import SwiftUI

struct NoteListView: View {
    @Bindable var model: NoteListModel
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
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                NoteListContent(
                    notes: model.filteredNotes,
                    onNoteTap: { note in
                        model.noteTapped(note)
                    },
                    onNoteEdit: { note in
                        model.editNoteTapped(note)
                    },
                    onNoteDelete: { note in
                        Task { await model.deleteNote(note) }
                    },
                    bottomPadding: fabSize.height + bottomSafeArea
                )
                .animation(
                    .easeInOut(duration: animationDuration),
                    value: model.filterCategory
                )
                .task {
                    await model.onAppear()
                }
                .navigationTitle("Title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            model.personSelectorButtonTapped()
                        }) {
                            Image(systemName: "person")
                                .imageScale(.medium)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            model.settingsButtonTapped()
                        }) {
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    bottomOverlay
                }
                .sheet(item: $model.presentedSheet) { _ in
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
            if !model.isScrolling {
                fabButtons
            }
            
            categoryPickerWithSpacers
        }
        .padding()
        .animation(
            .spring(response: animationDuration),
            value: model.isScrolling
        )
    }
    
    private var fabButtons: some View {
        HStack {
            CircularButton(
                systemImage: "arrow.up.arrow.down",
                action: {
                    model.sortButtonTapped()
                },
                onSizeChanged: { size in
                    fabSize = size
                }
            )

            Spacer()

            CircularButton(
                systemImage: "plus",
                action: {
                    model.addNoteButtonTapped()
                }
            )
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var categoryPickerWithSpacers: some View {
        HStack(spacing: 4) {
            if !model.isScrolling {
                Spacer()
                    .frame(width: fabSize.width)
                    .transition(.opacity.combined(with: .scale))
            }

            CategoryPickerView(
                selectedCategory: model.filterCategory,
                onCategorySelected: { category in
                    model.filterCategory = category
                },
                animationDuration: animationDuration,
                highlightAnimationDuration: highlightAnimationDuration,
                compactWidth: compactDialWidth,
                onScrollBegin: {
                    model.isScrolling = true
                },
                onScrollEnd: {
                    model.isScrolling = false
                },
                onCenteredItemChanged: { category in
                    model.filterCategory = category
                }
            )
            .elevatedShadow()
            .frame(maxWidth: model.isScrolling ? .infinity : nil)

            if !model.isScrolling {
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
        switch model.presentedSheet {
        case .detail(let note):
            NoteDetailView(note: note) {
                model.editNoteTapped(note)
            }
        case .edit(let note):
            NoteEditView(
                noteToEdit: note,
                defaultCategory: model.filterCategory
            ) { newNote in
                Task { await model.saveNote(newNote) }
            }
        case .sort:
            NoteSortSheet(
                selectedSortType: $model.sortType,
                selectedSortOrder: $model.sortOrder
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
        model: NoteListModel(
            notes: MockData.sampleNotes,
            filterCategory: nil,  // "All" selected by default
            noteStore: .preview,
            analytics: .noop
        )
    )
}
