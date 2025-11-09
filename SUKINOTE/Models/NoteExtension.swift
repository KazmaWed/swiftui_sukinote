//
//  Note+Sorting.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import Foundation

extension Array where Element == Note {
    /// Sorts the array of notes based on the specified sort type and order
    /// - Parameters:
    ///   - sortType: The type of sorting to apply
    ///   - order: The order of sorting (ascending or descending)
    /// - Returns: A new sorted array of notes
    func sorted(by sortType: NoteSortType, order: SortOrder = .ascending) -> [Note] {
        let sortedNotes: [Note]

        switch sortType {
        case .category:
            sortedNotes = self.sorted { note1, note2 in
                // Sort by category raw value, then by created date as secondary sort
                if note1.categoryRawValue != note2.categoryRawValue {
                    return note1.categoryRawValue < note2.categoryRawValue
                }
                return note1.createdAt > note2.createdAt
            }

        case .createdDate:
            sortedNotes = self.sorted { note1, note2 in
                note1.createdAt < note2.createdAt
            }

        case .title:
            sortedNotes = self.sorted { note1, note2 in
                // Use localizedStandardCompare for natural sorting (e.g., "Note 2" before "Note 10")
                let comparison = note1.title.localizedStandardCompare(note2.title)
                if comparison != .orderedSame {
                    return comparison == .orderedAscending
                }
                // If titles are equal, sort by created date as secondary sort
                return note1.createdAt > note2.createdAt
            }

        case .anniversaryDate:
            sortedNotes = self.sorted { note1, note2 in
                // Notes with anniversary dates come first
                switch (note1.anniversaryDate, note2.anniversaryDate) {
                case (nil, nil):
                    // Both have no anniversary date, sort by created date
                    return note1.createdAt > note2.createdAt
                case (nil, .some):
                    // note2 has anniversary date, so it comes first
                    return false
                case (.some, nil):
                    // note1 has anniversary date, so it comes first
                    return true
                case let (.some(date1), .some(date2)):
                    // Both have anniversary dates, compare them
                    if date1 != date2 {
                        return date1 < date2
                    }
                    // If anniversary dates are equal, sort by created date
                    return note1.createdAt > note2.createdAt
                }
            }
        }

        // Apply sort order (reverse if descending)
        return order == .ascending ? sortedNotes : sortedNotes.reversed()
    }
}
