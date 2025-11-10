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
    enum SheetType: Equatable, Identifiable {
        case detail(Note)
        case edit(Note?)
        case sort
        case settings

        var id: String {
            switch self {
            case .detail(let note):
                return "detail-\(note.id)"
            case .edit(let note):
                return "edit-\(note?.id.uuidString ?? "new")"
            case .sort:
                return "sort"
            case .settings:
                return "settings"
            }
        }
    }

    @ObservableState
    struct State: Equatable {
        var notes: [Note] = []
        var filterCategory: NoteCategory? = nil  // nil means "All"
        var isScrolling: Bool = false  // Category picker scroll state
        var sortType: NoteSortType = .category
        var sortOrder: SortOrder = .ascending
        var presentedSheet: SheetType? = nil
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
        case dismissSheet
        case scrollBegin
        case scrollEnd
        case sortButtonTapped
        case sortTypeChanged(NoteSortType)
        case sortOrderChanged(SortOrder)
        case settingsButtonTapped
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
                state.presentedSheet = .edit(nil)
                return .none

            case let .categorySelected(category):
                state.filterCategory = category
                return .none

            case let .noteTapped(note):
                state.presentedSheet = .detail(note)
                return .none

            case let .editNoteTapped(note):
                state.presentedSheet = .edit(note)
                return .none

            case let .deleteNoteTapped(note):
                return .run { send in
                    try await noteStore.deleteNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case let .saveNote(note):
                state.filterCategory = note.category
                state.presentedSheet = nil
                return .run { send in
                    try await noteStore.saveNote(note)
                    let notes = try await noteStore.fetchNotes()
                    await send(.notesLoaded(notes))
                }

            case .dismissSheet:
                state.presentedSheet = nil
                return .none

            case .scrollBegin:
                state.isScrolling = true
                return .none

            case .scrollEnd:
                state.isScrolling = false
                return .none

            case .sortButtonTapped:
                state.presentedSheet = .sort
                return .none

            case let .sortTypeChanged(sortType):
                state.sortType = sortType

                // Automatically switch category filter based on sort type
                switch sortType {
                case .category:
                    // For category sort, show all categories
                    state.filterCategory = nil
                case .anniversaryDate:
                    // For anniversary date sort, show only anniversary category
                    state.filterCategory = .anniversary
                case .createdDate, .title:
                    // For other sort types, keep current filter
                    break
                }

                return .none

            case let .sortOrderChanged(sortOrder):
                state.sortOrder = sortOrder
                return .none

            case .settingsButtonTapped:
                state.presentedSheet = .settings
                return .none
            }
        }
    }
}

