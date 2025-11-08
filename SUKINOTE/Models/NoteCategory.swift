//
//  NoteCategory.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/26.
//

import SwiftUI

enum NoteCategory: String, Codable, CaseIterable, Sendable {
    // Explicit raw values to stabilize Codable representation even if case names change
    case like = "like"
    case dislike = "dislike"
    case hobby = "hobby"
    case anniversary = "anniversary"
    case family = "family"
    case school = "school"
    case work = "work"

    var displayName: String {
        switch self {
        case .like:
            return "Like"
        case .dislike:
            return "Dislike"
        case .hobby:
            return "Hobby"
        case  .anniversary:
            return "Anniv."
        case .family:
            return "Family"
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
        case .hobby:
            return "music.note"
        case .anniversary:
            return "birthday.cake"
        case .family:
            return "person.2"
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
        case .hobby:
            return "music.note"
        case .anniversary:
            return "birthday.cake.fill"
        case .family:
            return "person.2.fill"
        case .school:
            return "graduationcap.fill"
        case .work:
            return "briefcase.fill"
        }
    }
    
    // "All" category properties
    struct AllCategory {
        static let iconName = "line.3.horizontal.decrease.circle"
        static let iconFilledName = "line.3.horizontal.decrease.circle.fill"
        static let label = "All"
        static let highlightColor: UIColor = .darkGray
        
        static var icon: UIImage {
            UIImage(systemName: iconName) ?? UIImage()
        }
        
        static var iconFilled: UIImage {
            UIImage(systemName: iconFilledName) ?? UIImage()
        }
    }
}
