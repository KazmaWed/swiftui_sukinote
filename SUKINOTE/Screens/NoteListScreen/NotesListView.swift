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
    var bottomPadding: CGFloat = 0

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
            .transition(.opacity)
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
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    )
                )
            }
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: bottomPadding)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    NotesListView(
        notes: [
            // like (2)
            Note(category: .like, title: "Like • Coffee", content: "Flat white"),
            Note(category: .like, title: "Like • Music", content: "Lo-fi beats"),
            // dislike (1)
            Note(category: .dislike, title: "Dislike • Weather", content: "Humidity"),
            // anniversary (1)
            Note(category: .anniversary, title: "Anniversary • Wedding", content: "2018-06-17"),
            // family (1)
            Note(category: .family, title: "Family • Call", content: "Mom on Sunday"),
            // hobby (2)
            Note(category: .hobby, title: "Hobby • Photography", content: "Street"),
            Note(category: .hobby, title: "Hobby • Reading", content: "Sci-fi"),
            // school (1)
            Note(category: .school, title: "School • Lecture", content: "iOS Patterns"),
            // work (2)
            Note(category: .work, title: "Work • Design Review", content: "GlassSnapDial"),
            Note(category: .work, title: "Work • Retro", content: "Friday")
        ],
        onNoteTap: { _ in },
        onNoteEdit: { _ in },
        onNoteDelete: { _ in }
    )
}