import Foundation
import Observation

@Observable
final class AnalysisResultModel {
    private(set) var notes: [TalkAnalysis.NoteCandidate]
    var editingIndex: Int? = nil

    init(analysis: TalkAnalysis) {
        notes = analysis.notes
    }

    func dateText(for candidate: TalkAnalysis.NoteCandidate) -> String? {
        candidate.date.flatMap(Self.format)
    }

    func noteForEditing(at index: Int) -> Note {
        let candidate = notes[index]
        return Note(
            category: candidate.category,
            title: candidate.title,
            content: candidate.content,
            anniversaryDate: candidate.date.flatMap(Self.resolveDate),
            isAnnual: candidate.category == .anniversary ? candidate.isAnnual : nil
        )
    }

    func updateNote(at index: Int, with note: Note) {
        let components = note.anniversaryDate.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        notes[index] = TalkAnalysis.NoteCandidate(
            category: note.category,
            title: note.title,
            content: note.content,
            date: components.map { .init(year: $0.year, month: $0.month, day: $0.day) },
            isAnnual: note.isAnnual ?? false
        )
    }

    func save() {
        // TODO: Save the notes
    }
}

private extension AnalysisResultModel {

    static func resolveDate(_ date: TalkAnalysis.PartialDate) -> Date? {
        guard let month = date.month, let day = date.day else { return nil }
        let year = date.year ?? Calendar.current.component(.year, from: Date())
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

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
