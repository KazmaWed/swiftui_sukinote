//
//  CategoryPickerView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI
import UIKit

struct CategoryPickerView: View {
    let selectedCategory: NoteCategory
    let onCategorySelected: (NoteCategory) -> Void
    var animationDuration: TimeInterval = 0.3
    var highlightAnimationDuration: TimeInterval = 0.3
    var onScrollBegin: (() -> Void)? = nil
    var onScrollEnd: (() -> Void)? = nil

    @State private var selectedIndex: Int = 0

    private var initialIndex: Int {
        NoteCategory.allCases.firstIndex(of: selectedCategory) ?? 0
    }

    var body: some View {
        // Build GlassSnapDial items from NoteCategory
        let categories: [NoteCategory] = NoteCategory.allCases
        let dialItems: [GlassSnapDialItem] = categories.map { cat in
            let base = UIImage(systemName: cat.icon) ?? UIImage()
            let filled = UIImage(systemName: cat.iconFilled)
            return GlassSnapDialItem(
                icon: base,
                label: cat.displayName,
                highlightColor: cat.highlightUIColor,
                highlightedIcon: filled
            )
        }

        GlassSnapDialView(
            items: dialItems,
            spacing: 0,
            itemSize: CGSize(width: 60, height: 50),
            font: .systemFont(ofSize: 12, weight: .semibold),
            tintColor: UIColor.label,
            animationDuration: animationDuration,
            scrollEndDelay: 0.8,
            hapticsEnabled: true,
            compactEnabled: false,
            initialCompact: false,
            compactWidth: 240,
            collapseDelayAfterTap: 1.5,
            selected: $selectedIndex,
            initialIndex: initialIndex,
            onScrollBegin: { onScrollBegin?() },
            onScrollEnd: { idx in
                let category = NoteCategory.allCases[idx]
                onCategorySelected(category)
                onScrollEnd?()
            },
            onTap: { idx in
                let category = NoteCategory.allCases[idx]
                onCategorySelected(category)
            }
        )
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
