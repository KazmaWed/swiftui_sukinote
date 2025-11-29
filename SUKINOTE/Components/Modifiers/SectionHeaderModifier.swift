//
//  SectionHeaderModifier.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import SwiftUI

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
}
