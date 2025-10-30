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

    @State private var scrollOffset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var visibleWidth: CGFloat = 0

    private var showLeftGradient: Bool {
        scrollOffset > 5
    }

    private var showRightGradient: Bool {
        contentWidth > visibleWidth && scrollOffset < contentWidth - visibleWidth - 5
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: true) {
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
                .background(
                    GeometryReader { contentGeo in
                        Color.clear.onAppear {
                            contentWidth = contentGeo.size.width
                        }
                    }
                )
                .background(
                    ScrollViewOffsetReader(
                        offset: $scrollOffset
                    )
                )
            }
            .onAppear {
                visibleWidth = geometry.size.width
            }
            .mask {
                HStack(spacing: 0) {
                    // Left fade gradient (only when scrolled)
                    if showLeftGradient {
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .white]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 36)
                    }

                    // Middle solid area
                    Rectangle()
                        .fill(.white)

                    // Right fade gradient (only when there's more content)
                    if showRightGradient {
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 36)
                    }
                }
            }
        }
        .frame(height: 60)
    }
}

// Helper to track scroll offset
struct ScrollViewOffsetReader: View {
    @Binding var offset: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: -proxy.frame(in: .named("scroll")).minX
                )
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    CategoryPickerView(
        selectedCategory: .like,
        onCategorySelected: { _ in }
    )
    .padding()
}
