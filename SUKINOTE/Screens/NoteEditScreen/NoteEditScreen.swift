//
//  EditView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct NoteEditScreen: View {
    @Environment(\.dismiss) var dismiss
    var noteToEdit: Note?
    var defaultCategory: NoteCategory? = nil
    var onSave: (Note) -> Void  // Callback to save note

    @State private var category: NoteCategory = .like
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var anniversaryRepeat: Bool = false
    @State private var date: Date = Date()

    init(
        noteToEdit: Note? = nil,
        defaultCategory: NoteCategory? = nil,
        onSave: @escaping (Note) -> Void
    ) {
        self.noteToEdit = noteToEdit
        self.defaultCategory = defaultCategory
        self.onSave = onSave

        // Initialize with existing note's values if available, otherwise use default values
        _category = State(
            initialValue: noteToEdit?.category
                ?? defaultCategory
                ?? .like
        )
        _title = State(initialValue: noteToEdit?.title ?? "")
        _content = State(initialValue: noteToEdit?.content ?? "")

        // For anniversary notes, also get the date
        if let note = noteToEdit, note.category == .anniversary {
            _date = State(initialValue: note.anniversaryDate ?? Date())
            _anniversaryRepeat = State(initialValue: note.isAnnual ?? false)
        } else {
            _date = State(initialValue: Date())
            _anniversaryRepeat = State(initialValue: false)
        }
    }

    func onSaveTapped() {
        let newNote: Note

        if let existingNote = noteToEdit {
            // Edit mode: use existing ID
            newNote = Note(
                id: existingNote.id,
                createdAt: existingNote.createdAt,
                category: category,
                title: title,
                content: content,
                anniversaryDate: category == .anniversary ? date : nil,
                isAnnual: category == .anniversary ? anniversaryRepeat : nil
            )
        } else {
            // Create new mode
            newNote = Note(
                category: category,
                title: title,
                content: content,
                anniversaryDate: category == .anniversary ? date : nil,
                isAnnual: category == .anniversary ? anniversaryRepeat : nil
            )
        }
        onSave(newNote)
        dismiss()
    }

    @ViewBuilder
    private var anniversarySection: some View {
        Group {
            Spacer().frame(height: 16)
            DatePicker(
                "Anniversary",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            Spacer().frame(height: 16)
            Toggle(isOn: $anniversaryRepeat) {
                Text("Annual")
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            headerBar
            Spacer().frame(height: 12)
            categorySection
            Spacer().frame(height: 16)
            textFieldsSection
            if category == .anniversary {
                anniversarySection
            }
            Spacer()
            saveButton
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var headerBar: some View {
        ZStack {
            // Centered title
            Text(noteToEdit == nil ? "New Note" : "Edit Note")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            // Trailing close button; empty spacer on the left is implicitly handled by ZStack
            HStack {
                Spacer()
                Button(
                    action: { dismiss() }
                ) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .accessibilityLabel("Cancel")
                }
                .buttonStyle(.plain)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var categorySection: some View {
        Text("Category")
        CategoryPickerView(
            selectedCategory: category,
            onCategorySelected: { selected in
                if let selected = selected {
                    category = selected
                }
            },
            showAllOption: false
        )
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(8)
    }

    @ViewBuilder
    private var textFieldsSection: some View {
        Text("Title")
        TextField("Empty", text: $title)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        Spacer().frame(height: 16)
        Text("Note")
        ZStack(alignment: .topLeading) {
            if content.isEmpty {
                Text("Empty")
                    .foregroundColor(Color(uiColor: .placeholderText))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $content)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
        }
        .padding(4)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }

    @ViewBuilder
    private var saveButton: some View {
        Button(
            action: onSaveTapped
        ) {
            Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderless)
        .frame(height: 48)
    }
}

#Preview {
    NoteEditScreen { _ in }
}
