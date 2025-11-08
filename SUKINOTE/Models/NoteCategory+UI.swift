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
        case .hobby: 
            // Mix teal with 10% black for a darker teal
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            UIColor.systemTeal.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return UIColor(
                red: red * 0.85,
                green: green * 0.85,
                blue: blue * 0.85,
                alpha: alpha
            )
        case .anniversary: return .systemOrange
        case .family: return .systemPurple
        case .school: return .systemIndigo
        case .work: return .systemBrown
        }
    }

    var highlightColor: Color { Color(highlightUIColor) }
}
