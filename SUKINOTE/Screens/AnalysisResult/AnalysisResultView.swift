import SwiftUI

struct AnalysisResultView: View {
    let analysis: TalkAnalysis
    var onClose: () -> Void = {}

    @State private var isCloseAlertPresented: Bool = false

    var body: some View {
        List(analysis.notes.indices, id: \.self) { index in
            let candidate = analysis.notes[index]
            NoteRowContent(
                category: candidate.category,
                title: candidate.title,
                dateText: candidate.date.flatMap(Self.format),
                content: candidate.content
            )
        }
        .listStyle(.plain)
        .overlay {
            if analysis.notes.isEmpty {
                Text("No note.")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save") {
                // TODO: Save the notes
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

private extension AnalysisResultView {

    /// Formats only the known parts of the date, e.g. "November 12" when the year is unknown.
    static func format(_ date: TalkAnalysis.PartialDate) -> String? {
        // NOTE: A leap year stands in for an unknown year so that February 29 stays valid
        let components = DateComponents(year: date.year ?? 2000, month: date.month ?? 1, day: date.day ?? 1)
        guard let resolved = Calendar.current.date(from: components) else { return nil }

        switch (date.year, date.month, date.day) {
        case (.some, .some, .some):
            return resolved.formatted(date: .long, time: .omitted)
        case (nil, .some, .some):
            return resolved.formatted(.dateTime.month(.wide).day())
        case (.some, .some, nil):
            return resolved.formatted(.dateTime.year().month(.wide))
        case (.some, nil, nil):
            return resolved.formatted(.dateTime.year())
        default:
            return nil
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
