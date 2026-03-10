//
//  HomeView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let user: UserModel?
    let documents: [DocumentModel]

    @Environment(\.sidebarToggle) var sidebarToggle

    let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: Spacing.md) {
                    Button(action: {
                        HapticHelper.medium()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            sidebarToggle.wrappedValue.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.cardBackground)
                            .cornerRadius(Radius.input)
                            .cardShadow()
                    }

                    Spacer()

                    Text("PDF AI")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryText)
                        .tracking(-0.5)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryText)
                            .frame(width: 44, height: 44)
                            .background(Color.cardBackground)
                            .cornerRadius(Radius.input)
                            .cardShadow()
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Greeting card
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("\(greeting),")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryText)
                                .tracking(-0.5)

                            Text(user?.fullName ?? "there")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.brand)
                                .tracking(-0.5)

                            let usage = user?.weeklyUsage ?? 0
                            HStack(spacing: Spacing.sm) {
                                HStack(spacing: 3) {
                                    ForEach(0..<5) { i in
                                        Capsule()
                                            .fill(i < usage ? Color.brand : Color.surface)
                                            .frame(width: 20, height: 6)
                                    }
                                }

                                Text("\(5 - usage) remaining")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondaryText)
                            }
                            .padding(.top, Spacing.xs)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                        // Quick templates
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Quick create")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, Spacing.md)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.sm) {
                                    ForEach(DocumentType.allCases, id: \.self) { type in
                                        TemplateChip(documentType: type)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                            }
                        }

                        // Recent PDFs
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Text("Recent")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondaryText)
                                    .textCase(.uppercase)
                                    .tracking(0.5)

                                Spacer()

                                if !documents.isEmpty {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            sidebarToggle.wrappedValue = true
                                        }
                                    }) {
                                        Text("See all")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.brand)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.md)

                            if documents.isEmpty {
                                VStack(spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.surface)
                                            .frame(width: 72, height: 72)

                                        Image(systemName: "doc.text")
                                            .font(.system(size: 28, weight: .light))
                                            .foregroundColor(.secondaryText.opacity(0.5))
                                    }

                                    Text("No PDFs yet")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primaryText)

                                    Text("Tap + to create your first document")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.xxl)
                            } else {
                                VStack(spacing: Spacing.sm) {
                                    if let first = documents.first {
                                        FeaturedDocumentCard(document: first)
                                            .padding(.horizontal, Spacing.md)
                                    }

                                    if documents.count > 1 {
                                        LazyVGrid(columns: columns, spacing: Spacing.sm) {
                                            ForEach(documents.dropFirst().prefix(4)) { document in
                                                CompactDocumentCard(document: document)
                                            }
                                        }
                                        .padding(.horizontal, Spacing.md)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, Spacing.xl)
                }
            }
            .background(Color.background)
        }
    }
}

// MARK: - Featured Document Card

struct FeaturedDocumentCard: View {
    let document: DocumentModel

    var documentType: DocumentType {
        DocumentType(rawValue: document.documentType) ?? .freeform
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: document.createdAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(documentType.color.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: documentType.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(documentType.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)

                Text("\(documentType.displayName)  ·  \(relativeDate)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondaryText.opacity(0.4))
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Radius.card)
        .cardShadow()
        .onTapGesture {
            print("Open PDF: \(document.title)")
        }
    }
}

// MARK: - Compact Document Card

struct CompactDocumentCard: View {
    let document: DocumentModel

    var documentType: DocumentType {
        DocumentType(rawValue: document.documentType) ?? .freeform
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: document.createdAt, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(documentType.color.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: documentType.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(documentType.color)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)

                Text(relativeDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130)
        .background(Color.cardBackground)
        .cornerRadius(Radius.card)
        .cardShadow()
        .onTapGesture {
            print("Open PDF: \(document.title)")
        }
    }
}

// MARK: - Template Chip

struct TemplateChip: View {
    let documentType: DocumentType

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: documentType.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(documentType.color)

            Text(documentType.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primaryText)

            if documentType.isPro {
                Text("PRO")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.proGold)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.proGold.opacity(0.12))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(Radius.pill)
        .cardShadow()
        .onTapGesture {
            if documentType.isPro {
                print("Show paywall for \(documentType.displayName)")
            } else {
                print("Selected template: \(documentType.displayName)")
            }
        }
    }
}

#Preview {
    HomeView(user: nil, documents: [])
        .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
