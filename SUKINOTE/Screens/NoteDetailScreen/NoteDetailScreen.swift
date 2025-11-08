//
//  NoteDetailScreen.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/08.
//

import SwiftUI

struct NoteDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    let note: Note
    var onEdit: () -> Void  // Callback to switch to edit mode

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
                .padding(.horizontal)
                .padding(.top)
            
            Spacer().frame(height: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                categorySection
                Divider()
                contentSection
                if note.category == .anniversary {
                    Divider()
                    anniversarySection
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Spacer()
            
            closeButton
                .padding(.bottom)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var headerBar: some View {
        ZStack {
            // Centered title
            Text("Note Details")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            // Trailing edit button
            HStack {
                Spacer()
                Button(
                    action: { onEdit() }
                ) {
                    Text("Edit")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Category")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                Image(systemName: note.category.iconFilled)
                    .foregroundColor(Color(note.category.highlightUIColor))
                    .imageScale(.medium)
                Text(note.category.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(note.title.isEmpty ? "Empty" : note.title)
                    .font(.body)
                    .foregroundColor(
                        note.title.isEmpty
                            ? Color(uiColor: .placeholderText) : .primary
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Note")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(note.content.isEmpty ? "Empty" : note.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .foregroundColor(
                        note.content.isEmpty
                            ? Color(uiColor: .placeholderText) : .primary
                    )
            }
        }
    }

    @ViewBuilder
    private var anniversarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Anniversary")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(
                    note.anniversaryDate?.formatted(date: .long, time: .omitted)
                        ?? ""
                )
                .font(.body)
            }

            if let isAnnual = note.isAnnual {
                HStack {
                    Text("Annual")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(isAnnual ? "Yes" : "No")
                        .font(.body)
                }
            }
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(
            action: { dismiss() }
        ) {
            Image(systemName: "xmark")
                .imageScale(.medium)
                .accessibilityLabel("Close")
        }
        .buttonStyle(.plain)
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    NoteDetailScreen(
        note: Note(
            category: .like,
            title: "Sample Note",
            content: "This is a sample note content."
        ),
        onEdit: {}
    )
}
