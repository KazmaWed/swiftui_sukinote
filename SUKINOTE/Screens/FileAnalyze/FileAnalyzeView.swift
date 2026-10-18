import SwiftUI
import UniformTypeIdentifiers

struct FileAnalyzeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: FileAnalyzeModel
    var onFinish: () -> Void

    @State private var isStopAnalysisAlertPresented: Bool = false

    init(
        fileURL: URL,
        analyzeService: any TalkAnalyzeService = RemoteTalkAnalyzeService.mockBackend,
        onFinish: @escaping () -> Void = {}
    ) {
        _model = State(initialValue: FileAnalyzeModel(fileURL: fileURL, analyzeService: analyzeService))
        self.onFinish = onFinish
    }

    private var contentType: UTType? {
        UTType(filenameExtension: model.fileURL.pathExtension)
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

            Text(model.fileURL.lastPathComponent)
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
        .task {
            await model.loadFile()
        }
        .overlay {
            if model.isAnalyzing {
                analyzingOverlay
            }
        }
        .navigationBarBackButtonHidden(model.isAnalyzing)
        .interactiveDismissDisabled(model.isAnalyzing)
        .toolbar {
            if model.isAnalyzing {
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
                get: { model.analysisResult != nil },
                set: { if !$0 { model.analysisResult = nil } }
            )
        ) {
            if let analysisResult = model.analysisResult {
                NavigationStack {
                    AnalysisResultView(analysis: analysisResult, onClose: onFinish)
                }
            }
        }
        .alert("Stop analyzing?", isPresented: $isStopAnalysisAlertPresented) {
            Button("Stop", role: .destructive) {
                model.cancelAnalysis()
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
        switch model.loadState {
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
                    model.startAnalysis()
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .controlSize(.large)
                .disabled(model.isAnalyzing)
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
                    Task { await model.loadFile() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileAnalyzeView(fileURL: URL(fileURLWithPath: "/tmp/sample.txt"))
    }
}
