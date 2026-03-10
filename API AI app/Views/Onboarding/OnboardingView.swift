//
//  OnboardingView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.darkSurface.ignoresSafeArea()

            TabView(selection: $currentPage) {
                WelcomePage(onGetStarted: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 1
                    }
                })
                .tag(0)

                HowItWorksPage(onNext: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 2
                    }
                })
                .tag(1)

                ProTeaserPage(onStartFree: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasSeenOnboarding = true
                    }
                })
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Page indicator
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.brand : Color.white.opacity(0.2))
                            .frame(width: index == currentPage ? 24 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }
                .padding(.bottom, 36)
            }
        }
    }
}

// MARK: - Page 1: Welcome

struct WelcomePage: View {
    let onGetStarted: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 42, weight: .light))
                        .foregroundColor(.brand)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                VStack(spacing: Spacing.sm) {
                    Text("Professional PDFs,\ninstantly.")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .tracking(-0.5)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)

                    Text("Describe what you need. We handle the rest.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
            Spacer()

            Button(action: onGetStarted) {
                Text("Get started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.brand)
                    .cornerRadius(Radius.button)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 72)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

// MARK: - Page 2: How it works

struct HowItWorksPage: View {
    let onNext: () -> Void
    @State private var showSteps = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("How it works")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(-0.5)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    StepRow(number: "1", title: "Describe your document",
                            subtitle: "Type or speak your request",
                            delay: 0.1, show: showSteps)

                    StepRow(number: "2", title: "AI writes the code",
                            subtitle: "LaTeX generated in seconds",
                            delay: 0.2, show: showSteps)

                    StepRow(number: "3", title: "Get your PDF",
                            subtitle: "Download, share, or edit",
                            delay: 0.3, show: showSteps)
                }
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
            Spacer()

            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.brand)
                    .cornerRadius(Radius.button)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 72)
        }
        .onAppear { showSteps = true }
    }
}

struct StepRow: View {
    let number: String
    let title: String
    let subtitle: String
    let delay: Double
    let show: Bool

    @State private var isVisible = false

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.brand)
                .frame(width: 32, height: 32)
                .background(Color.brand.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -16)
        .onChange(of: show) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                    isVisible = true
                }
            }
        }
    }
}

// MARK: - Page 3: Pro teaser

struct ProTeaserPage: View {
    let onStartFree: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                Text("Start free,\ngo unlimited")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)

                // Comparison
                HStack(spacing: 0) {
                    // Free column
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Free")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, Spacing.xs)

                        FeatureRow(icon: "checkmark", text: "5 PDFs / week", isActive: true, isPro: false)
                        FeatureRow(icon: "checkmark", text: "Basic templates", isActive: true, isPro: false)
                        FeatureRow(icon: "minus", text: "Contains ads", isActive: false, isPro: false)
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.darkCard)

                    // Pro column
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack(spacing: 6) {
                            Text("Pro")
                                .font(.system(size: 15, weight: .semibold))
                            Text("PRO")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.proGold.opacity(0.3))
                                .cornerRadius(4)
                        }
                        .foregroundColor(.proGold)
                        .padding(.bottom, Spacing.xs)

                        FeatureRow(icon: "checkmark", text: "Unlimited", isActive: true, isPro: true)
                        FeatureRow(icon: "checkmark", text: "All templates", isActive: true, isPro: true)
                        FeatureRow(icon: "checkmark", text: "No ads", isActive: true, isPro: true)
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.brand.opacity(0.15))
                }
                .cornerRadius(Radius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, Spacing.xl)

                Text("From \u{20AC}4.99/month")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()
            Spacer()

            VStack(spacing: Spacing.md) {
                Button(action: onStartFree) {
                    Text("Start for free")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.brand)
                        .cornerRadius(Radius.button)
                }

                Button(action: { print("See Pro plans") }) {
                    Text("See Pro plans")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.brand)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 72)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let isActive: Bool
    var isPro: Bool = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isPro ? .proGold.opacity(0.8) : (isActive ? .success : .white.opacity(0.3)))

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(isPro ? 0.9 : 0.7))
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
