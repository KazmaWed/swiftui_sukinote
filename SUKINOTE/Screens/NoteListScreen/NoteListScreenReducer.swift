//
//  NoteListScreenReducer.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/31.
//

import ComposableArchitecture
import Foundation

@Reducer
struct NoteListScreenReducer {
    @ObservableState
    struct State: Equatable {
        var notes: [Note] = []
        var filterCategory: NoteCategory? = nil  // nil means "All"
        var editNote: Note?
    }

    enum Action {
        case onAppear
        case notesLoaded([Note])
        case addNoteButtonTapped
        case categorySelected(NoteCategory?)  // nil means "All"
        case noteTapped(Note)
        case editNoteTapped(Note)
        case deleteNoteTapped(Note)
        case saveNote(Note)
        case dismissEditView
    }

    @Dependency(\.noteStore) var noteStore

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case let .notesLoaded(notes):
                state.notes = notes
                return .none

            case .addNoteButtonTapped:
                // Create a placeholder note with the current filter category (or .like if "All" is selected)
                state.editNote = Note(
                    category: state.filterCategory ?? .like,
                    title: "",
                    content: ""
                )
                return .none

            case let .categorySelected(category):
                state.filterCategory = category
                return .none

            case let .noteTapped(note):
                state.editNote = note
                return .none

            case let .editNoteTapped(note):
                state.editNote = note
                return .none

            case let .deleteNoteTapped(note):
                return .run { send in
                    try await noteStore.deleteNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case let .saveNote(note):
                state.filterCategory = note.category
                state.editNote = nil
                return .run { send in
                    try await noteStore.saveNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case .dismissEditView:
                state.editNote = nil
                return .none
            }
        }
    }
}

