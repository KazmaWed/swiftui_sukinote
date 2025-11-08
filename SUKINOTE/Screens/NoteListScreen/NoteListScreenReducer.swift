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
        var selectedNote: Note?  // For detail/edit view
        var isEditingNote: Bool = false  // true = edit mode, false = detail mode
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
        case dismissNoteView
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
                // No state changes needed here; the view controls sheet presentation.
                return .none

            case let .categorySelected(category):
                state.filterCategory = category
                return .none

            case let .noteTapped(note):
                state.selectedNote = note
                state.isEditingNote = false
                return .none

            case let .editNoteTapped(note):
                state.selectedNote = note
                state.isEditingNote = true
                return .none

            case let .deleteNoteTapped(note):
                return .run { send in
                    try await noteStore.deleteNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case let .saveNote(note):
                state.filterCategory = note.category
                state.selectedNote = nil
                state.isEditingNote = false
                return .run { send in
                    try await noteStore.saveNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case .dismissNoteView:
                state.selectedNote = nil
                state.isEditingNote = false
                return .none
            }
        }
    }
}

