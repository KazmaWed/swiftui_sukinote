//
//  NoteCategory.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

enum NoteCategory: String, Codable {
    case like, dislike, anniversary
    
    var displayName: String {
        switch self {
        case .like:
            return "スキ"
        case .dislike:
            return "キライ"
        case .anniversary:
            return "記念日"
        }
    }

    var icon: String {
        switch self {
        case .like:
            return "heart.fill"
        case .dislike:
            return "hand.thumbsdown.fill"
        case .anniversary:
            return "calendar"
        }
    }
}
