//
//  EditView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    var noteToEdit: (any NoteProtocol)?  // 編集するNote
    var defaultCategory: NoteCategory? = nil
    var onSave: (any NoteProtocol) -> Void  // Callback to save note

    @State private var category: NoteCategory = .like
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var anniversaryRepeat: Bool = false
    @State private var date: Date = Date()

    // 初期化時に既存のNoteがあればその値を使う
    init(
        noteToEdit: (any NoteProtocol)? = nil,
        defaultCategory: NoteCategory? = nil,
        onSave: @escaping (any NoteProtocol) -> Void
    ) {
        self.noteToEdit = noteToEdit
        self.onSave = onSave

        // 既存Noteがあればその値で初期化、なければデフォルト値
        _category = State(
            initialValue: noteToEdit?.category
            ?? defaultCategory
            ?? .like
        )
        _title = State(initialValue: noteToEdit?.title ?? "")
        _content = State(initialValue: noteToEdit?.content ?? "")

        // AnniversaryNoteの場合は日付も取得
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
            // 編集モード：既存のIDを使う
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
            // 新規作成モード
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
            Text("カテゴリー")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NoteCategory.allCases, id: \.self) { cat in
                        Button(
                            action: {
                                category = cat
                            }
                        ) {
                            VStack(spacing: 4) {
                                Text(cat.displayName).font(.caption)
                                Image(systemName: cat.icon).imageScale(.large)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                category == cat
                                    ? Color.accentColor
                                    : Color(.systemGray5)
                            )
                            .foregroundColor(
                                category == cat ? .white : .primary
                            )
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }

            Spacer().frame(height: 16)
            Text("タイトル")
            TextField("Empty", text: $title)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            Spacer().frame(height: 16)
            Text("メモ")
            TextField("Empty", text: $content, axis: .vertical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .lineLimit(5...)
            if category == .anniversary {
                Group {
                    Spacer().frame(height: 16)
                    DatePicker(
                        "記念日",
                        selection: .constant(date),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    Spacer().frame(height: 16)
                    Toggle(isOn: $anniversaryRepeat) {
                        Text("繰り返し")
                    }
                }
            }
            Spacer()
            Button(
                action: onSaveTapped
            ) {
                Text("保存")
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
    EditView { _ in }
}
