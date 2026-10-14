import Foundation
import Observation

@Observable
final class NoteListModel {
    enum SheetType: Equatable, Identifiable {
        case detail(Note)
        case edit(Note?)
        case sort
        case settings
        case personSelector

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
            case .personSelector:
                return "personSelector"
            }
        }
    }

    var notes: [Note]
    var filterCategory: NoteCategory?  // nil means "All"
    var isScrolling: Bool = false  // Category picker scroll state
    var presentedSheet: SheetType? = nil

    var sortType: NoteSortType = .category {
        didSet {
            // Automatically switch category filter based on sort type
            switch sortType {
            case .category:
                // For category sort, show all categories
                filterCategory = nil
            case .anniversaryDate:
                // For anniversary date sort, show only anniversary category
                filterCategory = .anniversary
            case .createdDate, .title:
                // For other sort types, keep current filter
                break
            }
        }
    }
    var sortOrder: SortOrder = .ascending

    @ObservationIgnored private let noteStore: NoteStore
    @ObservationIgnored private let analytics: AnalyticsClient

    init(
        notes: [Note] = [],
        filterCategory: NoteCategory? = nil,
        noteStore: NoteStore,
        analytics: AnalyticsClient = .live
    ) {
        self.notes = notes
        self.filterCategory = filterCategory
        self.noteStore = noteStore
        self.analytics = analytics
    }

    var filteredNotes: [Note] {
        let filtered: [Note]
        if let category = filterCategory {
            filtered = notes.filter { $0.category == category }
        } else {
            filtered = notes
        }
        return filtered.sorted(by: sortType, order: sortOrder)
    }

    // MARK: - Data

    func onAppear() async {
        await reloadNotes()
    }

    func deleteNote(_ note: Note) async {
        do {
            try await noteStore.deleteNote(note)
        } catch {
            print("Failed to delete note: \(error)")
        }
        await reloadNotes()
    }

    func saveNote(_ note: Note) async {
        analytics.logSaveNote(note.toAnalyticsParams())
        filterCategory = note.category
        presentedSheet = nil
        do {
            try await noteStore.saveNote(note)
        } catch {
            print("Failed to save note: \(error)")
        }
        await reloadNotes()
    }

    private func reloadNotes() async {
        do {
            notes = try await noteStore.fetchNotes()
        } catch {
            print("Failed to fetch notes: \(error)")
        }
    }

    // MARK: - Sheets

    func addNoteButtonTapped() {
        presentedSheet = .edit(nil)
    }

    func noteTapped(_ note: Note) {
        presentedSheet = .detail(note)
    }

    func editNoteTapped(_ note: Note) {
        presentedSheet = .edit(note)
    }

    func sortButtonTapped() {
        presentedSheet = .sort
    }

    func settingsButtonTapped() {
        presentedSheet = .settings
    }

    func personSelectorButtonTapped() {
        presentedSheet = .personSelector
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
