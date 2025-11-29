//
//  UiColorExtension.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/09.
//

import SwiftUI

extension UIColor {
    static var darkTeal: UIColor {
        // Mix teal with 10% black for a darker teal
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor.systemTeal.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        return UIColor(
            red: red * 0.85,
            green: green * 0.85,
            blue: blue * 0.85,
            alpha: alpha
        )
    }
}
