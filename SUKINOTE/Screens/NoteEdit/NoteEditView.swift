//
//  NoteEditView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import PhotosUI
import SwiftUI

struct NoteEditView: View {
    @Environment(\.dismiss) var dismiss
    var noteToEdit: Note?
    var defaultCategory: NoteCategory? = nil
    var onSave: (Note) -> Void  // Callback to save note

    @State private var category: NoteCategory = .like
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var anniversaryRepeat: Bool = false
    @State private var date: Date = Date()
    @State private var pickerItems: [PhotosPickerItem] = []  // PhotosPicker temporary selection
    @State private var images: [Data] = []  // Actual image data for storage and display

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
        _images = State(
            initialValue: noteToEdit?.images ?? []
        )

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
                isAnnual: category == .anniversary ? anniversaryRepeat : nil,
                images: images.isEmpty ? nil : images
            )
        } else {
            // Create new mode
            newNote = Note(
                category: category,
                title: title,
                content: content,
                anniversaryDate: category == .anniversary ? date : nil,
                isAnnual: category == .anniversary ? anniversaryRepeat : nil,
                images: images.isEmpty ? nil : images
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

    @ViewBuilder
    private var imageAttachmentsSection: some View {
        let thumbnailSize = CGFloat(72)
        let cornerRadius = CGFloat(8)

        VStack(alignment: .leading, spacing: 8) {
            Text("Images")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Display selected images
                    ForEach(images.indices, id: \.self) { index in
                        if let uiImage = UIImage(data: images[index]) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: thumbnailSize,
                                        height: thumbnailSize
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: cornerRadius
                                        )
                                    )

                                Button(
                                    action: { images.remove(at: index) }
                                ) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(
                                            Color.red.clipShape(Circle())
                                        )
                                }
                                .offset(
                                    x: -cornerRadius / 2,
                                    y: cornerRadius / 2
                                )
                            }
                        }
                    }
                    // Add image button
                    PhotosPicker(
                        selection: $pickerItems,
                        matching: .images
                    ) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .background(Color(.systemBackground))
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.blue, lineWidth: 1)

                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .onChange(of: pickerItems) { oldValue, newValue in
            Task {
                for item in newValue {
                    if let data = try? await item.loadTransferable(
                        type: Data.self
                    ) {
                        images.append(data)
                    }
                }
                pickerItems.removeAll()
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
            Spacer().frame(height: 16)
            imageAttachmentsSection
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
            onCategorySelected: { _ in },
            compactEnabled: false,
            onCenteredItemChanged: { selected in
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
    NoteEditView { _ in }
}
