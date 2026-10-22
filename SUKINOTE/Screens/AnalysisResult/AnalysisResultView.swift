import SwiftUI

struct AnalysisResultView: View {
    @State private var model: AnalysisResultModel
    var onClose: () -> Void

    @State private var isCloseAlertPresented: Bool = false

    init(analysis: TalkAnalysis, onClose: @escaping () -> Void = {}) {
        _model = State(initialValue: AnalysisResultModel(analysis: analysis))
        self.onClose = onClose
    }

    var body: some View {
        List(model.notes.indices, id: \.self) { index in
            let candidate = model.notes[index]
            NoteRowContent(
                category: candidate.category,
                title: candidate.title,
                dateText: model.dateText(for: candidate),
                content: candidate.content
            )
            .background(.background)
            .onTapGesture { model.editingIndex = index }
        }
        .listStyle(.plain)
        .sheet(
            isPresented: Binding(
                get: { model.editingIndex != nil },
                set: { if !$0 { model.editingIndex = nil } }
            )
        ) {
            if let index = model.editingIndex {
                NoteEditView(noteToEdit: model.noteForEditing(at: index)) { note in
                    model.updateNote(at: index, with: note)
                }
            }
        }
        .overlay {
            if model.notes.isEmpty {
                Text("No note.")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save") {
                model.save()
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .controlSize(.large)
            .padding()
        }
        .navigationTitle("Analysis Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isCloseAlertPresented = true
                } label: {
                    Image(systemName: "xmark")
                        .accessibilityLabel("Close")
                }
            }
        }
        .alert("Discard the results?", isPresented: $isCloseAlertPresented) {
            Button("Discard", role: .destructive) {
                onClose()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The analysis results will not be saved.")
        }
    }
}

#Preview {
    NavigationStack {
        AnalysisResultView(
            analysis: TalkAnalysis(notes: [
                .init(category: .like, title: "和食", content: "和食が好き。食べ物は割となんでも好き", date: nil, isAnnual: false),
                .init(category: .dislike, title: "ラム肉", content: "ラム肉が少し苦手", date: nil, isAnnual: false),
                .init(
                    category: .anniversary,
                    title: "誕生日",
                    content: "誕生日は11月12日",
                    date: .init(year: nil, month: 11, day: 12),
                    isAnnual: true
                ),
            ])
        )
    }
}
