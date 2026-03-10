//
//  AccountView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

struct AccountView: View {
    let user: UserModel?

    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @State private var notificationsEnabled = true
    @State private var selectedLanguage = "English"
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false

    let languages = ["English", "French"]

    private var userName: String { user?.fullName ?? "User" }
    private var userEmail: String { user?.email ?? "" }
    private var userIsPro: Bool { user?.isPro ?? false }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Profile header
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.brand.opacity(0.15))
                                .frame(width: 72, height: 72)

                            Text(userInitials)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.brand)
                        }

                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primaryText)

                            if !userEmail.isEmpty {
                                Text(userEmail)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondaryText)
                            }
                        }

                        // Plan badge
                        Text(userIsPro ? "PRO" : "FREE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(userIsPro ? .proGold : .secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                (userIsPro ? Color.proGold : Color.secondaryText).opacity(0.1)
                            )
                            .cornerRadius(Radius.pill)
                    }
                    .padding(.top, Spacing.lg)

                    // Upgrade card (free users)
                    if !userIsPro {
                        Button(action: { print("Show subscription view") }) {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Upgrade to Pro")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Unlimited PDFs, no ads, all templates")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))

                                HStack {
                                    Text("Upgrade")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primaryText)

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.white)
                                .cornerRadius(Radius.button)
                            }
                            .padding(Spacing.lg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.brand, Color.brandDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(Radius.card)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, Spacing.md)
                    }

                    // Settings
                    VStack(spacing: Spacing.md) {
                        SettingsSection(title: "Preferences") {
                            SettingsRow(icon: "bell", title: "Notifications", iconColor: .brand) {
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(.brand)
                            }

                            SettingsRow(icon: "globe", title: "Language", iconColor: .secondaryText) {
                                Menu {
                                    ForEach(languages, id: \.self) { language in
                                        Button(action: { selectedLanguage = language }) {
                                            HStack {
                                                Text(language)
                                                if selectedLanguage == language {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 3) {
                                        Text(selectedLanguage)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondaryText)

                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.secondaryText.opacity(0.5))
                                    }
                                }
                            }
                        }

                        SettingsSection(title: "Legal") {
                            SettingsRow(icon: "hand.raised", title: "Privacy Policy", iconColor: .secondaryText) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondaryText.opacity(0.3))
                            }
                            .onTapGesture { print("Open Privacy Policy") }

                            SettingsRow(icon: "doc.text", title: "Terms of Service", iconColor: .secondaryText) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondaryText.opacity(0.3))
                            }
                            .onTapGesture { print("Open Terms of Service") }
                        }

                        SettingsSection(title: "Account") {
                            SettingsRow(icon: "star", title: "Rate PDF AI", iconColor: .proGold) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondaryText.opacity(0.3))
                            }
                            .onTapGesture { print("Open App Store rating") }

                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", iconColor: .error) {
                                EmptyView()
                            }
                            .onTapGesture { showSignOutAlert = true }
                        }

                        SettingsSection(title: "") {
                            SettingsRow(icon: "trash", title: "Delete Account", iconColor: .error) {
                                EmptyView()
                            }
                            .onTapGesture { showDeleteAccountAlert = true }
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Text("PDF AI v1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(.secondaryText.opacity(0.4))
                        .padding(.bottom, Spacing.xl)
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { signOut() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteAccount() }
        } message: {
            Text("All your PDFs and data will be permanently deleted.")
        }
    }

    private var userInitials: String {
        let components = userName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }

    private func signOut() {
        if let user {
            modelContext.delete(user)
        }
        hasSeenOnboarding = false
    }

    private func deleteAccount() {
        let docDescriptor = FetchDescriptor<DocumentModel>()
        if let allDocs = try? modelContext.fetch(docDescriptor) {
            for doc in allDocs {
                modelContext.delete(doc)
            }
        }
        if let user {
            modelContext.delete(user)
        }
        hasSeenOnboarding = false
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.sm)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.cardBackground)
            .cornerRadius(Radius.card)
            .cardShadow()
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 30, height: 30)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primaryText)

            Spacer()

            trailing
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

extension ShapeStyle where Self == AnyShapeStyle {
    static var any: AnyShapeStyle { AnyShapeStyle(Color.clear) }
}

extension LinearGradient {
    var any: AnyShapeStyle { AnyShapeStyle(self) }
}

#Preview {
    AccountView(user: nil)
        .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
