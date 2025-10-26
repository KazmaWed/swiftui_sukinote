//
//  ContentView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var notes: [any NoteProtocol] = []

    func addNote() {
        notes.append(
            LikeNote(
                title: "New note",
                content: "Something notable here."
            )
        )
    }

    var body: some View {
        VStack {
            if notes.isEmpty{
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {},
                ) {
                    Image(systemName: "plus")
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
