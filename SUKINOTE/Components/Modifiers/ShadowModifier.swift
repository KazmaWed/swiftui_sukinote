//
//  ShadowModifier.swift
//  SUKINOTE
//
//  Common shadow styles for UI elements
//

import SwiftUI

extension View {
    /// Applies a standard elevated shadow for buttons and interactive elements
    func elevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
