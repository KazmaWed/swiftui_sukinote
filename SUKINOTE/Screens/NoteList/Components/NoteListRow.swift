import SwiftUI

struct NoteListRow: View {
    let note: Note
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NoteRowContent(
            category: note.category,
            title: note.title,
            dateText: note.anniversaryDate?.formatted(date: .long, time: .omitted),
            content: note.content,
            thumbnailData: note.images?.first
        )
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
