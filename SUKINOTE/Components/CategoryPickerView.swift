//  CategoryPickerView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI
import UIKit
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI
import UIKit

struct CategoryPickerView: View {
    let selectedCategory: NoteCategory?  // nil means "All"
    let onCategorySelected: (NoteCategory?) -> Void
    var animationDuration: TimeInterval = 0.3
    var highlightAnimationDuration: TimeInterval = 0.3
    var compactEnabled: Bool = true
    var compactWidth: CGFloat = 240
    var onScrollBegin: (() -> Void)? = nil
    var onScrollEnd: (() -> Void)? = nil
    var onCenteredItemChanged: ((NoteCategory?) -> Void)? = nil  // Called when centered item changes
    var showAllOption: Bool = true  // Whether to show "All" option

    @State private var selectedIndex: Int = 0

    private var initialIndex: Int {
        if let category = selectedCategory {
            let offset = showAllOption ? 1 : 0
            return (NoteCategory.allCases.firstIndex(of: category) ?? 0) + offset
        } else { return 0 }
    }

    // Keep selectedIndex in sync with external selectedCategory changes (e.g. after Save)
    private func syncSelectedIndex() {
        let newIndex = initialIndex
        if newIndex != selectedIndex {
            selectedIndex = newIndex
        }
    }

    var body: some View {
        // Build GlassSnapDial items
        let categoryItems: [GlassSnapDialItem] = NoteCategory.allCases.map { cat in
            let base = UIImage(systemName: cat.icon) ?? UIImage()
            let filled = UIImage(systemName: cat.iconFilled)
            return GlassSnapDialItem(
                icon: base,
                label: cat.displayName,
                highlightColor: cat.highlightUIColor,
                highlightedIcon: filled
            )
        }

        let dialItems: [GlassSnapDialItem] = {
            if showAllOption {
                return [.all] + categoryItems
            } else {
                return categoryItems
            }
        }()

        GlassSnapDialView(
            items: dialItems,
            spacing: 0,
            itemSize: CGSize(width: 60, height: 50),
            font: .systemFont(ofSize: 12, weight: .semibold),
            animationDuration: animationDuration,
            hapticsEnabled: true,
            compactEnabled: compactEnabled,
            initialCompact: true,
            compactWidth: compactWidth,
            collapseDelay: 1.2,
            useButtonGlassBackground: true,
            buttonCornerRadius: 1000,
            selected: $selectedIndex,
            initialIndex: initialIndex,
            onScrollBegin: { onScrollBegin?() },
            onScrollEnd: { idx in
                let category: NoteCategory?
                if showAllOption {
                    // Index 0 is "All" (nil), indices 1+ are NoteCategory items
                    category = idx == 0 ? nil : NoteCategory.allCases[idx - 1]
                } else {
                    // All indices are NoteCategory items
                    category = NoteCategory.allCases[idx]
                }
                onCategorySelected(category)
                onScrollEnd?()
            },
            onTap: { idx in
                let category: NoteCategory?
                if showAllOption {
                    // Index 0 is "All" (nil), indices 1+ are NoteCategory items
                    category = idx == 0 ? nil : NoteCategory.allCases[idx - 1]
                } else {
                    // All indices are NoteCategory items
                    category = NoteCategory.allCases[idx]
                }
                onCategorySelected(category)
            },
            onCenteredItemChanged: { idx in
                let category: NoteCategory?
                if showAllOption {
                    // Index 0 is "All" (nil), indices 1+ are NoteCategory items
                    category = idx == 0 ? nil : NoteCategory.allCases[idx - 1]
                } else {
                    // All indices are NoteCategory items
                    category = NoteCategory.allCases[idx]
                }
                onCenteredItemChanged?(category)
            }
        )
        .frame(height: 60)
        .onChange(of: selectedCategory) { _, _ in
            // When external selection changes, adjust dial position
            syncSelectedIndex()
        }
        .onAppear { syncSelectedIndex() }
    }
}

#Preview {
    CategoryPickerView(
        selectedCategory: nil,  // "All" selected
        onCategorySelected: { _ in }
    )
    .padding()
}
