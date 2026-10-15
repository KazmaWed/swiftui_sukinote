import SwiftUI
import UniformTypeIdentifiers

struct FileAnalyzeView: View {
    let fileURL: URL

    private enum LoadState {
        case loading
        case loaded(Data, format: ImportedFileFormat, json: String?)  // json is nil for non-text files
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
        case .loaded(let data, let format, let json):
            VStack(spacing: 8) {
                Text(data.count.formatted(.byteCount(style: .file)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Format: \(String(describing: format))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let json {
                    ScrollView {
                        Text(json)
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("Analyze this file to create notes.\nThis feature is coming soon.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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
            let json =
                contentType?.conforms(to: .image) == true
                ? nil : try await Self.makeLineTalkJSON(from: data)
            loadState = .loaded(data, format: format, json: json)
        } catch {
            loadState = .failed(error)
        }
    }
}

private extension FileAnalyzeView {

    @concurrent
    nonisolated static func detectFormat(fileURL: URL, data: Data) async -> ImportedFileFormat {
        ImportedFileFormat.detect(fileURL: fileURL, data: data)
    }

    /// Parses LINE chat history text into the JSON passed to LLMs.
    /// Runs off the main actor since chat histories can be large.
    @concurrent
    nonisolated static func makeLineTalkJSON(
        from data: Data
    ) async throws -> String {
        let log = LineTalkParser.parse(String(decoding: data, as: UTF8.self))
        return String(decoding: try log.jsonData(), as: UTF8.self)
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
