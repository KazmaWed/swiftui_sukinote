import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct NoteEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var model: NoteEditModel
    var onSave: (Note) -> Void  // Callback to save note
    var onDelete: (() -> Void)?
    var showsImportButton: Bool

    @State private var pickerItems: [PhotosPickerItem] = []  // PhotosPicker temporary selection
    @State private var isFileImporterPresented: Bool = false

    private static let importableContentTypes: [UTType] = [
        .plainText,
        UTType("net.daringfireball.markdown") ?? .plainText,
        .image,
    ]

    init(
        noteToEdit: Note? = nil,
        defaultCategory: NoteCategory? = nil,
        onSave: @escaping (Note) -> Void,
        onDelete: (() -> Void)? = nil,
        showsImportButton: Bool = true
    ) {
        _model = State(initialValue: NoteEditModel(noteToEdit: noteToEdit, defaultCategory: defaultCategory))
        self.onSave = onSave
        self.onDelete = onDelete
        self.showsImportButton = showsImportButton
    }

    func onSaveTapped() {
        onSave(model.makeNote())
        dismiss()
    }

    @ViewBuilder
    private var anniversarySection: some View {
        Group {
            Spacer().frame(height: 16)
            DatePicker(
                "Anniversary",
                selection: $model.date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            Spacer().frame(height: 16)
            Toggle(isOn: $model.anniversaryRepeat) {
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
                    ForEach(model.images.indices, id: \.self) { index in
                        if let uiImage = UIImage(data: model.images[index]) {
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
                                    action: { model.removeImage(at: index) }
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
                await model.addImages(from: newValue)
                pickerItems.removeAll()
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                headerBar
                Spacer().frame(height: 12)
                categorySection
                Spacer().frame(height: 16)
                textFieldsSection
                if model.category == .anniversary {
                    anniversarySection
                }
                Spacer().frame(height: 16)
                imageAttachmentsSection
                Spacer()
                saveButton
                if onDelete != nil {
                    deleteButton
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding()
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: Self.importableContentTypes
            ) { result in
                model.handleFileImport(result)
            }
            .navigationDestination(item: $model.importedFileURL) { url in
                FileAnalyzeView(fileURL: url, onFinish: { dismiss() })
            }
        }
    }

    @ViewBuilder
    private var headerBar: some View {
        ZStack {
            // Centered title
            Text(model.isEditing ? "Edit Note" : "New Note")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            // Leading import button, trailing close button
            HStack {
                if showsImportButton {
                    Button(
                        action: { isFileImporterPresented = true }
                    ) {
                        Text("Import")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.borderless)
                }
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
            selectedCategory: model.category,
            onCategorySelected: { _ in },
            compactEnabled: false,
            onCenteredItemChanged: { selected in
                if let selected = selected {
                    model.category = selected
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
        TextField("Empty", text: $model.title)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        Spacer().frame(height: 16)
        Text("Note")
        ZStack(alignment: .topLeading) {
            if model.content.isEmpty {
                Text("Empty")
                    .foregroundColor(Color(uiColor: .placeholderText))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $model.content)
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

    @ViewBuilder
    private var deleteButton: some View {
        Button(role: .destructive) {
            onDelete?()
            dismiss()
        } label: {
            Text("Delete")
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
