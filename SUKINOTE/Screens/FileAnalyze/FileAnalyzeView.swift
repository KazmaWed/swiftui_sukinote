import SwiftUI
import UniformTypeIdentifiers

struct FileAnalyzeView: View {
    let fileURL: URL

    private enum LoadState {
        case loading
        case loaded(Data, format: ImportedFileFormat)
        case failed(Error)
    }

    @State private var loadState: LoadState = .loading

    private var contentType: UTType? {
        UTType(filenameExtension: fileURL.pathExtension)
    }

    private var iconName: String {
        if contentType?.conforms(to: .image) == true { return "photo" }
        return "doc.text"
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(fileURL.lastPathComponent)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            statusView
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Analyze File")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: fileURL) {
            await loadFile()
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch loadState {
        case .loading:
            ProgressView("Loading...")
        case .loaded(let data, let format):
            VStack(spacing: 8) {
                Text(data.count.formatted(.byteCount(style: .file)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Format: \(String(describing: format))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("AI Analyze") {
                    Task { await analyzeTalk(data: data) }
                }
            }
        case .failed(let error):
            VStack(spacing: 12) {
                Text("Failed to load the file.")
                    .font(.body)
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await loadFile() }
                }
            }
        }
    }

    private func loadFile() async {
        loadState = .loading
        do {
            let data = try await Self.readData(from: fileURL)
            let format = await Self.detectFormat(fileURL: fileURL, data: data)
            loadState = .loaded(data, format: format)
        } catch {
            loadState = .failed(error)
        }
    }

    // TODO: Show the result on screen instead of printing it
    private func analyzeTalk(data: Data) async {
        do {
            let input = try await Self.makeTalkInput(from: data)
            // TODO: Let the user choose the subject person; uses the first sender for now
            guard let subjectName = input.firstSender else {
                print("[AnalyzeTalk] No messages found in the file")
                return
            }
            print("[AnalyzeTalk] Analyzing about \(subjectName)...")
            let analysis = try await RemoteTalkAnalyzeService.mockBackend.analyze(
                subjectName: subjectName,
                talkJSON: input.json
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            print("[AnalyzeTalk] Result:\n" + String(decoding: try encoder.encode(analysis), as: UTF8.self))
        } catch {
            print("[AnalyzeTalk] Failed: \(error)")
        }
    }
}

private extension FileAnalyzeView {

    /// Parses LINE chat history into the JSON sent for analysis.
    /// Runs off the main actor since chat histories can be large.
    @concurrent
    nonisolated static func makeTalkInput(from data: Data) async throws -> (json: String, firstSender: String?) {
        let log = LineTalkParser.parse(String(decoding: data, as: UTF8.self))
        let firstSender = log.days.lazy.flatMap(\.messages).first { !$0.sender.isEmpty }?.sender
        return (String(decoding: try log.jsonData(), as: UTF8.self), firstSender)
    }

    @concurrent
    nonisolated static func detectFormat(fileURL: URL, data: Data) async -> ImportedFileFormat {
        ImportedFileFormat.detect(fileURL: fileURL, data: data)
    }

    /// Runs off the main actor because NSFileCoordinator blocks
    /// while waiting for the file (e.g. an iCloud download) to become available.
    @concurrent
    nonisolated static func readData(from url: URL) async throws -> Data {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess { url.stopAccessingSecurityScopedResource() }
        }

        var coordinatorError: NSError?
        var result: Result<Data, Error>?
        NSFileCoordinator().coordinate(
            readingItemAt: url,
            options: [],
            error: &coordinatorError
        ) { readingURL in
            result = Result { try Data(contentsOf: readingURL) }
        }
        if let coordinatorError {
            throw coordinatorError
        }
        guard let result else {
            throw CocoaError(.fileReadUnknown)
        }
        return try result.get()
    }
}

#Preview {
    NavigationStack {
        FileAnalyzeView(fileURL: URL(fileURLWithPath: "/tmp/sample.txt"))
    }
}
