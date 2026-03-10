//
//  DesignConstants.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import Foundation

enum Radius {
    static let card: CGFloat = 20
    static let button: CGFloat = 16
    static let input: CGFloat = 14
    static let sheet: CGFloat = 28
    static let pill: CGFloat = 100
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum Shadows {
    static let card = ShadowStyle(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    static let elevated = ShadowStyle(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
}

struct ShadowStyle {
    let color: SwiftUI.Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

import SwiftUI

extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    func elevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
    }
}
