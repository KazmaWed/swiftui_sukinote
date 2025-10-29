//
//  Note.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import Foundation

protocol NoteProtocol: Identifiable {
    var id: UUID { get }
    var createdAt: Date { get }
    var category: NoteCategory { get }
    var title: String { get }
    var content: String { get }
}

struct Note {
    static func create(
        id: UUID = UUID(),
        createdAt: Date = Date.now,
        category: NoteCategory,
        title: String,
        content: String,
        anniversaryDate: Date? = nil,
        annual: Bool? = nil
    ) -> any NoteProtocol {
        switch category {
        case .like:
            return LikeNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        case .dislike:
            return DislikeNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        case .anniversary:
            return AnniversaryNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content,
                date: anniversaryDate ?? Date(),
                annual: annual ?? false
            )
        case .family:
            return FamilyNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        case .hobby:
            return HobbyNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        case .school:
            return SchoolNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        case .work:
            return WorkNote(
                id: id,
                createdAt: createdAt,
                category: category,
                title: title,
                content: content
            )
        }
    }
}

struct LikeNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .like,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}

struct DislikeNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .dislike,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}

struct AnniversaryNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String
    var date: Date
    var annual: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .anniversary,
        title: String,
        content: String,
        date: Date,
        annual: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
        self.date = date
        self.annual = annual
    }
}

struct FamilyNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .family,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}

struct HobbyNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .hobby,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}

struct SchoolNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .school,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}

struct WorkNote: NoteProtocol, Codable {
    let id: UUID
    let createdAt: Date
    let category: NoteCategory
    var title: String
    var content: String
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .work,
        title: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
    }
}
