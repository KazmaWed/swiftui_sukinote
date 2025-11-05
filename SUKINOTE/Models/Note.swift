//
//  Note.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import Foundation
import SwiftData

@Model
final class Note: Identifiable, @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var categoryRawValue: String
    var title: String
    var content: String
    var anniversaryDate: Date?
    var isAnnual: Bool?

    var category: NoteCategory {
        get { NoteCategory(rawValue: categoryRawValue) ?? .like }
        set { categoryRawValue = newValue.rawValue }
    }

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
        self.categoryRawValue = category.rawValue
        self.title = title
        self.content = content
        self.anniversaryDate = anniversaryDate
        self.isAnnual = isAnnual
    }
}

