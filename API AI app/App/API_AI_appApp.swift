//
//  PDFaiApp.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

@main
struct PDFaiApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            RootView(hasSeenOnboarding: $hasSeenOnboarding)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [UserModel.self, DocumentModel.self])
    }
}

struct RootView: View {
    @Binding var hasSeenOnboarding: Bool
    @Query private var users: [UserModel]
    @State private var showingAuth = false

    private var isLoggedIn: Bool { !users.isEmpty }

    var body: some View {
        ZStack {
            if isLoggedIn {
                MainTabView()
            }

            if !hasSeenOnboarding {
                Color.background.ignoresSafeArea()

                if showingAuth {
                    AuthView(hasSeenOnboarding: $hasSeenOnboarding)
                        .transition(.opacity)
                } else {
                    OnboardingView(hasSeenOnboarding: $showingAuth)
                        .transition(.opacity)
                }
            } else if !isLoggedIn {
                Color.background.ignoresSafeArea()
                AuthView(hasSeenOnboarding: $hasSeenOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.3), value: showingAuth)
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
    }
}
