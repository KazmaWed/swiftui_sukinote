import Foundation

// NOTE: What the backend will do for POST /analyze-talk: send the chat history to GPT with Structured Outputs and return the result as is.
// Uses the API key in Secrets.plist, so it must be replaced by the real backend before release.
// The prompt and the schema live in Prompts/ as plain files so they can be evaluated and moved to the backend as is;
// the schema must match TalkAnalysis.
nonisolated enum MockBackendAnalyzeTalkHandler {

    private struct AnalyzeTalkRequest: Decodable {
        let subjectName: String
        let talk: String
        let today: String
    }

    private struct ChatCompletionResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let content: String?
                let refusal: String?
            }
            let message: Message
        }
        let choices: [Choice]
    }

    private static let chatCompletionsURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private static let todayPlaceholder = "{{today}}"

    static func handle(requestBody: Data) async -> (statusCode: Int, body: Data) {
        guard let analyzeRequest = try? JSONDecoder().decode(AnalyzeTalkRequest.self, from: requestBody) else {
            return errorResponse(400, "Invalid request body")
        }
        guard !analyzeRequest.subjectName.isEmpty else {
            return errorResponse(400, "subjectName must not be empty")
        }
        guard let secrets = loadSecrets() else {
            return errorResponse(500, "Secrets.plist with OpenAIAPIKey and OpenAIModel is missing")
        }
        guard let promptTemplate = loadSystemPrompt(), let responseSchema = loadResponseSchema() else {
            return errorResponse(500, "analyze_talk_system_prompt.txt or analyze_talk_response_schema.json is missing or invalid")
        }
        guard let today = describeDate(analyzeRequest.today) else {
            return errorResponse(400, "today must be a date in yyyy-MM-dd format")
        }
        let systemPrompt = promptTemplate.replacingOccurrences(of: todayPlaceholder, with: today)
        let userMessage = """
            Subject person: \(analyzeRequest.subjectName)
            Chat history:
            \(analyzeRequest.talk)
            """

        do {
            var request = URLRequest(url: chatCompletionsURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(secrets.apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "model": secrets.model,
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": userMessage]
                ],
                "response_format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "talk_analysis",
                        "strict": true,
                        "schema": responseSchema
                    ]
                ]
            ])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                return (502, data)
            }

            let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            guard let message = completion.choices.first?.message else {
                return errorResponse(502, "No choices in the response")
            }
            if let refusal = message.refusal {
                return errorResponse(422, refusal)
            }
            guard let content = message.content else {
                return errorResponse(502, "No content in the response")
            }
            return (200, Data(content.utf8))
        } catch {
            return errorResponse(502, error.localizedDescription)
        }
    }
}

nonisolated private extension MockBackendAnalyzeTalkHandler {

    static func loadSecrets() -> (apiKey: String, model: String)? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let secrets = NSDictionary(contentsOf: url),
              let apiKey = secrets["OpenAIAPIKey"] as? String, !apiKey.isEmpty,
              let model = secrets["OpenAIModel"] as? String, !model.isEmpty else {
            return nil
        }
        return (apiKey, model)
    }

    // NOTE: Adds the weekday (e.g. "2026-10-08 (Thursday)") so the model can resolve expressions such as "next Friday"
    static func describeDate(_ isoDate: String) -> String? {
        let parseStrategy = Date.ISO8601FormatStyle().year().month().day().dateSeparator(.dash)
        guard let date = try? Date(isoDate, strategy: parseStrategy) else { return nil }

        var weekdayStyle = Date.FormatStyle(locale: Locale(identifier: "en_US_POSIX")).weekday(.wide)
        weekdayStyle.timeZone = .gmt
        return "\(isoDate) (\(date.formatted(weekdayStyle)))"
    }

    static func loadSystemPrompt() -> String? {
        guard let url = Bundle.main.url(forResource: "analyze_talk_system_prompt", withExtension: "txt") else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    static func loadResponseSchema() -> Any? {
        guard let url = Bundle.main.url(forResource: "analyze_talk_response_schema", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data)
    }

    static func errorResponse(_ statusCode: Int, _ message: String) -> (statusCode: Int, body: Data) {
        let body = (try? JSONSerialization.data(withJSONObject: ["error": message])) ?? Data()
        return (statusCode, body)
    }
}
