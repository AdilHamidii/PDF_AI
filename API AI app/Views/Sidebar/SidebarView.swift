//
//  SidebarView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var isOpen: Bool
    let documents: [DocumentModel]
    let user: UserModel?

    private var userName: String { user?.fullName ?? "User" }
    private var userEmail: String { user?.email ?? "" }
    private var userIsPro: Bool { user?.isPro ?? false }

    var body: some View {
        GeometryReader { geometry in
            let sidebarWidth = geometry.size.width * 0.82

            ZStack(alignment: .leading) {
                Color.black
                    .opacity(isOpen ? 0.35 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(isOpen)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            isOpen = false
                        }
                    }
                    .zIndex(1)

                VStack(alignment: .leading, spacing: 0) {
                    // User section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.brand.opacity(0.15))
                                .frame(width: 48, height: 48)

                            Text(userInitials)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.brand)
                        }

                        Text(userName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primaryText)

                        if !userEmail.isEmpty {
                            Text(userEmail)
                                .font(.system(size: 13))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    .padding(Spacing.lg)
                    .padding(.top, Spacing.sm)

                    // New PDF button
                    Button(action: {
                        HapticHelper.medium()
                        print("New PDF tapped")
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("New PDF")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.brand)
                        .cornerRadius(Radius.button)
                    }
                    .padding(.horizontal, Spacing.lg)

                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 0.5)
                        .padding(.vertical, Spacing.md)

                    // Documents list
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Spacing.lg) {
                            if !todayDocuments.isEmpty {
                                documentSection(title: "Today", documents: todayDocuments)
                            }
                            if !yesterdayDocuments.isEmpty {
                                documentSection(title: "Yesterday", documents: yesterdayDocuments)
                            }
                            if !last7DaysDocuments.isEmpty {
                                documentSection(title: "Last 7 days", documents: last7DaysDocuments)
                            }
                            if !olderDocuments.isEmpty {
                                documentSection(title: "Older", documents: olderDocuments)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }

                    Spacer()

                    // Bottom section
                    VStack(spacing: Spacing.sm) {
                        if !userIsPro {
                            Button(action: { print("Show paywall") }) {
                                HStack(spacing: Spacing.sm) {
                                    Text("PRO")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.proGold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.proGold.opacity(0.12))
                                        .cornerRadius(4)

                                    Text("Upgrade for unlimited PDFs")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondaryText)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondaryText.opacity(0.4))
                                }
                                .padding(Spacing.md)
                                .background(Color.surface)
                                .cornerRadius(Radius.input)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button(action: { print("Settings tapped") }) {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.secondaryText)
                                Text("Settings")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondaryText)
                                Spacer()
                            }
                            .padding(.vertical, Spacing.sm)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
                .frame(width: sidebarWidth)
                .background(Color.cardBackground)
                .shadow(color: Color.black.opacity(isOpen ? 0.12 : 0), radius: 20, x: 4, y: 0)
                .offset(x: isOpen ? 0 : -sidebarWidth)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isOpen)
                .zIndex(2)
            }
        }
    }

    private var userInitials: String {
        let components = userName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }

    private var todayDocuments: [DocumentModel] {
        documents.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var yesterdayDocuments: [DocumentModel] {
        documents.filter { Calendar.current.isDateInYesterday($0.createdAt) }
    }

    private var last7DaysDocuments: [DocumentModel] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        return documents.filter {
            $0.createdAt >= sevenDaysAgo && $0.createdAt < twoDaysAgo
        }
    }

    private var olderDocuments: [DocumentModel] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return documents.filter { $0.createdAt < sevenDaysAgo }
    }

    @ViewBuilder
    private func documentSection(title: String, documents: [DocumentModel]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondaryText)
                .textCase(.uppercase)
                .tracking(0.5)

            ForEach(documents) { document in
                DocumentRow(document: document)
                    .contextMenu {
                        Button(action: { print("Rename: \(document.title)") }) {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(action: { print("Duplicate: \(document.title)") }) {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        Button(role: .destructive, action: { print("Delete: \(document.title)") }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

struct DocumentRow: View {
    let document: DocumentModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(documentType.color.opacity(0.12))
                    .frame(width: 24, height: 24)

                Image(systemName: documentType.icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(documentType.color)
            }

            Text(document.title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primaryText)
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticHelper.selection()
            print("Open PDF: \(document.title)")
        }
    }

    private var documentType: DocumentType {
        DocumentType(rawValue: document.documentType) ?? .freeform
    }
}

#Preview {
    SidebarView(
        isOpen: .constant(true),
        documents: [],
        user: nil
    )
    .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
