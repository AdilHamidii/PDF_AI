//
//  View+Haptics.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import UIKit

extension View {
    func hapticLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func hapticMedium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func hapticHeavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func hapticError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func hapticWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func hapticSelection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// Helper for triggering haptics in actions
struct HapticHelper {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
