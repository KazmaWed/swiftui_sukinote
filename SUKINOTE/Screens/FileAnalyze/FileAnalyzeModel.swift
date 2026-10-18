import Foundation
import Observation

@Observable
final class FileAnalyzeModel {
    enum LoadState {
        case loading
        case loaded(Data, format: ImportedFileFormat)
        case failed(Error)
    }

    let fileURL: URL
    private(set) var loadState: LoadState = .loading
    var analysisResult: TalkAnalysis? = nil
    private var analysisTask: Task<Void, Never>? = nil

    @ObservationIgnored private let analyzeService: any TalkAnalyzeService

    init(fileURL: URL, analyzeService: any TalkAnalyzeService = RemoteTalkAnalyzeService.mockBackend) {
        self.fileURL = fileURL
        self.analyzeService = analyzeService
    }

    var isAnalyzing: Bool {
        analysisTask != nil
    }

    func loadFile() async {
        loadState = .loading
        do {
            let data = try await Self.readData(from: fileURL)
            let format = await Self.detectFormat(fileURL: fileURL, data: data)
            loadState = .loaded(data, format: format)
        } catch {
            loadState = .failed(error)
        }
    }

    func startAnalysis() {
        guard case .loaded(let data, _) = loadState, !isAnalyzing else { return }
        analysisTask = Task {
            await analyzeTalk(data: data)
            analysisTask = nil
        }
    }

    func cancelAnalysis() {
        analysisTask?.cancel()
        analysisTask = nil
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
            analysisResult = try await analyzeService.analyze(
                subjectName: subjectName,
                talkJSON: input.json
            )
        } catch {
            print("[AnalyzeTalk] Failed: \(error)")
        }
    }
}

private extension FileAnalyzeModel {

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
