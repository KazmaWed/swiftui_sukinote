//
//  CategoryPickerView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct CategoryPickerView: View {
    let selectedCategory: NoteCategory
    let onCategorySelected: (NoteCategory) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(NoteCategory.allCases, id: \.self) { category in
                    Button(
                        action: { onCategorySelected(category) }
                    ) {
                        VStack(spacing: 2) {
                            Image(
                                systemName: selectedCategory == category
                                ? category.iconFilled
                                : category.icon
                            )
                            .imageScale(.large)
                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 8)
                    }
                    .foregroundStyle(
                        selectedCategory == category
                            ? Color.accentColor
                            : Color(.black)
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.white))
            .cornerRadius(100)
        }
        .cornerRadius(100)
    }
}

#Preview {
    CategoryPickerView(
        selectedCategory: .like,
        onCategorySelected: { _ in }
    )
    .padding()
}
