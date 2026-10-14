import SwiftUI
import UniformTypeIdentifiers

struct FileAnalyzeView: View {
    let fileURL: URL

    private enum LoadState {
        case loading
        case loaded(Data)
        case failed(Error)
    }

    @State private var loadState: LoadState = .loading

    private var contentType: UTType? {
        UTType(filenameExtension: fileURL.pathExtension)
    }

    private var iconName: String {
        if contentType?.conforms(to: .image) == true {
            return "photo"
        }
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

            Spacer()
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
        case .loaded(let data):
            VStack(spacing: 8) {
                Text(data.count.formatted(.byteCount(style: .file)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Analyze this file to create notes.\nThis feature is coming soon.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
            loadState = .loaded(try await Self.readData(from: fileURL))
        } catch {
            loadState = .failed(error)
        }
    }

    /// Runs off the main actor because NSFileCoordinator blocks
    /// while waiting for the file (e.g. an iCloud download) to become available.
    @concurrent
    nonisolated private static func readData(from url: URL) async throws -> Data {
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
