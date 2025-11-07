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
    var animationDuration: TimeInterval = 0.3
    var highlightAnimationDuration: TimeInterval = 0.3
    var onScrollBegin: (() -> Void)? = nil
    var onScrollEnd: (() -> Void)? = nil

    @State private var centeredIndex: Int = 0

    private var initialIndex: Int {
        NoteCategory.allCases.firstIndex(of: selectedCategory) ?? 0
    }

    var body: some View {
        let items: [NoteCategory] = NoteCategory.allCases

        SnapDial(
            items.indices,
            spacing: 0,
            distribution: .fill,
            animationDuration: animationDuration,
            centeredIndex: $centeredIndex,
            initialIndex: initialIndex,
            onScrollBegin: {
                onScrollBegin?()
            },
            onScrollEnd: { index in
                let category = NoteCategory.allCases[index]
                onCategorySelected(category)
                onScrollEnd?()
            },
            onTap: { index in
                let category = NoteCategory.allCases[index]
                onCategorySelected(category)
            }
        ) { index in
            let category = items[index]
            let isSelected = index == centeredIndex

            VStack(spacing: 2) {
                Image(
                    systemName: isSelected
                        ? category.iconFilled
                        : category.icon
                )
                .imageScale(.medium)
                .frame(height: 24)
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(width: 60, height: 50)
            .background(
                isSelected
                    ? Color.accentColor
                    : Color.clear
            )
            .foregroundStyle(
                isSelected
                    ? Color.white
                    : Color(.black)
            )
            .cornerRadius(8)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: highlightAnimationDuration), value: centeredIndex)
        }
        .frame(height: 60)
    }
}

#Preview {
    CategoryPickerView(
        selectedCategory: .like,
        onCategorySelected: { _ in }
    )
    .padding()
}
