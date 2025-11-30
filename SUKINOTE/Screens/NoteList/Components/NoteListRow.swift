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
        HStack {
            // Category icon
            Image(systemName: note.category.iconFilled)
                .imageScale(.large)
                .foregroundStyle(note.category.highlightColor)
                .frame(width: 24, alignment: .center)
            Spacer().frame(width: 16)
            // Title, Content
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
            Spacer().frame(width: 16)
            Spacer()
            // Image thumbnail
            if let images = note.images, let firstImage = images.first,
               let uiImage = UIImage(data: firstImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
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
    let sampleImageData: Data? = {
        if let path = Bundle.main.path(forResource: "sample_image", ofType: "jpg"),
           let image = UIImage(contentsOfFile: path) {
            return image.jpegData(compressionQuality: 0.8)
        }
        return nil
    }()

    return List {
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

        if let imageData = sampleImageData {
            NoteListRow(
                note: Note(
                    category: .like,
                    title: "Note with Image",
                    content: "This note has an attached image",
                    images: [imageData]
                ),
                onTap: {},
                onEdit: {},
                onDelete: {}
            )
        }
    }
}
