//
//  ToastView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import Combine

enum ToastType {
    case success
    case error
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .success
        case .error: return .error
        case .info: return .brand
        }
    }
}

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let type: ToastType
    let message: String

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(toast.type.color.opacity(0.12))
                    .frame(width: 28, height: 28)

                Image(systemName: toast.type.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(toast.type.color)
            }

            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryText)

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(Radius.button)
        .elevatedShadow()
        .padding(.horizontal, Spacing.md)
    }
}

class ToastManager: ObservableObject {
    @Published var currentToast: Toast?

    func show(_ type: ToastType, message: String) {
        withAnimation(.easeOut(duration: 0.25)) {
            currentToast = Toast(type: type, message: message)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.2)) {
                self.currentToast = nil
            }
        }
    }

    func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            currentToast = nil
        }
    }
}

struct ToastManagerKey: EnvironmentKey {
    static let defaultValue = ToastManager()
}

extension EnvironmentValues {
    var toastManager: ToastManager {
        get { self[ToastManagerKey.self] }
        set { self[ToastManagerKey.self] = newValue }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onTapGesture { toastManager.dismiss() }
                }
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

extension View {
    func toast(manager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: manager))
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ToastView(toast: Toast(type: .success, message: "PDF generated successfully"))
        ToastView(toast: Toast(type: .error, message: "Failed to generate PDF"))
        ToastView(toast: Toast(type: .info, message: "3 of 5 PDFs used this week"))
    }
    .padding()
}
