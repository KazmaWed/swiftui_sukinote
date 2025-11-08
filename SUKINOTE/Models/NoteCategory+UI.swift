//  NoteCategory+UI.swift
//  SUKINOTE
//
//  UI-related extensions for NoteCategory (colors, etc.)
//
import UIKit
import SwiftUI

extension NoteCategory {
    var highlightUIColor: UIColor {
        switch self {
        case .like: return .systemPink
        case .dislike: return .systemPurple
        case .anniversary: return .systemOrange
        case .family: return .systemBlue
        case .hobby: return .systemTeal
        case .school: return .systemIndigo
        case .work: return .systemGray
        }
    }

    var highlightColor: Color { Color(highlightUIColor) }
}
