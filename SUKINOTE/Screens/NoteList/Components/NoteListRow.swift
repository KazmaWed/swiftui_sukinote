//
//  NoteListRow.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NoteListRow: View {
    let note: Note
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: note.category.iconFilled)
                .imageScale(.large)
                .foregroundStyle(note.category.highlightColor)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "No Title" : note.title)
                    .font(.headline)
                if let anniversaryDate = note.anniversaryDate {
                    Text(anniversaryDate.formatted(date: .long, time: .omitted))
                        .font(.headline)
                        .fontWeight(.regular)
                }
                if note.content != "" {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .background(.background)
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
        NoteListRow(
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
