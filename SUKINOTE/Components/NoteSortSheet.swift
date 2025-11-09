//
//  NoteSortSheet.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import SwiftUI

struct NoteSortSheet: View {
    @Binding var selectedSortType: NoteSortType
    @Binding var selectedSortOrder: SortOrder
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Sort Type Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sort By")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(NoteSortType.allCases, id: \.self) { sortType in
                            SortTypeRow(
                                sortType: sortType,
                                isSelected: selectedSortType == sortType
                            ) {
                                selectedSortType = sortType
                            }

                            if sortType != NoteSortType.allCases.last {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                // Sort Order Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Picker("Sort Order", selection: $selectedSortOrder) {
                        ForEach([SortOrder.ascending, SortOrder.descending], id: \.self) { order in
                            Text(order.displayName)
                                .tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Sort Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct SortTypeRow: View {
    let sortType: NoteSortType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: sortType.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .primary)
                    .frame(width: 24)

                Text(sortType.displayName)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .imageScale(.large)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Sort Sheet") {
    @Previewable @State var sortType: NoteSortType = .createdDate
    @Previewable @State var sortOrder: SortOrder = .ascending

    NoteSortSheet(
        selectedSortType: $sortType,
        selectedSortOrder: $sortOrder
    )
}
