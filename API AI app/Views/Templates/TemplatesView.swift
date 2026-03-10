//
//  TemplatesView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct TemplatesView: View {
    @State private var showCards = false

    let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Templates")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primaryText)
                            .tracking(-0.5)

                        Text("Choose a document type")
                            .font(.system(size: 15))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(Array(DocumentType.allCases.enumerated()), id: \.element) { index, type in
                            TemplateCard(
                                documentType: type,
                                index: index,
                                show: showCards
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.bottom, Spacing.xl)
            }
            .background(Color.background)
        }
        .onAppear { showCards = true }
    }
}

struct TemplateCard: View {
    let documentType: DocumentType
    let index: Int
    let show: Bool

    @State private var isVisible = false

    var description: String {
        switch documentType {
        case .freeform: return "Anything you can describe"
        case .cv: return "ATS-friendly resume"
        case .coverLetter: return "Tailored application letters"
        case .letter: return "Professional correspondence"
        case .receipt: return "Business receipts & invoices"
        case .businessCard: return "Elegant business cards"
        }
    }

    var body: some View {
        Button(action: {
            if documentType.isPro {
                print("Show paywall for \(documentType.displayName)")
            } else {
                print("Selected template: \(documentType.displayName)")
            }
        }) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Image(systemName: documentType.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(documentType.color)

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(documentType.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)

                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 140)
            .background(Color.cardBackground)
            .cornerRadius(Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card)
                    .stroke(Color.border, lineWidth: 0.5)
            )
            .overlay(
                Group {
                    if documentType.isPro {
                        VStack {
                            HStack {
                                Spacer()
                                Text("PRO")
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundColor(.proGold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.proGold.opacity(0.12))
                                    .cornerRadius(4)
                                    .padding(Spacing.sm)
                            }
                            Spacer()
                        }

                        RoundedRectangle(cornerRadius: Radius.card)
                            .fill(Color.background.opacity(0.6))

                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondaryText.opacity(0.5))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 16)
        .onChange(of: show) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.35).delay(Double(index) * 0.05)) {
                    isVisible = true
                }
            }
        }
    }
}

#Preview {
    TemplatesView()
}
