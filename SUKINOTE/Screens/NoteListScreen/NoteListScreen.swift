//
//  ContentView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI

struct NoteListScreen: View {
    @State private var notes: [any NoteProtocol] = []
    @State private var showEditView = false
    @State private var filterCategory = NoteCategory.allCases.first!
    @State private var selectedNote: (any NoteProtocol)?

    init() {
        // Note: Initial list itgems for testing
        _notes = State(initialValue: [
            Note.create(
                category: .like,
                title: "たまねぎ",
                content: "サラダに入れて食べるのが大好き"
            ),
            Note.create(
                category: .anniversary,
                title: "誕生日",
                content: "サプライズは好きじゃない"
            ),
        ])
    }

    func addNote() {
        selectedNote = nil
        showEditView = true
    }

    func pickCategory(_ category: NoteCategory) {
        filterCategory = category
    }

    func editNoteCallback(_ note: any NoteProtocol) {
        selectedNote = nil
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
        filterCategory = note.category
        showEditView = false
    }

    func removeNote(_ note: any NoteProtocol) {
        notes.removeAll(where: { $0.id == note.id })
    }

    func editNote(_ note: any NoteProtocol) {
        selectedNote = note
        showEditView = true
    }

    var body: some View {
        NavigationStack {
            NotesListView(
                notes: notes,
                onNoteTap: { note in
                    selectedNote = note
                    showEditView = true
                },
                onNoteEdit: { note in
                    editNote(note)
                },
                onNoteDelete: { note in
                    removeNote(note)
                }
            )
            .overlay(alignment: .bottom) {
                HStack {
                    CategoryPickerView(
                        selectedCategory: filterCategory,
                        onCategorySelected: { category in
                            pickCategory(category)
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
                        action: addNote,
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
                isPresented: $showEditView
            ) {
                NoteEditScreen(
                    noteToEdit: selectedNote,
                    defaultCategory: filterCategory
                ) { newNote in
                    editNoteCallback(newNote)
                }
            }
        }
    }
}

#Preview {
    NoteListScreen()
}
