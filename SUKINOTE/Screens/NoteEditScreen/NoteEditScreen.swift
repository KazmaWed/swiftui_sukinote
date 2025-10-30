//
//  EditView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NoteEditScreen: View {
    @Environment(\.dismiss) var dismiss
    var noteToEdit: (any NoteProtocol)?
    var defaultCategory: NoteCategory? = nil
    var onSave: (any NoteProtocol) -> Void  // Callback to save note

    @State private var category: NoteCategory = .like
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var anniversaryRepeat: Bool = false
    @State private var date: Date = Date()

    init(
        noteToEdit: (any NoteProtocol)? = nil,
        defaultCategory: NoteCategory? = nil,
        onSave: @escaping (any NoteProtocol) -> Void
    ) {
        self.noteToEdit = noteToEdit
        self.onSave = onSave

        // Initialize with existing note's values if available, otherwise use default values
        _category = State(
            initialValue: noteToEdit?.category
            ?? defaultCategory
            ?? .like
        )
        _title = State(initialValue: noteToEdit?.title ?? "")
        _content = State(initialValue: noteToEdit?.content ?? "")

        // For AnniversaryNote, also get the date
        if let anniversaryNote = noteToEdit as? AnniversaryNote {
            _date = State(initialValue: anniversaryNote.date)
            _anniversaryRepeat = State(
                initialValue:
                    anniversaryNote.annual
            )
        } else {
            _date = State(initialValue: Date())
            _anniversaryRepeat = State(initialValue: false)
        }
    }

    func onSaveTapped() {
        let newNote: any NoteProtocol

        if let existingNote = noteToEdit {
            // Edit mode: use existing ID
            newNote = Note.create(
                id: existingNote.id,
                createdAt: existingNote.createdAt,
                category: category,
                title: title,
                content: content,
                anniversaryDate: date,
                annual: anniversaryRepeat
            )
        } else {
            // Create new mode
            newNote = Note.create(
                category: category,
                title: title,
                content: content,
                anniversaryDate: date,
                annual: anniversaryRepeat
            )
        }
        onSave(newNote)
        dismiss()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Category")
            CategoryPickerView(
                selectedCategory: category,
                onCategorySelected: {seledted in category = seledted}
            )
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(8)
            Spacer().frame(height: 16)
            Text("Title")
            TextField("Empty", text: $title)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            Spacer().frame(height: 16)
            Text("Note")
            TextField("Empty", text: $content, axis: .vertical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .lineLimit(5...)
            if category == .anniversary {
                Group {
                    Spacer().frame(height: 16)
                    DatePicker(
                        "Anniversary",
                        selection: .constant(date),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    Spacer().frame(height: 16)
                    Toggle(isOn: $anniversaryRepeat) {
                        Text("Annual")
                    }
                }
            }
            Spacer()
            Button(
                action: onSaveTapped
            ) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NoteEditScreen { _ in }
}
