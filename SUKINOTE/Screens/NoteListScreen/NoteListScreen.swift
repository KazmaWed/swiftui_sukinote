//
//  ContentView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import ComposableArchitecture
import SwiftUI

struct NoteListScreen: View {
    @Bindable var store: StoreOf<NoteListScreenReducer>
    @State private var fabSize: CGSize = .zero
    @State private var screenWidth: CGFloat = 0
    
    // MARK: - Layout Constants
    private let animationDuration: Double = 0.3
    private let highlightAnimationDuration: Double = 0.1
    private let bottomPadding: Double = 16
    private let horizontalPadding: CGFloat = 16
    private let spacingBetweenFABAndDial: CGFloat = 4
    
    private var compactDialWidth: CGFloat {
        max(
            0,
            screenWidth - (fabSize.width * 2) - (horizontalPadding * 2)
                - (spacingBetweenFABAndDial * 2)
        )
    }
    
    private var filteredNotes: [Note] {
        if let category = store.filterCategory {
            return store.notes.filter { $0.category == category }
        } else {
            return store.notes
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                NotesListView(
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
                    bottomPadding: fabSize.height + bottomPadding
                )
                .animation(
                    .easeInOut(duration: animationDuration),
                    value: store.filterCategory
                )
                .onAppear {
                    store.send(.onAppear)
                }
                .overlay(alignment: .bottom) {
                    bottomOverlay
                }
                .sheet(isPresented: detailSheetBinding) {
                    detailSheet
                }
                .sheet(isPresented: editSheetBinding) {
                    editSheet
                }
                .onAppear {
                    screenWidth = geometry.size.width
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    screenWidth = newWidth
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
                    // TODO: Implement sort functionality
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
    private var detailSheetBinding: Binding<Bool> {
        Binding(
            get: {
                store.selectedNote != nil && !store.isEditingNote
            },
            set: { isPresented in
                if !isPresented { store.send(.dismissNoteView) }
            }
        )
    }
    
    @ViewBuilder
    private var detailSheet: some View {
        if let note = store.selectedNote {
            NoteDetailScreen(note: note) {
                store.send(.editNoteTapped(note))
            }
        }
    }
    
    private var editSheetBinding: Binding<Bool> {
        Binding(
            get: {
                (store.selectedNote != nil && store.isEditingNote)
                    || store.pendingNewNote
            },
            set: { isPresented in
                if !isPresented {
                    store.send(.dismissNoteView)
                }
            }
        )
    }
    
    private var editSheet: some View {
        NoteEditScreen(
            noteToEdit: store.isEditingNote ? store.selectedNote : nil,
            defaultCategory: store.filterCategory
        ) { newNote in
            store.send(.saveNote(newNote))
        }
    }
}

#Preview {
    // Diverse sample notes from all categories with varying counts
    let sampleNotes: [Note] = [
        // like (3)
        Note(
            category: .like,
            title: "Morning Coffee Ritual",
            content: "Flat white with oat milk"
        ),
        Note(
            category: .like,
            title: "Lo-fi Jazz Sessions",
            content: "Perfect for coding"
        ),
        Note(
            category: .like,
            title: "Kyoto in Spring",
            content: "Cherry blossoms at Philosopher's Path"
        ),
        // dislike (2)
        Note(
            category: .dislike,
            title: "Humid Summer Days",
            content: "Makes me feel sluggish"
        ),
        Note(
            category: .dislike,
            title: "Overly Spicy Food",
            content: "Can't taste the flavors"
        ),
        // hobby (3)
        Note(
            category: .hobby,
            title: "Street Photography",
            content: "Candid moments in Tokyo"
        ),
        Note(
            category: .hobby,
            title: "Growing Herbs",
            content: "Basil and mint on balcony"
        ),
        Note(
            category: .hobby,
            title: "Sci-fi Novels",
            content: "Currently reading Foundation"
        ),
        // anniversary (2)
        Note(
            category: .anniversary,
            title: "Wedding Day",
            content: "2018-06-17"
        ),
        Note(
            category: .anniversary,
            title: "App Launch",
            content: "First version went live"
        ),
        // family (1)
        Note(
            category: .family,
            title: "Weekly Call with Mom",
            content: "Every Sunday at 3pm"
        ),
        // school (2)
        Note(
            category: .school,
            title: "iOS Design Patterns",
            content: "MVVM vs TCA comparison"
        ),
        Note(
            category: .school,
            title: "Algorithm Study",
            content: "Binary search trees"
        ),
        // work (4)
        Note(
            category: .work,
            title: "First Day at StartupCo",
            content: "Nervous but excited. Great team vibes"
        ),
        Note(
            category: .work,
            title: "Shipped Major Feature",
            content: "Payment system went live. Celebrated with team dinner"
        ),
        Note(
            category: .work,
            title: "Mentor's Advice",
            content: "\"Write code for humans, not machines\""
        ),
        Note(
            category: .work,
            title: "Career Pivot Decision",
            content: "Left consulting to join product team"
        ),
    ]

    return NoteListScreen(
        store: Store(
            initialState: NoteListScreenReducer.State(
                notes: sampleNotes,
                filterCategory: nil  // "All" selected by default
            )
        ) {
            NoteListScreenReducer()
        } withDependencies: { values in
            // Override NoteStore for previews to return the sample notes
            values.noteStore = NoteStore(
                fetchNotes: { sampleNotes },
                saveNote: { _ in },
                deleteNote: { _ in }
            )
        }
    )
}
