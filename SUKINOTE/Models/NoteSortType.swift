//
//  NoteSortType.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import Foundation

enum NoteSortType: String, CaseIterable, Codable, Sendable {
    case category = "category"
    case createdDate = "createdDate"
    case title = "title"
    case anniversaryDate = "anniversaryDate"

    var displayName: String {
        switch self {
        case .category:
            return "Category"
        case .createdDate:
            return "Created Date"
        case .title:
            return "Title"
        case .anniversaryDate:
            return "Anniversary Date"
        }
    }

    var icon: String {
        switch self {
        case .category:
            return "folder"
        case .createdDate:
            return "calendar"
        case .title:
            return "textformat"
        case .anniversaryDate:
            return "birthday.cake"
        }
    }
}

enum SortOrder: String, Codable, Sendable {
    case ascending = "ascending"
    case descending = "descending"

    var displayName: String {
        switch self {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        }
    }

    var icon: String {
        switch self {
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        }
    }
}
