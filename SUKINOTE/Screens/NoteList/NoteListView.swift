//
//  NoteListView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import ComposableArchitecture
import SwiftUI

struct NoteListView: View {
    @Bindable var store: StoreOf<NoteListFeature>
    @State private var fabSize: CGSize = .zero
    @State private var screenWidth: CGFloat = 0
    @State private var bottomSafeArea: CGFloat = 0

    // MARK: - Layout Constants
    private let animationDuration: Double = 0.3
    private let highlightAnimationDuration: Double = 0.1
    private let horizontalPadding: CGFloat = 12
    private let spacingBetweenFABAndDial: CGFloat = 8
    
    private var compactDialWidth: CGFloat {
        max(
            0,
            screenWidth - (fabSize.width * 2) - (horizontalPadding * 2)
                - (spacingBetweenFABAndDial * 2)
        )
    }
    
    private var filteredNotes: [Note] {
        let filtered: [Note]
        if let category = store.filterCategory {
            filtered = store.notes.filter { $0.category == category }
        } else {
            filtered = store.notes
        }
        return filtered.sorted(by: store.sortType, order: store.sortOrder)
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                NoteListContent(
                    notes: filteredNotes,
                    onNoteTap: { note in
                        store.send(.noteTapped(note))
                    },
                    onNoteEdit: { note in
                        store.send(.editNoteTapped(note))
                    },
                    onNoteDelete: { note in
                        store.send(.deleteNoteTapped(note))
                    },
                    bottomPadding: fabSize.height + bottomSafeArea
                )
                .animation(
                    .easeInOut(duration: animationDuration),
                    value: store.filterCategory
                )
                .onAppear {
                    store.send(.onAppear)
                }
                .navigationTitle("Title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            store.send(.personSelectorButtonTapped)
                        }) {
                            Image(systemName: "person")
                                .imageScale(.medium)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            store.send(.settingsButtonTapped)
                        }) {
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    bottomOverlay
                }
                .sheet(item: Binding(
                    get: { store.presentedSheet },
                    set: { newValue in
                        if newValue == nil {
                            store.send(.dismissSheet)
                        }
                    }
                )) { _ in
                    presentedSheetView
                }
                .onAppear {
                    screenWidth = geometry.size.width
                    bottomSafeArea = geometry.safeAreaInsets.bottom
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    screenWidth = newWidth
                }
                .onChange(of: geometry.safeAreaInsets.bottom) { _, newBottom in
                    bottomSafeArea = newBottom
                }
            }
        }
    }
    
    // MARK: - Bottom Overlay (FABs + Category Picker)
    private var bottomOverlay: some View {
        ZStack {
            if !store.isScrolling {
                fabButtons
            }
            
            categoryPickerWithSpacers
        }
        .padding()
        .animation(
            .spring(response: animationDuration),
            value: store.isScrolling
        )
    }
    
    private var fabButtons: some View {
        HStack {
            CircularButton(
                systemImage: "arrow.up.arrow.down",
                action: {
                    store.send(.sortButtonTapped)
                },
                onSizeChanged: { size in
                    fabSize = size
                }
            )

            Spacer()

            CircularButton(
                systemImage: "plus",
                action: {
                    store.send(.addNoteButtonTapped)
                }
            )
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var categoryPickerWithSpacers: some View {
        HStack(spacing: 4) {
            if !store.isScrolling {
                Spacer()
                    .frame(width: fabSize.width)
                    .transition(.opacity.combined(with: .scale))
            }

            CategoryPickerView(
                selectedCategory: store.filterCategory,
                onCategorySelected: { category in
                    store.send(.categorySelected(category))
                },
                animationDuration: animationDuration,
                highlightAnimationDuration: highlightAnimationDuration,
                compactWidth: compactDialWidth,
                onScrollBegin: {
                    store.send(.scrollBegin)
                },
                onScrollEnd: {
                    store.send(.scrollEnd)
                },
                onCenteredItemChanged: { category in
                    store.send(.categorySelected(category))
                }
            )
            .elevatedShadow()
            .frame(maxWidth: store.isScrolling ? .infinity : nil)

            if !store.isScrolling {
                Spacer()
                    .frame(width: fabSize.width)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 0)
    }
    
    // MARK: - Sheets
    @ViewBuilder
    private var presentedSheetView: some View {
        switch store.presentedSheet {
        case .detail(let note):
            NoteDetailView(note: note) {
                store.send(.editNoteTapped(note))
            }
        case .edit(let note):
            NoteEditView(
                noteToEdit: note,
                defaultCategory: store.filterCategory
            ) { newNote in
                store.send(.saveNote(newNote))
            }
        case .sort:
            NoteSortSheet(
                selectedSortType: Binding(
                    get: { store.sortType },
                    set: { store.send(.sortTypeChanged($0)) }
                ),
                selectedSortOrder: Binding(
                    get: { store.sortOrder },
                    set: { store.send(.sortOrderChanged($0)) }
                )
            )
        case .settings:
            SettingsView()
        case .personSelector:
            PersonSelectorView()
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    NoteListView(
        store: Store(
            initialState: NoteListFeature.State(
                notes: MockData.sampleNotes,
                filterCategory: nil  // "All" selected by default
            )
        ) {
            NoteListFeature()
        } withDependencies: { values in
            // Override NoteStore for previews to return the sample notes
            values.noteStore = NoteStore(
                fetchNotes: { MockData.sampleNotes },
                saveNote: { _ in },
                deleteNote: { _ in }
            )
        }
    )
}
