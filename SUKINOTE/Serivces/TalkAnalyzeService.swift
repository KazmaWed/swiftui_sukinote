import Foundation

struct TalkAnalysis: Codable, Equatable {

    struct PartialDate: Codable, Equatable {
        var year: Int?
        var month: Int?
        var day: Int?
    }

    struct NoteCandidate: Codable, Equatable {
        var category: NoteCategory
        var title: String
        var content: String
        var date: PartialDate?  // Only for anniversary notes
        var isAnnual: Bool
    }

    var notes: [NoteCandidate]
}

protocol TalkAnalyzeService {

    /// - Parameters:
    ///   - subjectName: The person to extract notes about, as their sender name in the chat
    ///   - talkJSON: Chat history encoded by `LineTalkLog.jsonData()`
    func analyze(subjectName: String, talkJSON: String) async throws -> TalkAnalysis
}
