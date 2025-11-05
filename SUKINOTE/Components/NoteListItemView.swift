//
//  NoteRowView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NoteListItemView: View {
    let note: Note
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: note.category.icon)
                .imageScale(.large)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "No Title" : note.title)
                    .font(.headline)
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .background(Color.white)
        .onTapGesture { onTap() }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    List {
        NoteListItemView(
            note: Note(
                category: .like,
                title: "Sample Note",
                content: "This is a sample content with extended length of text"
            ),
            onTap: {},
            onEdit: {},
            onDelete: {}
        )
    }
}
