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

    func addNote() {
        showEditView = true
        print("addNote()")
//        notes.append(
//            LikeNote(
//                title: "New note",
//                content: "Something notable here."
//            )
//        )
    }
    
    func editNoteCallback(_ note: any NoteProtocol) {
        notes.append(note)
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
                    }
                }
            }
            .toolbar {
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button(
                        action: addNote,
                    ) {
                        Image(systemName: "scribble")
                            .padding()
                    }
                }
            }
            .navigationDestination(
                isPresented: $showEditView
            ) {
                EditView { newNote in
                    editNoteCallback(newNote)
                }
            }
        }
    }
}

#Preview {
    NoteListView()
}
