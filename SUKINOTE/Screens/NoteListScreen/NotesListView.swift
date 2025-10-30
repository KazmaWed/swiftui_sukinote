//
//  NotesListComponent.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NotesListView: View {
    let notes: [any NoteProtocol]
    let onNoteTap: (any NoteProtocol) -> Void
    let onNoteEdit: (any NoteProtocol) -> Void
    let onNoteDelete: (any NoteProtocol) -> Void

    var body: some View {
        if notes.isEmpty {
            VStack {
                Text("No note.")
                    .foregroundColor(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
            .background(Color(.systemGroupedBackground))
        } else {
            List(notes, id: \.id) { note in
                NoteListItemView(
                    note: note,
                    onTap: {
                        onNoteTap(note)
                    },
                    onEdit: {
                        onNoteEdit(note)
                    },
                    onDelete: {
                        onNoteDelete(note)
                    }
                )
            }
        }
    }
}

#Preview {
    NotesListView(
        notes: [
            Note.create(
                category: .like,
                title: "Sample Note",
                content: "This is a sample content"
            )
        ],
        onNoteTap: { _ in },
        onNoteEdit: { _ in },
        onNoteDelete: { _ in }
    )
}