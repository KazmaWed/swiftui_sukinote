//  NoteCategory+UI.swift
//  SUKINOTE
//
//  UI-related extensions for NoteCategory (colors, etc.)
//

import SwiftUI
import UIKit

extension NoteCategory {
    var highlightUIColor: UIColor {
        switch self {
        case .like: return .systemPink
        case .dislike: return .systemBlue
        case .anniversary: return .systemOrange
        case .family: return .systemPurple
        case .hobby: return .systemTeal
        case .school: return .systemIndigo
        case .work: return .systemBrown
        }
    }

    var highlightColor: Color { Color(highlightUIColor) }
}
