//
//  ContentView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI

struct NoteListView: View {
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
            VStack {
                if notes.isEmpty {
                    VStack {
                        Text("No note.")
                            .foregroundColor(.secondary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                    .background(Color(.systemGroupedBackground))
                } else {
                    List(notes, id: \.id) { note in
                        HStack(spacing: 16) {
                            Image(systemName: note.category.icon)
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .onTapGesture {
                            selectedNote = note
                            showEditView = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                removeNote(note)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                editNote(note)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    VStack {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(NoteCategory.allCases, id: \.self) {
                                    category in
                                    Button(
                                        action: { pickCategory(category) }
                                    ) {
                                        VStack(spacing: 2) {
                                            Image(systemName: category.icon)
                                                .imageScale(.large)
                                            Text(category.displayName)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal, 8)
                                    }
                                    .foregroundStyle(
                                        filterCategory == category
                                            ? Color.accentColor
                                            : Color(.black)
                                    )
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.white))
                            .cornerRadius(100)
                        }
                    }
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
                EditView(
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
    NoteListView()
}
