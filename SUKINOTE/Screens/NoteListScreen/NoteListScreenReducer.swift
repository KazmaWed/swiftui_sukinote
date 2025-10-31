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
        var filterCategory: NoteCategory = .like
        var editNote: EditNoteState?
    }

    @ObservableState
    struct EditNoteState: Equatable, Identifiable {
        var id: UUID { note?.id ?? UUID() }
        var note: Note?
        var category: NoteCategory
    }

    enum Action {
        case addNoteButtonTapped
        case categorySelected(NoteCategory)
        case noteTapped(Note)
        case editNoteTapped(Note)
        case deleteNoteTapped(Note)
        case saveNote(Note)
        case dismissEditView
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addNoteButtonTapped:
                state.editNote = EditNoteState(note: nil, category: state.filterCategory)
                return .none

            case let .categorySelected(category):
                state.filterCategory = category
                return .none

            case let .noteTapped(note):
                state.editNote = EditNoteState(note: note, category: state.filterCategory)
                return .none

            case let .editNoteTapped(note):
                state.editNote = EditNoteState(note: note, category: state.filterCategory)
                return .none

            case let .deleteNoteTapped(note):
                state.notes.removeAll { $0.id == note.id }
                return .none

            case let .saveNote(note):
                if let index = state.notes.firstIndex(where: { $0.id == note.id }) {
                    // Update existing note
                    state.notes[index] = note
                } else {
                    // Add new note
                    state.notes.append(note)
                }
                state.filterCategory = note.category
                state.editNote = nil
                return .none

            case .dismissEditView:
                state.editNote = nil
                return .none
            }
        }
    }
}

