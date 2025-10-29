//
//  NoteCategory.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

enum NoteCategory: String, Codable, CaseIterable {
    case like, dislike, anniversary, family, hobby, school, work

    var displayName: String {
        switch self {
        case .like:
            return "Like"
        case .dislike:
            return "Dislike"
        case .anniversary:
            return "Anniv."
        case .family:
            return "Family"
        case .hobby:
            return "Hobby"
        case .school:
            return "School"
        case .work:
            return "Work"
        }
    }

    var icon: String {
        switch self {
        case .like:
            return "heart"
        case .dislike:
            return "hand.thumbsdown"
        case .anniversary:
            return "calendar"
        case .family:
            return "person.2"
        case .hobby:
            return "pencil"
        case .school:
            return "book"
        case .work:
            return "briefcase"
        }
    }
}
