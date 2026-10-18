import Foundation
import Observation
import PhotosUI
import SwiftUI

@Observable
final class NoteEditModel {
    var category: NoteCategory
    var title: String
    var content: String
    var anniversaryRepeat: Bool
    var date: Date
    var images: [Data]
    var importedFileURL: URL? = nil

    @ObservationIgnored private let noteToEdit: Note?

    init(noteToEdit: Note? = nil, defaultCategory: NoteCategory? = nil) {
        self.noteToEdit = noteToEdit
        category = noteToEdit?.category ?? defaultCategory ?? .like
        title = noteToEdit?.title ?? ""
        content = noteToEdit?.content ?? ""
        images = noteToEdit?.images ?? []

        // For anniversary notes, also get the date
        if let note = noteToEdit, note.category == .anniversary {
            date = note.anniversaryDate ?? Date()
            anniversaryRepeat = note.isAnnual ?? false
        } else {
            date = Date()
            anniversaryRepeat = false
        }
    }

    var isEditing: Bool {
        noteToEdit != nil
    }

    func makeNote() -> Note {
        if let existingNote = noteToEdit {
            // Edit mode: use existing ID
            return Note(
                id: existingNote.id,
                createdAt: existingNote.createdAt,
                category: category,
                title: title,
                content: content,
                anniversaryDate: category == .anniversary ? date : nil,
                isAnnual: category == .anniversary ? anniversaryRepeat : nil,
                images: images.isEmpty ? nil : images
            )
        }
        return Note(
            category: category,
            title: title,
            content: content,
            anniversaryDate: category == .anniversary ? date : nil,
            isAnnual: category == .anniversary ? anniversaryRepeat : nil,
            images: images.isEmpty ? nil : images
        )
    }

    func addImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                images.append(data)
            }
        }
    }

    func removeImage(at index: Int) {
        images.remove(at: index)
    }

    func handleFileImport(_ result: Result<URL, Error>) {
        do {
            importedFileURL = try result.get()
        } catch {
            print("Failed to import file: \(error)")
        }
    }
}
