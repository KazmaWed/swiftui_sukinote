//  GlassSurfaceModifier.swift
//  SUKINOTE
//
//  Reusable glass-like surface to match button .glass style look.
//  Adds material, subtle inner highlight and stroke to avoid looking darker on large areas.
//

import SwiftUI

struct GlassSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    var material: Material = .ultraThinMaterial
    var strokeOpacity: Double = 0.25
    var highlightOpacity: Double = 0.25
    // Extra specular/refraction-like sheens
    var diagonalSheenOpacity: Double = 0.12
    var radialSheenOpacity: Double = 0.10
    // Base luminance lift to counter dark backgrounds
    var baseLuminanceOpacity: Double = 0.08

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            // Base glass material
            .background(material, in: shape)
            // Base luminance lift across entire surface
            .overlay(
                shape
                    .fill(Color.white.opacity(baseLuminanceOpacity))
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            // Rim light to lift luminance
            .overlay(
                shape.strokeBorder(Color.white.opacity(strokeOpacity), lineWidth: 0.5)
            )
            // Top highlight band
            .overlay(
                shape
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white.opacity(highlightOpacity), location: 0.0),
                                .init(color: .white.opacity(highlightOpacity * 0.6), location: 0.12),
                                .init(color: .clear, location: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            // Diagonal sheen (simulates refraction along one axis)
            .overlay(
                shape
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(diagonalSheenOpacity), location: 0.35),
                                .init(color: .clear, location: 0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            // Radial glint near top-left (small sparkle)
            .overlay(
                shape
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(radialSheenOpacity),
                                .clear
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: max(cornerRadius, 24)
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func glassSurface(cornerRadius: CGFloat = 12,
                      material: Material = .ultraThinMaterial,
                      strokeOpacity: Double = 0.25,
                      highlightOpacity: Double = 0.25,
                      diagonalSheenOpacity: Double = 0.12,
                      radialSheenOpacity: Double = 0.10,
                      baseLuminanceOpacity: Double = 0.08) -> some View {
        modifier(GlassSurfaceModifier(cornerRadius: cornerRadius,
                                      material: material,
                                      strokeOpacity: strokeOpacity,
                                      highlightOpacity: highlightOpacity,
                                      diagonalSheenOpacity: diagonalSheenOpacity,
                                      radialSheenOpacity: radialSheenOpacity,
                                      baseLuminanceOpacity: baseLuminanceOpacity))
    }
}
