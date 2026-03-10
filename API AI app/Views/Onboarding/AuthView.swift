//
//  AuthView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct AuthView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(0.15))
                        .frame(width: 88, height: 88)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.brand)
                }

                VStack(spacing: Spacing.xs) {
                    Text("PDF AI")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.5)

                    Text("Create professional documents")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            VStack(spacing: Spacing.sm) {
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 54)
                .cornerRadius(Radius.button)

                Button(action: {}) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)

                        Text("Sign in with Google")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.darkCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.button)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .cornerRadius(Radius.button)
                }

                Button(action: { continueAsGuest() }) {
                    Text("Continue without account")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, Spacing.sm)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.error)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.xs)
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
                .frame(height: Spacing.xl)

            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
        }
        .background(Color.darkSurface.ignoresSafeArea())
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView().tint(.brand)
                }
            }
        )
    }

    private func continueAsGuest() {
        let user = UserModel(
            appleUserID: "guest_\(UUID().uuidString)",
            fullName: "Adil",
            email: ""
        )
        modelContext.insert(user)
        hasSeenOnboarding = true
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

            let userID = credential.user
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let email = credential.email ?? ""

            // Check if user already exists (re-login)
            let descriptor = FetchDescriptor<UserModel>(
                predicate: #Predicate { $0.appleUserID == userID }
            )
            let existingUsers = (try? modelContext.fetch(descriptor)) ?? []

            if existingUsers.isEmpty {
                let user = UserModel(
                    appleUserID: userID,
                    fullName: fullName.isEmpty ? "User" : fullName,
                    email: email
                )
                modelContext.insert(user)
            }

            hasSeenOnboarding = true

        case .failure(let error):
            errorMessage = "Sign in failed. Please try again."
            print("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AuthView(hasSeenOnboarding: .constant(false))
        .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
