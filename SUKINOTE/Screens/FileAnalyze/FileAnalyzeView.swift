import SwiftUI
import UniformTypeIdentifiers

struct FileAnalyzeView: View {
    @Environment(\.dismiss) private var dismiss
    let fileURL: URL

    private enum LoadState {
        case loading
        case loaded(Data, format: ImportedFileFormat)
        case failed(Error)
    }

    @State private var loadState: LoadState = .loading
    @State private var analysisTask: Task<Void, Never>? = nil  // Non-nil while the AI analysis is running
    @State private var analysisResult: TalkAnalysis? = nil  // Set when the analysis completes to show the result
    @State private var isStopAnalysisAlertPresented: Bool = false

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
        .navigationTitle("Analyze File")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: fileURL) {
            await loadFile()
        }
        .overlay {
            if analysisTask != nil {
                analyzingOverlay
            }
        }
        .navigationBarBackButtonHidden(analysisTask != nil)
        .interactiveDismissDisabled(analysisTask != nil)
        .toolbar {
            if analysisTask != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isStopAnalysisAlertPresented = true
                    } label: {
                        Image(systemName: "chevron.backward")
                            .accessibilityLabel("Back")
                    }
                }
            }
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { analysisResult != nil },
                set: { if !$0 { analysisResult = nil } }
            )
        ) {
            if let analysisResult {
                NavigationStack {
                    AnalysisResultView(analysis: analysisResult)
                }
            }
        }
        .alert("Stop analyzing?", isPresented: $isStopAnalysisAlertPresented) {
            Button("Stop", role: .destructive) {
                analysisTask?.cancel()
                dismiss()
            }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("The analysis in progress will be cancelled.")
        }
    }

    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView("Analyzing...")
                .controlSize(.large)
                .tint(.white)
                .foregroundStyle(.white)
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
                Spacer()
                Button("AI Analyze") {
                    analysisTask = Task {
                        await analyzeTalk(data: data)
                        analysisTask = nil
                    }
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .controlSize(.large)
                .disabled(analysisTask != nil)
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
            analysisResult = analysis
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
