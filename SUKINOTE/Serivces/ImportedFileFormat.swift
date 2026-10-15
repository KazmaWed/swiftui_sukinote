import Foundation
import UniformTypeIdentifiers

/// Format of an imported file, which decides how the file is analyzed.
nonisolated enum ImportedFileFormat: Equatable, Sendable {
    case lineTalk
    case plainText
    case image
    case unsupported
}

extension ImportedFileFormat {

    nonisolated static func detect(fileURL: URL, data: Data) -> ImportedFileFormat {
        guard let contentType = UTType(filenameExtension: fileURL.pathExtension) else { return .unsupported }
        
        if contentType.conforms(to: .image) { return .image }
        
        guard contentType.conforms(to: .text),
              let text = String(data: data, encoding: .utf8)
        else { return .unsupported }
        
        return detectTextFormat(text)
    }
}

private extension ImportedFileFormat {

    private nonisolated static func detectTextFormat(_ text: String) -> ImportedFileFormat {
        if isLineTalk(text) { return .lineTalk }
        return .plainText
    }

    private nonisolated static func isLineTalk(_ text: String) -> Bool {
        LineTalkParser.parse(text).days.contains { !$0.messages.isEmpty }
    }
}
