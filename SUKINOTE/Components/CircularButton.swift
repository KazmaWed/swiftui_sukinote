//
//  CircularButton.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import SwiftUI

struct CircularButton: View {
    let systemImage: String
    let action: () -> Void
    var size: CGFloat = 40
    var onSizeChanged: ((CGSize) -> Void)? = nil
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .frame(
                    width: size,
                    height: size,
                    alignment: .center
                )
        }
        .buttonStyle(.glass)
        .clipShape(Circle())
        .elevatedShadow()
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        onSizeChanged?(geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        onSizeChanged?(newSize)
                    }
            }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularButton(
            systemImage: "arrow.up.arrow.down",
            action: { print("Sort tapped") }
        )
        
        CircularButton(
            systemImage: "plus",
            action: { print("Add tapped") }
        )
        
        CircularButton(
            systemImage: "gear",
            action: { print("Settings tapped") },
            size: 50
        )
    }
    .padding()
}
