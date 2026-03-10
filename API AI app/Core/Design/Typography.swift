//
//  Typography.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

enum Typography {
    static func displayStyle() -> Font {
        .system(size: 32, weight: .bold)
    }

    static func titleStyle() -> Font {
        .system(size: 22, weight: .semibold)
    }

    static func headlineStyle() -> Font {
        .system(size: 16, weight: .semibold)
    }

    static func bodyStyle() -> Font {
        .system(size: 15, weight: .regular)
    }

    static func captionStyle() -> Font {
        .system(size: 12, weight: .medium)
    }
}

extension View {
    func displayStyle() -> some View {
        self.font(Typography.displayStyle())
    }

    func titleStyle() -> some View {
        self.font(Typography.titleStyle())
    }

    func headlineStyle() -> some View {
        self.font(Typography.headlineStyle())
    }

    func bodyStyle() -> some View {
        self.font(Typography.bodyStyle())
    }

    func captionStyle() -> some View {
        self.font(Typography.captionStyle())
    }
}
