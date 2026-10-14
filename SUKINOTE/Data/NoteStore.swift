import Foundation
import SwiftData

struct NoteStore: Sendable {
    var fetchNotes: @Sendable () async throws -> [Note]
    var saveNote: @Sendable (Note) async throws -> Void
    var deleteNote: @Sendable (Note) async throws -> Void
}

extension NoteStore {
    static func live(container: ModelContainer) -> NoteStore {
        NoteStore(
            fetchNotes: {
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<Note>(
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                )
                return try context.fetch(descriptor)
            },
            saveNote: { note in
                let context = ModelContext(container)
                context.insert(note)
                try context.save()
            },
            deleteNote: { note in
                let context = ModelContext(container)
                let noteID = note.id
                let descriptor = FetchDescriptor<Note>(
                    predicate: #Predicate { $0.id == noteID }
                )
                if let noteToDelete = try context.fetch(descriptor).first {
                    context.delete(noteToDelete)
                    try context.save()
                }
            }
        )
    }

    /// In-memory store backed by sample notes, for previews
    static let preview = NoteStore(
        fetchNotes: { MockData.sampleNotes },
        saveNote: { _ in },
        deleteNote: { _ in }
    )
}
