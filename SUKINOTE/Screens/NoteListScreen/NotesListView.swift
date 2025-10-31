//
//  NotesListComponent.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NotesListView: View {
    let notes: [Note]
    let onNoteTap: (Note) -> Void
    let onNoteEdit: (Note) -> Void
    let onNoteDelete: (Note) -> Void

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
            Note(
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