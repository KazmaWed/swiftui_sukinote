import Foundation
import Testing
@testable import SUKINOTE

struct LineTalkParserTests {

    // MARK: - Fixtures

    @Test func parsesEnglishGroupChat() throws {
        let log = LineTalkParser.parse(try fixture("line_en_group"))

        #expect(log.title == "Chat history in ボードゲーム部")
        #expect(log.days.map(\.date) == ["2026-08-31", "2026-09-01"])
        #expect(log.days[0].messages == [
            LineTalkMessage(time: "23:25", sender: "ゆうき", text: "ご飯食べたら遊ぼう"),
            LineTalkMessage(time: "23:26", sender: "Taro Yamada", text: "何する？"),
            LineTalkMessage(time: "23:26", sender: "はなこ", text: "みんな元気だね\n眠くなってきた(emoji)"),
            LineTalkMessage(time: "23:26", sender: "はなこ", text: "人狼する？"),
            LineTalkMessage(time: "23:37", sender: "はなこ", text: "[Photo]"),
            LineTalkMessage(time: "23:37", sender: "Taro Yamada", text: "[Photo]"),
        ])
        #expect(log.days[1].messages == [
            LineTalkMessage(
                time: "12:29",
                sender: "はなこ",
                text: "おすすめの番組\n#TVer\nhttps://example.com/episodes/abc123"
            ),
            LineTalkMessage(time: "12:30", sender: "", text: "ゆうきがアルバムを作成しました"),
            LineTalkMessage(time: "13:11", sender: "ゆうき", text: "昨日のゲーム楽しかった\n\nまた来週もやろう"),
        ])
    }

    @Test func parsesJapaneseOneOnOneChat() throws {
        let log = LineTalkParser.parse(try fixture("line_ja_one_on_one"))

        #expect(log.title == "山田花子とのトーク履歴")
        #expect(log.days.map(\.date) == ["2026-10-10", "2026-10-11"])
        #expect(log.days[0].messages == [
            LineTalkMessage(time: "21:03", sender: "山田花子", text: "こんばんは！\nよろしくお願いします☺️"),
            LineTalkMessage(time: "21:04", sender: "山田太郎", text: "こちらこそ、よろしくお願いします"),
        ])
        // The file ends without a trailing newline
        #expect(log.days[1].messages == [
            LineTalkMessage(
                time: "09:51",
                sender: "山田花子",
                text: "おはようございます🌞\n\n週末はスタバで本を読んでました(emoji)"
            ),
        ])
    }

    // MARK: - Line formats

    @Test(arguments: [
        ("2026/10/13(月)", "2026-10-13"),
        ("2026/08/31 Mon", "2026-08-31"),
        ("2022.10.13 木曜日", "2022-10-13"),
        ("2026/1/5(月)", "2026-01-05"),
    ])
    func parsesDateLineFormats(line: String, expectedDate: String) {
        let log = LineTalkParser.parse("\(line)\n12:00\ta\tb")

        #expect(log.days.map(\.date) == [expectedDate])
    }

    @Test func normalizesSingleDigitHour() {
        let log = LineTalkParser.parse("2026/10/13(月)\n9:05\ta\tおはよう")

        #expect(log.days[0].messages == [LineTalkMessage(time: "09:05", sender: "a", text: "おはよう")])
    }

    @Test func handlesBOMAndCRLF() {
        let log = LineTalkParser.parse("\u{FEFF}[LINE] Chat history with a\r\n\r\n2026/10/13(月)\r\n12:00\ta\t\"1行目\r\n2行目\"\r\n")

        #expect(log.title == "Chat history with a")
        #expect(log.days[0].messages == [LineTalkMessage(time: "12:00", sender: "a", text: "1行目\n2行目")])
    }

    @Test func keepsTabsInMessageText() {
        let log = LineTalkParser.parse("2026/10/13(月)\n12:00\ta\tタブ\tを含む")

        #expect(log.days[0].messages == [LineTalkMessage(time: "12:00", sender: "a", text: "タブ\tを含む")])
    }

    // MARK: - Multi-line messages

    @Test func keepsQuotesOfSingleLineMessage() {
        let log = LineTalkParser.parse("2026/10/13(月)\n12:00\ta\t\"名言\"だよね\n12:01\tb\t\"引用\"")

        #expect(log.days[0].messages.map(\.text) == ["\"名言\"だよね", "\"引用\""])
    }

    @Test func doesNotTreatDateTextInMessageAsDateLine() {
        let log = LineTalkParser.parse("2026/10/13(月)\n12:00\ta\t\"予定\n2026/10/20 に会おう\n2026/10/20\nよろしく\"")

        #expect(log.days.count == 1)
        #expect(log.days[0].messages.map(\.text) == ["予定\n2026/10/20 に会おう\n2026/10/20\nよろしく"])
    }

    @Test func dropsBlankLinesBeforeNextDate() {
        let log = LineTalkParser.parse("2026/10/13(月)\n12:00\ta\tおはよう\n\n\n2026/10/14(火)\n12:00\ta\tこんにちは")

        #expect(log.days.map { $0.messages.map(\.text) } == [["おはよう"], ["こんにちは"]])
    }

    // MARK: - Invalid input

    @Test func returnsEmptyLogForEmptyText() {
        #expect(LineTalkParser.parse("") == LineTalkLog(title: nil, days: []))
    }

    @Test func ignoresMessagesBeforeFirstDate() {
        let log = LineTalkParser.parse("hello\n12:00\ta\tb")

        #expect(log.days.isEmpty)
    }

    @Test func doesNotTreatInvalidMonthAsDate() {
        let log = LineTalkParser.parse("2026/13/01(月)\n12:00\ta\tb")

        #expect(log.days.isEmpty)
    }

    // MARK: - JSON

    @Test func encodesJSONKeyedByDate() throws {
        let log = LineTalkLog(title: "t", days: [
            LineTalkDay(date: "2026-10-14", messages: [
                LineTalkMessage(time: "08:00", sender: "b", text: "2行\n目"),
            ]),
            LineTalkDay(date: "2026-10-13", messages: [
                LineTalkMessage(time: "12:00", sender: "a", text: "\"引用\" https://example.com/a"),
            ]),
        ])

        let json = String(decoding: try log.jsonData(), as: UTF8.self)

        #expect(json == #"{"2026-10-13":[["12:00","a","\"引用\" https://example.com/a"]],"2026-10-14":[["08:00","b","2行\n目"]]}"#)
    }

    // MARK: - Helpers

    private func fixture(_ name: String) throws -> String {
        let url = try #require(Bundle(for: BundleToken.self).url(forResource: name, withExtension: "txt"))
        return try String(contentsOf: url, encoding: .utf8)
    }
}

private final class BundleToken {}
