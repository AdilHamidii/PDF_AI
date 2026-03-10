//
//  Models.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import Foundation
import SwiftUI

enum DocumentType: String, CaseIterable {
    case freeform
    case cv
    case coverLetter
    case letter
    case receipt
    case businessCard

    var displayName: String {
        switch self {
        case .freeform: return "Free-form"
        case .cv: return "CV / Resume"
        case .coverLetter: return "Cover Letter"
        case .letter: return "Formal Letter"
        case .receipt: return "Receipt"
        case .businessCard: return "Business Card"
        }
    }

    var icon: String {
        switch self {
        case .freeform: return "doc.text"
        case .cv: return "person.text.rectangle"
        case .coverLetter: return "envelope"
        case .letter: return "text.alignleft"
        case .receipt: return "receipt"
        case .businessCard: return "rectangle.on.rectangle.angled"
        }
    }

    var isPro: Bool {
        self == .receipt || self == .businessCard
    }

    var color: Color {
        switch self {
        case .freeform: return .brand
        case .cv: return Color(hex: "#6366F1")
        case .coverLetter: return Color(hex: "#34D399")
        case .letter: return Color(hex: "#F59E0B")
        case .receipt: return Color(hex: "#EF4444")
        case .businessCard: return Color(hex: "#8B5CF6")
        }
    }
}
