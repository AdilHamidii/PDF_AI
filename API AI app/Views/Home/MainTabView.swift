//
//  MainTabView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var isSidebarOpen = false
    @State private var showCreateSheet = false
    @State private var showStepForm = false
    @State private var selectedTemplateForForm: DocumentType?
    @State private var showGenerating = false
    @State private var freeformPrompt = ""
    @State private var freeformDocumentType = ""
    @State private var formDataForGeneration: [String: Any]?
    @StateObject private var toastManager = ToastManager()
    @Namespace private var animation

    @Query private var users: [UserModel]
    @Query(sort: \DocumentModel.createdAt, order: .reverse) private var documents: [DocumentModel]

    private var currentUser: UserModel? { users.first }

    enum Tab: Int {
        case home = 0
        case search = 1
        case fab = 2
        case notifications = 3
        case account = 4
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(user: currentUser, documents: documents)
                    case .search:
                        SearchView(documents: documents)
                    case .fab:
                        HomeView(user: currentUser, documents: documents)
                    case .notifications:
                        NotificationsView()
                    case .account:
                        AccountView(user: currentUser)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab, onFABTap: {
                    showCreateSheet = true
                })
            }

            SidebarView(
                isOpen: $isSidebarOpen,
                documents: documents,
                user: currentUser
            )
            .environment(\.sidebarToggle, $isSidebarOpen)
            .zIndex(999)
        }
        .environment(\.toastManager, toastManager)
        .environment(\.animationNamespace, animation)
        .toast(manager: toastManager)
        .sheet(isPresented: $showCreateSheet) {
            CreateBottomSheet(
                showStepForm: $showStepForm,
                selectedTemplateForForm: $selectedTemplateForForm,
                showGenerating: $showGenerating,
                freeformPrompt: $freeformPrompt,
                freeformDocumentType: $freeformDocumentType
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(Radius.sheet)
        }
        .sheet(isPresented: $showStepForm) {
            NavigationStack {
                if let template = selectedTemplateForForm {
                    StepFormView(
                        documentType: template,
                        onComplete: { formData in
                            freeformDocumentType = template.rawValue
                            formDataForGeneration = formData
                            freeformPrompt = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showGenerating = true
                            }
                        }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $showGenerating) {
            NavigationStack {
                GeneratingView(
                    prompt: freeformPrompt.isEmpty ? nil : freeformPrompt,
                    documentType: freeformDocumentType.isEmpty ? "freeform" : freeformDocumentType,
                    formData: formDataForGeneration
                )
            }
        }
        .preferredColorScheme(.light)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let onFABTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabBarItem(
                    icon: "house",
                    iconFilled: "house.fill",
                    isSelected: selectedTab == .home,
                    action: { selectedTab = .home }
                )

                TabBarItem(
                    icon: "magnifyingglass",
                    iconFilled: "magnifyingglass",
                    isSelected: selectedTab == .search,
                    action: { selectedTab = .search }
                )

                FABButton(action: onFABTap)
                    .padding(.horizontal, Spacing.sm)

                TabBarItem(
                    icon: "bell",
                    iconFilled: "bell.fill",
                    isSelected: selectedTab == .notifications,
                    action: { selectedTab = .notifications }
                )

                TabBarItem(
                    icon: "person",
                    iconFilled: "person.fill",
                    isSelected: selectedTab == .account,
                    action: { selectedTab = .account }
                )
            }
            .frame(height: 56)
            .padding(.bottom, 10)
            .padding(.top, 6)
            .background(
                Color.cardBackground
                    .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: -4)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let iconFilled: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticHelper.light()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? iconFilled : icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .brand : .secondaryText)

                Circle()
                    .fill(isSelected ? Color.brand : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

struct FABButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticHelper.medium()
            action()
        }) {
            Circle()
                .fill(Color.brand)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                )
                .shadow(color: Color.brand.opacity(0.3), radius: 12, x: 0, y: 4)
        }
        .offset(y: -8)
    }
}

// Environment key for sidebar toggle
struct SidebarToggleKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

// Environment key for animation namespace
struct AnimationNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var sidebarToggle: Binding<Bool> {
        get { self[SidebarToggleKey.self] }
        set { self[SidebarToggleKey.self] = newValue }
    }

    var animationNamespace: Namespace.ID? {
        get { self[AnimationNamespaceKey.self] }
        set { self[AnimationNamespaceKey.self] = newValue }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
