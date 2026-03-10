//
//  NotificationsView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct NotificationsView: View {
    let notifications = MockNotifications.notifications

    var body: some View {
        NavigationStack {
            Group {
                if notifications.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.surface)
                                .frame(width: 72, height: 72)

                            Image(systemName: "bell.slash")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.secondaryText.opacity(0.5))
                        }

                        VStack(spacing: Spacing.xs) {
                            Text("No notifications")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primaryText)

                            Text("We'll notify you when your PDFs are ready")
                                .font(.system(size: 14))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, Spacing.xl)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Spacing.sm) {
                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
            .background(Color.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(notification.iconColor.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: notification.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(notification.iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primaryText)

                Text(notification.body)
                    .font(.system(size: 13))
                    .foregroundColor(.secondaryText)

                Text(notification.relativeTime)
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryText.opacity(0.5))
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.brand)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Radius.card)
        .cardShadow()
        .contentShape(Rectangle())
        .onTapGesture {
            print("Notification tapped: \(notification.title)")
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let body: String
    let relativeTime: String
    let isRead: Bool
}

struct MockNotifications {
    static let notifications: [AppNotification] = [
        AppNotification(
            icon: "doc.text.fill",
            iconColor: .brand,
            title: "Your PDF is ready",
            body: "Software Engineer CV",
            relativeTime: "Just now",
            isRead: false
        ),
        AppNotification(
            icon: "exclamationmark.triangle",
            iconColor: .proGold,
            title: "4 of 5 PDFs used",
            body: "Upgrade for unlimited access",
            relativeTime: "Yesterday",
            isRead: false
        ),
        AppNotification(
            icon: "gift",
            iconColor: Color(hex: "#7B6BA0"),
            title: "Referral reward",
            body: "A friend joined PDF AI",
            relativeTime: "3 days ago",
            isRead: true
        ),
    ]
}

#Preview {
    NotificationsView()
}
