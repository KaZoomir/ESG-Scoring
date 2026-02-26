//
//  ProfileView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.27.
//

import SwiftUI
import FirebaseAuth

// MARK: - ProfileView

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedSection: ProfileSection = .overview

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "fbfbfb").ignoresSafeArea()

                if viewModel.isLoading && viewModel.user == nil {
                    ProgressView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            // MARK: - Header Card
                            ProfileHeaderCard(user: viewModel.user)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)

                            // MARK: - ESG Score Breakdown
                            if let user = viewModel.user {
                                ESGScoreBreakdownCard(user: user)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)
                            }

                            // MARK: - Section Tabs
                            ProfileSectionTabs(selected: $selectedSection)
                                .padding(.top, 16)

                            Rectangle()
                                .fill(Color(hex: "e1e1e3"))
                                .frame(height: 1)

                            // MARK: - Section Content
                            switch selectedSection {
                            case .overview:
                                ProfileOverviewSection(user: viewModel.user, leaderboard: viewModel.leaderboard)
                            case .badges:
                                ProfileBadgesSection(badges: viewModel.badges)
                            case .settings:
                                ProfileSettingsSection(
                                    showLogoutConfirm: $viewModel.showLogoutConfirm
                                )
                            }

                            Color.clear.frame(height: 90)
                        }
                    }
                    .refreshable { viewModel.loadProfile() }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Sign Out", isPresented: $viewModel.showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { viewModel.logout() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedOut) {
            LoginView()
        }
    }
}

// MARK: - Profile Section Enum

enum ProfileSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case badges   = "Badges"
    case settings = "Settings"
    var id: String { rawValue }
}

// MARK: - Header Card

private struct ProfileHeaderCard: View {
    let user: User?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {

                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Text(user?.name.prefix(1).uppercased() ?? "?")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(user?.name ?? "—")
                        .font(.h4)
                        .foregroundStyle(Color(.label))

                    if let email = user?.email {
                        Label(email, systemImage: "envelope")
                            .font(.bodySmall)
                            .foregroundStyle(Color(.systemGray))
                            .lineLimit(1)
                    }

                    if let sid = user?.studentID, !sid.isEmpty {
                        Label(sid, systemImage: "person.text.rectangle")
                            .font(.bodySmall)
                            .foregroundStyle(Color(.systemGray))
                    }

                    if let faculty = user?.faculty, !faculty.isEmpty {
                        Label(faculty, systemImage: "building.2")
                            .font(.bodySmall)
                            .foregroundStyle(Color(.systemGray))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider().padding(.horizontal, 16).padding(.top, 12)

            // Level + points
            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text(user?.getUserLevel() ?? "—")
                        .font(.h6)
                        .foregroundStyle(Color.primaryGreen)
                    Text("Level")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray))
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 36)

                VStack(spacing: 2) {
                    Text("\(user?.totalESGScore ?? 0)")
                        .font(.h6)
                        .foregroundStyle(Color(.label))
                    Text("ESG Points")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray))
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 36)

                VStack(spacing: 2) {
                    Text("\(user?.currentStreak ?? 0)🔥")
                        .font(.h6)
                        .foregroundStyle(Color(.label))
                    Text("Streak")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)

            // Progress bar to next level
            if let user = user {
                let progress = user.getProgressToNextLevel()
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress to \(nextLevel(user))")
                            .font(.caption)
                            .foregroundStyle(Color(.systemGray))
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(Color.primaryGreen)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "e1e1e3"))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primaryGreen)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }

    private func nextLevel(_ user: User) -> String {
        let levels = AppConfig.levelNames
        let current = user.getUserLevel()
        if let idx = levels.firstIndex(of: current), idx < levels.count - 1 {
            return levels[idx + 1]
        }
        return "Max"
    }
}

// MARK: - ESG Score Breakdown

