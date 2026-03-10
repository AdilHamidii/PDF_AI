//
//  View+Shimmer.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.surface.opacity(0),
                            Color.white.opacity(0.6),
                            Color.surface.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct ShimmerCard: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.surface)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.surface)
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.surface)
                    .frame(width: 100, height: 10)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Radius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(Color.border, lineWidth: 0.5)
        )
        .shimmer()
    }
}

#Preview {
    VStack(spacing: Spacing.sm) {
        ShimmerCard()
        ShimmerCard()
        ShimmerCard()
    }
    .padding()
}
