import Foundation
import Observation

@Observable
final class AnalysisResultModel {
    private(set) var notes: [TalkAnalysis.NoteCandidate]

    init(analysis: TalkAnalysis) {
        notes = analysis.notes
    }

    func dateText(for candidate: TalkAnalysis.NoteCandidate) -> String? {
        candidate.date.flatMap(Self.format)
    }

    func save() {
        // TODO: Save the notes
    }
}

private extension AnalysisResultModel {

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
