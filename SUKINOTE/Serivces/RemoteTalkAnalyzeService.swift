import Foundation

final class RemoteTalkAnalyzeService: TalkAnalyzeService {

    enum APIError: Error {
        case invalidResponse
        case httpError(statusCode: Int)
    }

    private struct AnalyzeTalkRequest: Encodable {
        let subjectName: String
        // NOTE: Sent as a JSON string rather than an object so the backend passes it to the model as is;
        // decoding it into a dictionary would lose the order of the dates
        let talk: String
        // NOTE: The user's local date (yyyy-MM-dd), which the backend uses to resolve dates such as "next Friday"
        let today: String
    }

    private let baseURL: URL
    private let session: URLSession
    private let currentDate: () -> Date

    init(
        baseURL: URL,
        session: URLSession,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.baseURL = baseURL
        self.session = session
        self.currentDate = currentDate
    }

    func analyze(subjectName: String, talkJSON: String) async throws -> TalkAnalysis {
        var request = URLRequest(url: baseURL.appending(path: "analyze-talk"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // NOTE: Format in the device's time zone; the ISO 8601 style defaults to GMT, which is a day off around midnight
        let todayStyle = Date.ISO8601FormatStyle(timeZone: .current).year().month().day().dateSeparator(.dash)
        request.httpBody = try JSONEncoder().encode(
            AnalyzeTalkRequest(subjectName: subjectName, talk: talkJSON, today: currentDate().formatted(todayStyle))
        )

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(TalkAnalysis.self, from: data)
    }
}

extension RemoteTalkAnalyzeService {

    // TODO: Replace with the real backend's base URL and URLSession.shared once the backend is built
    static let mockBackend = RemoteTalkAnalyzeService(
        baseURL: MockBackendURLProtocol.baseURL,
        session: MockBackendURLProtocol.makeSession()
    )
}
