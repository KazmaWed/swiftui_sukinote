import SwiftUI

/// Layout of a note row, shared by saved notes and analysis results.
struct NoteRowContent: View {
    let category: NoteCategory
    let title: String
    var dateText: String? = nil
    let content: String
    var thumbnailData: Data? = nil

    var body: some View {
        HStack {
            // Category icon
            Image(systemName: category.iconFilled)
                .imageScale(.large)
                .foregroundStyle(category.highlightColor)
                .frame(width: 24, alignment: .center)
            Spacer().frame(width: 16)
            // Title, Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title.isEmpty ? "No Title" : title)
                    .font(.headline)
                if let dateText {
                    Text(dateText)
                        .font(.headline)
                        .fontWeight(.regular)
                }
                if content != "" {
                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer().frame(width: 16)
            Spacer()
            // Image thumbnail
            if let thumbnailData, let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    List {
        NoteRowContent(
            category: .like,
            title: "和食",
            content: "和食が好き。食べ物は割となんでも好き"
        )
        NoteRowContent(
            category: .anniversary,
            title: "誕生日",
            dateText: "November 12",
            content: "誕生日は11月12日"
        )
    }
}
