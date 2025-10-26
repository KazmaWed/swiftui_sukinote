//
//  EditView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

struct EditView: View {
    @State private var category: NoteCategory = .like
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var anniversaryRepeat: Bool = false

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
            if (category == .anniversary) {
                Group {
                    Spacer().frame(height: 16)
                    DatePicker(
                        "記念日",
                        selection: .constant(Date()),
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
                action: {}
            ) {
                Text("Add")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.glass)
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
    EditView()
}
