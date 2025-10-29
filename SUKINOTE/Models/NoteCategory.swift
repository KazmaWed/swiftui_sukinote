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
            return "スキ"
        case .dislike:
            return "キライ"
        case .anniversary:
            return "記念日"
        case .family:
            return "家族"
        case .hobby:
            return "趣味"
        case .school:
            return "学校"
        case .work:
            return "仕事"
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
