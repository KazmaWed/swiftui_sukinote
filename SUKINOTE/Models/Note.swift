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

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: NoteCategory = .anniversary,
        title: String,
        content: String,
        date: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
        self.date = date
    }
}