private struct ESGScoreBreakdownCard: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ESG Score Breakdown")
                .font(.h6)
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 16)
                .padding(.top, 14)

            VStack(spacing: 10) {
                ScoreBar(label: "Environmental", score: user.environmentalScore, total: user.totalESGScore, color: Color.environmentalColor, icon: "leaf.fill")
                ScoreBar(label: "Social", score: user.socialScore, total: user.totalESGScore, color: Color.socialColor, icon: "person.3.fill")
                ScoreBar(label: "Governance", score: user.governanceScore, total: user.totalESGScore, color: Color.governanceColor, icon: "building.columns.fill")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }
}

private struct ScoreBar: View {
    let label: String
    let score: Int
    let total: Int
    let color: Color
    let icon: String

    var progress: Double {
        guard total > 0 else { return 0 }
        return min(1.0, Double(score) / Double(total))
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(color)
                Text(label)
                    .font(.bodySmall)
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("\(score) pts")
                    .font(.bodySmall)
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.12))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Section Tabs

private struct ProfileSectionTabs: View {
    @Binding var selected: ProfileSection

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProfileSection.allCases) { section in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = section
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(section.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(selected == section ? Color(.label) : Color(.systemGray))
                            .padding(.horizontal, 8)
                            .padding(.top, 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(selected == section ? Color.primaryGreen : Color.clear)
                            .frame(width: 24, height: 4)
                            .padding(.bottom, 4)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "fbfbfb"))
    }
}

// MARK: - Overview Section

private struct ProfileOverviewSection: View {
    let user: User?
    let leaderboard: [Rating]

    var body: some View {
        VStack(spacing: 12) {

            // Stats row
            HStack(spacing: 12) {
                StatCard(value: "\(user?.eventsAttended ?? 0)", label: "Attended", icon: "calendar.badge.checkmark", color: Color.primaryGreen)
                StatCard(value: "\(user?.eventsCompleted ?? 0)", label: "Completed", icon: "checkmark.seal.fill", color: Color.socialColor)
                StatCard(value: "\(user?.longestStreak ?? 0)", label: "Best Streak", icon: "flame.fill", color: Color.warningColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Leaderboard preview
            if !leaderboard.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Leaderboard")
                            .font(.h6)
                            .foregroundStyle(Color(.label))
                        Spacer()
                        Text("Top \(leaderboard.count)")
                            .font(.bodySmall)
                            .foregroundStyle(Color(.systemGray))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 8)

                    ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, rating in
                        LeaderboardRow(rating: rating, index: index)
                        if index < leaderboard.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }

                    Color.clear.frame(height: 10)
                }
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.h5)
                .foregroundStyle(Color(.label))
            Text(label)
                .font(.captionSmall)
                .foregroundStyle(Color(.systemGray))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }
}

private struct LeaderboardRow: View {
    let rating: Rating
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                if index < 3 {
                    Circle()
                        .fill(rankColor(index).opacity(0.12))
                        .frame(width: 32, height: 32)
                    Text(rating.getRankBadge())
                        .font(.system(size: 16))
                } else {
                    Circle()
                        .fill(Color(hex: "f6f6f9"))
                        .frame(width: 32, height: 32)
                    Text("\(rating.rank)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemGray))
                }
            }

            // Avatar
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.12))
                    .frame(width: 36, height: 36)
                Text(rating.userName.prefix(1).uppercased())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(rating.userName)
                    .font(.bodyMedium)
                    .foregroundStyle(Color(.label))
                if let faculty = rating.faculty {
                    Text(faculty)
                        .font(.captionSmall)
                        .foregroundStyle(Color(.systemGray))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(rating.score) pts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.label))
                if let change = rating.change, change != 0 {
                    Text(change > 0 ? "▲\(change)" : "▼\(abs(change))")
                        .font(.captionSmall)
                        .foregroundStyle(change > 0 ? Color.successColor : Color.errorColor)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color(hex: "FFD700")
        case 1: return Color(hex: "C0C0C0")
        case 2: return Color(hex: "CD7F32")
        default: return Color.primaryGreen
        }
    }
}

