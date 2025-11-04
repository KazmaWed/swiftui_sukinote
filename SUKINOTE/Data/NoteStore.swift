//
//  NoteStore.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/01.
//

import Foundation
import SwiftData
import ComposableArchitecture

struct NoteStore {
    var fetchNotes: @Sendable () async throws -> [Note]
    var saveNote: @Sendable (Note) async throws -> Void
    var deleteNote: @Sendable (Note) async throws -> Void
}

extension NoteStore: DependencyKey {
    static let liveValue: NoteStore = {
        let container = try! ModelContainer(for: Note.self)

        return NoteStore(
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
    }()
}

extension DependencyValues {
    var noteStore: NoteStore {
        get { self[NoteStore.self] }
        set { self[NoteStore.self] = newValue }
    }
}