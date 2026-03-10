//
//  Color+Brand.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

extension Color {
    // Primary accent — soft coral/peach inspired by the reference UIs
    static let brand = Color(hex: "#F2784B")
    static let brandDark = Color(hex: "#D9643A")
    static let brandLight = Color(hex: "#FFF0EB")

    // Backgrounds — warm lavender-tinted off-white
    static let background = Color(hex: "#F5F3F8")
    static let surface = Color(hex: "#EEEAF3")
    static let cardBackground = Color(hex: "#FFFFFF")

    // Text
    static let primaryText = Color(hex: "#1C1B2E")
    static let secondaryText = Color(hex: "#9290A3")

    // Borders & dividers
    static let border = Color(hex: "#E8E5EE")

    // Semantic
    static let success = Color(hex: "#3AAF6C")
    static let error = Color(hex: "#E54D4D")
    static let proGold = Color(hex: "#D4A731")

    // Dark surface for onboarding / pro sections
    static let darkSurface = Color(hex: "#1C1B2E")
    static let darkCard = Color(hex: "#2A2940")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
