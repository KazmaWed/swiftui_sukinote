//
//  Note.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import Foundation

struct Note: Equatable, Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    var category: NoteCategory
    var title: String
    var content: String
    // Anniversary-specific fields (nil for other categories)
    var anniversaryDate: Date?
    var isAnnual: Bool?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date.now,
        category: NoteCategory,
        title: String,
        content: String,
        anniversaryDate: Date? = nil,
        isAnnual: Bool? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
        self.anniversaryDate = anniversaryDate
        self.isAnnual = isAnnual
    }
}

