//
//  PressableButtonStyle.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticHelper.light()
                }
            }
    }
}

extension View {
    func pressableButton() -> some View {
        self.buttonStyle(PressableButtonStyle())
    }
}