// MARK: - Badges Section

private struct ProfileBadgesSection: View {
    let badges: [Badge]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if badges.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rosette")
                        .font(.system(size: 48))
                        .foregroundStyle(Color(hex: "e1e1e3"))
                    Text("No badges yet")
                        .font(.bodyMedium)
                        .foregroundStyle(Color(.systemGray))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(badges) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
        }
    }
}

private struct BadgeCard: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? badgeColor(badge.type).opacity(0.15) : Color(hex: "f0f0f0"))
                    .frame(width: 56, height: 56)
                Image(systemName: badge.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(badge.isUnlocked ? badgeColor(badge.type) : Color(hex: "c0c0c0"))
            }

            Text(badge.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(badge.isUnlocked ? Color(.label) : Color(.systemGray))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(badge.description)
                .font(.captionSmall)
                .foregroundStyle(Color(.systemGray))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if !badge.isUnlocked {
                Text("\(badge.pointsRequired) pts required")
                    .font(.captionSmall)
                    .foregroundStyle(Color.primaryGreen)
            } else {
                Text("Unlocked ✓")
                    .font(.captionSmall)
                    .foregroundStyle(Color.successColor)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(badge.isUnlocked ? badgeColor(badge.type).opacity(0.3) : Color(hex: "e1e1e3"), lineWidth: 1)
        )
        .opacity(badge.isUnlocked ? 1.0 : 0.7)
    }

    private func badgeColor(_ type: BadgeType) -> Color {
        switch type {
        case .environmental: return Color.environmentalColor
        case .social:        return Color.socialColor
        case .governance:    return Color.governanceColor
        case .milestone:     return Color(hex: "FFD700")
        case .special:       return Color.primaryGreen
        }
    }
}

// MARK: - Settings Section

private struct ProfileSettingsSection: View {
    @Binding var showLogoutConfirm: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(spacing: 0) {
            // Appearance group
            SettingsGroup(title: "Appearance") {
                Toggle(isOn: $isDarkMode) {
                    SettingsRow(icon: "moon.fill", iconColor: Color(hex: "5856D6"), title: "Dark Mode")
                }
                .tint(Color.primaryGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            // Account group
            SettingsGroup(title: "Account") {
                Button {
                    // TODO: Edit Profile
                } label: {
                    SettingsRowChevron(icon: "person.fill", iconColor: Color.primaryGreen, title: "Edit Profile")
                }

                Divider().padding(.horizontal, 16)

                Button {
                    // TODO: Notifications settings
                } label: {
                    SettingsRowChevron(icon: "bell.fill", iconColor: Color.socialColor, title: "Notifications")
                }

                Divider().padding(.horizontal, 16)

                Button {
                    // TODO: Privacy
                } label: {
                    SettingsRowChevron(icon: "lock.fill", iconColor: Color(hex: "34C759"), title: "Privacy")
                }
            }

            // Support group
            SettingsGroup(title: "Support") {
                Button {
                    // TODO: Help
                } label: {
                    SettingsRowChevron(icon: "questionmark.circle.fill", iconColor: Color(hex: "FF9500"), title: "Help & FAQ")
                }

                Divider().padding(.horizontal, 16)

                Button {
                    if let url = URL(string: "mailto:support@esg-kbtu.kz") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    SettingsRowChevron(icon: "envelope.fill", iconColor: Color.infoColor, title: "Contact Us")
                }
            }

            // Logout
            Button {
                showLogoutConfirm = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.errorColor.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.errorColor)
                    }
                    Text("Sign Out")
                        .font(.bodyMedium)
                        .foregroundStyle(Color.errorColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(Color.errorColor.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .buttonStyle(.plain)
        }
        .padding(.top, 12)
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color(.systemGray))
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
}

private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.bodyMedium)
                .foregroundStyle(Color(.label))
        }
    }
}

private struct SettingsRowChevron: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.bodyMedium)
                .foregroundStyle(Color(.label))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.systemGray3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
