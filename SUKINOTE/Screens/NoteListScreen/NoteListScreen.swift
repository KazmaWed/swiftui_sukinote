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
    @State private var isScrolling: Bool = false

    var body: some View {
        NavigationStack {
            NotesListView(
                notes: store.notes,
                onNoteTap: { note in
                    store.send(.noteTapped(note))
                },
                onNoteEdit: { note in
                    store.send(.editNoteTapped(note))
                },
                onNoteDelete: { note in
                    store.send(.deleteNoteTapped(note))
                }
            )
            .onAppear {
                store.send(.onAppear)
            }
            .overlay(alignment: .bottom) {
                let animationDuration: Double = 0.3
                let highlightAnimationDuration: Double = 0.1
                
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
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 4)
                            }
                            .buttonStyle(.glass)
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
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 4)
                            }
                            .buttonStyle(.glass)
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
                        }
                        .transition(.opacity.combined(with: .scale))
                    }

                    HStack(spacing: 12) {
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
                            }
                        )
                        .background(Color(.white))
                        .cornerRadius(100)
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
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
    NoteListScreen(
        store: Store(
            initialState: NoteListScreenReducer.State(
                notes: [
                    Note(
                        category: .like,
                        title: "Sample Note",
                        content: "This is a sample content"
                    )
                ],
                filterCategory: .like
            )
        ) {
            NoteListScreenReducer()
        }
    )
}
