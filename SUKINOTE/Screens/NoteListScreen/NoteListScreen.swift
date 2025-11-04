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
                HStack {
                    CategoryPickerView(
                        selectedCategory: store.filterCategory,
                        onCategorySelected: { category in
                            store.send(.categorySelected(category))
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
                    Spacer().frame(width: 12)
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
                }.padding()
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
