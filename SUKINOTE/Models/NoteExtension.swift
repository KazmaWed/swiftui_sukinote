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
            // For category sort, order affects only the category sequence, not within-category sorting
            let isAscending = (order == .ascending)
            sortedNotes = self.sorted { note1, note2 in
                let category1Order = note1.category.sortOrder
                let category2Order = note2.category.sortOrder

                // Compare categories based on sort order
                if category1Order != category2Order {
                    return isAscending
                        ? category1Order < category2Order
                        : category1Order > category2Order
                }

                // Within same category, oldest notes come first (regardless of order)
                return note1.createdAt < note2.createdAt
            }
            // Don't apply order reversal for category sort - it's already handled above
            return sortedNotes

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
                // If titles are equal, sort by created date (oldest first) as secondary sort
                return note1.createdAt < note2.createdAt
            }

        case .anniversaryDate:
            // Anniversary notes are sorted by anniversaryDate based on order
            // Other category notes are sorted by category order (like category ascending)
            let isAscending = (order == .ascending)
            sortedNotes = self.sorted { note1, note2 in
                let isAnniversary1 = note1.category == .anniversary
                let isAnniversary2 = note2.category == .anniversary

                // Anniversary category notes always come first
                if isAnniversary1 && !isAnniversary2 {
                    return true
                } else if !isAnniversary1 && isAnniversary2 {
                    return false
                }

                // Both are anniversary category
                if isAnniversary1 && isAnniversary2 {
                    switch (note1.anniversaryDate, note2.anniversaryDate) {
                    case (nil, nil):
                        // Both have no anniversary date, sort by created date (oldest first)
                        return note1.createdAt < note2.createdAt
                    case (nil, .some):
                        // note2 has anniversary date, so it comes first
                        return false
                    case (.some, nil):
                        // note1 has anniversary date, so it comes first
                        return true
                    case let (.some(date1), .some(date2)):
                        // Both have anniversary dates, compare them based on order
                        if date1 != date2 {
                            return isAscending ? date1 < date2 : date1 > date2
                        }
                        // If anniversary dates are equal, sort by created date (oldest first)
                        return note1.createdAt < note2.createdAt
                    }
                }

                // Both are non-anniversary categories - sort by category order
                let category1Order = note1.category.sortOrder
                let category2Order = note2.category.sortOrder
                if category1Order != category2Order {
                    return category1Order < category2Order
                }

                // Within same category, oldest notes come first
                return note1.createdAt < note2.createdAt
            }
            // Don't apply order reversal - it's already handled above
            return sortedNotes
        }

        // Apply sort order (reverse if descending)
        return order == .ascending ? sortedNotes : sortedNotes.reversed()
    }
}
