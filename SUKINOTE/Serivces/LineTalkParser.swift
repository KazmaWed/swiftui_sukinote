import Foundation

/// Chat history parsed from a text file exported by LINE ("トーク履歴を送信").
nonisolated struct LineTalkLog: Equatable, Sendable {
    var title: String?  // e.g. "○○とのトーク履歴"
    var days: [LineTalkDay]
}

nonisolated struct LineTalkDay: Equatable, Sendable {
    var date: String  // "yyyy-MM-dd"
    var messages: [LineTalkMessage]
}

/// Encoded as `[time, sender, text]` to keep the JSON compact for LLM prompts.
nonisolated struct LineTalkMessage: Equatable, Sendable, Encodable {
    var time: String  // "HH:mm"
    var sender: String  // Empty for system messages
    var text: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(time)
        try container.encode(sender)
        try container.encode(text)
    }
}

extension LineTalkLog {
    /// JSON keyed by date, each day holding `[time, sender, text]` arrays:
    /// `{"2026-10-13":[["12:34","taro","おはよう"],...],...}`
    nonisolated func jsonData() throws -> Data {
        var messagesByDate: [String: [LineTalkMessage]] = [:]
        for day in days {
            messagesByDate[day.date, default: []].append(contentsOf: day.messages)
        }
        let encoder = JSONEncoder()
        // "yyyy-MM-dd" keys sort chronologically
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(messagesByDate)
    }
}

/// Parses LINE chat history text.
///
/// The format is not officially documented and depends on the app language:
/// ```
/// [LINE] ○○とのトーク履歴             [LINE] Chat history with ○○
/// 保存日時：2026/10/14 21:00           Saved on: 2026/10/14, 21:00
///
/// 2026/10/13(月)                       2026/10/13 Mon
/// 12:34<TAB>taro<TAB>おはよう
/// 12:35<TAB>hanako<TAB>"1行目
/// 2行目"
/// ```
/// Older exports use date lines like `2022.10.13 木曜日`; all of these are accepted.
nonisolated enum LineTalkParser {
    static func parse(_ text: String) -> LineTalkLog {
        let lines = text
            .replacingOccurrences(of: "\u{FEFF}", with: "")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")

        var title: String?
        var days: [LineTalkDay] = []
        var currentMessage: PendingMessage?

        func flushMessage() {
            guard let message = currentMessage, !days.isEmpty else { return }
            days[days.count - 1].messages.append(message.finalized())
            currentMessage = nil
        }

        for line in lines {
            if let date = parseDate(line) {
                flushMessage()
                days.append(LineTalkDay(date: date, messages: []))
            } else if !days.isEmpty, let message = parseMessageLine(line) {
                flushMessage()
                currentMessage = message
            } else if days.isEmpty {
                // Header area before the first date line
                if title == nil, let match = line.wholeMatch(of: headerPattern) {
                    title = String(match.1)
                }
            } else {
                // Continuation of a multi-line message (blank lines included)
                currentMessage?.continuationLines.append(line)
            }
        }
        flushMessage()

        return LineTalkLog(title: title, days: days)
    }

    // MARK: - Line patterns

    private static let headerPattern = #/\[LINE\]\s*(.+)/#
    // The suffix is limited to a weekday so that message lines
    // such as "2026/10/13 に会おう" are not mistaken for dates:
    //   2026/10/13(月)      Japanese
    //   2026/08/31 Mon      English
    //   2022.10.13 木曜日    Older exports
    private static let datePattern =
        #/(\d{4})[/.](\d{1,2})[/.](\d{1,2})(?:\(.\)| (?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)| .曜日)/#
    // 12:34<TAB>rest
    private static let messagePattern = #/(\d{1,2}):(\d{2})\t(.*)/#

    private static func parseDate(_ line: String) -> String? {
        guard let match = line.wholeMatch(of: datePattern),
            let month = Int(match.2), let day = Int(match.3),
            (1...12).contains(month), (1...31).contains(day)
        else { return nil }
        return "\(match.1)-\(twoDigits(month))-\(twoDigits(day))"
    }

    private static func parseMessageLine(_ line: String) -> PendingMessage? {
        guard let match = line.wholeMatch(of: messagePattern),
            let hour = Int(match.1), hour < 24
        else { return nil }
        let time = "\(twoDigits(hour)):\(match.2)"

        // "sender<TAB>text", or just "text" for some system messages
        let rest = match.3
        if let tabIndex = rest.firstIndex(of: "\t") {
            return PendingMessage(
                time: time,
                sender: String(rest[..<tabIndex]),
                firstLine: String(rest[rest.index(after: tabIndex)...])
            )
        }
        return PendingMessage(time: time, sender: "", firstLine: String(rest))
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    private struct PendingMessage {
        var time: String
        var sender: String
        var firstLine: String
        var continuationLines: [String] = []

        func finalized() -> LineTalkMessage {
            var bodyLines = continuationLines
            // Blank lines before the next date line belong to the layout, not the message
            while let last = bodyLines.last, last.isEmpty {
                bodyLines.removeLast()
            }
            var text = ([firstLine] + bodyLines).joined(separator: "\n")

            // LINE wraps multi-line messages in double quotes.
            // Single-line messages are left as is, since they may legitimately start with a quote.
            if !bodyLines.isEmpty, text.count >= 2,
                text.hasPrefix("\""), text.hasSuffix("\"")
            {
                text = String(text.dropFirst().dropLast())
            }
            return LineTalkMessage(time: time, sender: sender, text: text)
        }
    }
}
