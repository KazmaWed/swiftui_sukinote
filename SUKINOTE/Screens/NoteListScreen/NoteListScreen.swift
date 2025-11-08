//
//  ContentView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI
import ComposableArchitecture

struct NoteListScreen: View {
    @Bindable var store: StoreOf<NoteListScreenReducer>
    @State private var fabWidth: CGFloat = 0
    @State private var fabHeight: CGFloat = 0
    @State private var isScrolling: Bool = false

    var body: some View {
        let animationDuration: Double = 0.3
        let highlightAnimationDuration: Double = 0.1
        let bottomPadding: Double = 16
        
        NavigationStack {
            NotesListView(
                notes: {
                    if let category = store.filterCategory {
                        return store.notes.filter { $0.category == category }
                    } else {
                        // "All" is selected - show all notes
                        return store.notes
                    }
                }(),
                onNoteTap: { note in
                    isScrolling = false
                    store.send(.noteTapped(note))
                },
                onNoteEdit: { note in
                    isScrolling = false
                    store.send(.editNoteTapped(note))
                },
                onNoteDelete: { note in
                    isScrolling = false
                    store.send(.deleteNoteTapped(note))
                },
                bottomPadding: fabHeight + bottomPadding
            )
            .animation(.easeInOut(duration: animationDuration), value: store.filterCategory)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isScrolling = false
                    }
            )
            .onAppear {
                store.send(.onAppear)
            }
            .overlay(alignment: .bottom) {
                
                ZStack {
                    if !isScrolling {
                        HStack {
                            Button(
                                action: {
                                    // TODO
                                }
                            ) {
                                Image(systemName: "person")
                                    .imageScale(.large)
                                    .padding(8)
                            }
                            .buttonStyle(.glass)
                            .clipShape(Circle())
                            .elevatedShadow()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            fabWidth = geometry.size.width
                                        }
                                        .onChange(of: geometry.size.width) { _, newWidth in
                                        fabWidth = newWidth
                                    }
                                }
                            )

                            Spacer()

                            Button(
                                action: {
                                    store.send(.addNoteButtonTapped)
                                }
                            ) {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .padding(8)
                            }
                            .buttonStyle(.glass)
                            .clipShape(Circle())
                            .elevatedShadow()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            fabWidth = geometry.size.width
                                            fabHeight = geometry.size.height
                                        }
                                }
                            )
                        }
                        .transition(.opacity.combined(with: .scale))
                    }

                    HStack(spacing: 4) {
                        if !isScrolling {
                            Spacer()
                                .frame(width: fabWidth)
                                .transition(.opacity.combined(with: .scale))
                        }

                        CategoryPickerView(
                            selectedCategory: store.filterCategory,
                            onCategorySelected: { category in
                                store.send(.categorySelected(category))
                            },
                            animationDuration: animationDuration,
                            highlightAnimationDuration: highlightAnimationDuration,
                            onScrollBegin: {
                                isScrolling = true
                            },
                            onScrollEnd: {
                                isScrolling = false
                            },
                            onCenteredItemChanged: { category in
                                store.send(.categorySelected(category))
                            }
                        )
                        .elevatedShadow()
                        .frame(maxWidth: isScrolling ? .infinity : nil)

                        if !isScrolling {
                            Spacer()
                                .frame(width: fabWidth)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .padding()
                .animation(.spring(response: animationDuration), value: isScrolling)
            }
            .navigationDestination(
                item: Binding(
                    get: { store.editNote },
                    set: { if $0 == nil { store.send(.dismissEditView) } }
                )
            ) { note in
                NoteEditScreen(
                    noteToEdit: note,
                    defaultCategory: store.filterCategory
                ) { newNote in
                    store.send(.saveNote(newNote))
                }
            }
        }
    }
}

#Preview {
    // Diverse sample notes from all categories with varying counts
    let sampleNotes: [Note] = [
        // like (3)
        Note(category: .like, title: "Like • Coffee", content: "Flat white"),
        Note(category: .like, title: "Like • Music", content: "Lo-fi beats"),
        Note(category: .like, title: "Like • Place", content: "Kyoto"),
        // dislike (2)
        Note(category: .dislike, title: "Dislike • Weather", content: "Humidity"),
        Note(category: .dislike, title: "Dislike • Food", content: "Too spicy"),
        // anniversary (2)
        Note(category: .anniversary, title: "Anniversary • Wedding", content: "2018-06-17"),
        Note(category: .anniversary, title: "Anniversary • Launch", content: "App v1.0"),
        // family (1)
        Note(category: .family, title: "Family • Call", content: "Mom on Sunday"),
        // hobby (3)
        Note(category: .hobby, title: "Hobby • Photography", content: "Street"),
        Note(category: .hobby, title: "Hobby • Gardening", content: "Herbs"),
        Note(category: .hobby, title: "Hobby • Reading", content: "Sci-fi"),
        // school (2)
        Note(category: .school, title: "School • Lecture", content: "iOS Patterns"),
        Note(category: .school, title: "School • Homework", content: "Algorithms"),
        // work (4)
        Note(category: .work, title: "Work • Standup", content: "10:00"),
        Note(category: .work, title: "Work • Design Review", content: "GlassSnapDial"),
        Note(category: .work, title: "Work • Code", content: "Refactor models"),
        Note(category: .work, title: "Work • Retro", content: "Friday")
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
