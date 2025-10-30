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
        case  .anniversary:
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
            return "hand.thumbsup"
        case .dislike:
            return "heart.slash"
        case .anniversary:
            return "birthday.cake"
        case .family:
            return "person.2"
        case .hobby:
            return "camera"
        case .school:
            return "graduationcap"
        case .work:
            return "briefcase"
        }
    }
    
    var iconFilled: String {
        switch self {
        case .like:
            return "hand.thumbsup.fill"
        case .dislike:
            return "heart.slash.fill"
        case .anniversary:
            return "birthday.cake.fill"
        case .family:
            return "person.2.fill"
        case .hobby:
            return "camera.fill"
        case .school:
            return "graduationcap.fill"
        case .work:
            return "briefcase.fill"
        }
    }
}
