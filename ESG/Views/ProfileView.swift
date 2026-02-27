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

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F2").ignoresSafeArea()

                if viewModel.user == nil {
                    ProgressView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            // MARK: Back + Title row
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color(.label))
                                    .frame(width: 36, height: 36)
                                Text("Profile")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            Spacer().frame(height: 12)

                            if let user = viewModel.user {

                                // MARK: Profile Header
                                ProfileHeaderCard(
                                    user: user,
                                    onEditClick: { viewModel.showEditDialog = true },
                                    onAvatarClick: {}
                                )
                                .padding(.horizontal, 16)

                                Spacer().frame(height: 12)

                                // MARK: Badges + Buttons Card
                                VStack(spacing: 0) {
                                    BadgesSection(badges: viewModel.badges)
                                        .padding(16)

                                    Divider().background(Color(hex: "E6E6E6"))

                                    VStack(spacing: 8) {
                                        NavigationLink(destination: RatingView()) {
                                            Text("View Rating")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 48)
                                                .background(Color.primaryGreen)
                                                .clipShape(Capsule())
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)

                                        ManagerMemberActions(role: user.role ?? "member")
                                            .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 16)
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 16)

                                Spacer().frame(height: 8)

                                // MARK: Navigation + Sign Out Card
                                VStack(spacing: 0) {
                                    NavigationCardList(items: [
                                        ("calendar",           "My Events"),
                                        ("envelope",           "Contact Us"),
                                        ("gearshape",          "Settings"),
                                        ("questionmark.circle","Help & FAQs"),
                                    ])

                                    Button {
                                        viewModel.showLogoutConfirm = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .font(.system(size: 20))
                                                .foregroundStyle(.red)
                                            Text("Sign Out")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.red)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .overlay(Capsule().stroke(Color.red, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                    .padding(16)

                                    Spacer().frame(height: 24)
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 16)
                            }

                            Spacer().frame(height: 90)
                        }
                    }
                    .refreshable { viewModel.loadProfile() }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showEditDialog) {
            EditProfileDialog(
                studentId: viewModel.user?.studentID ?? "",
                email: viewModel.user?.email ?? "",
                onSave: { sid, email in viewModel.updateUser(studentId: sid, email: email) }
            )
        }
        .alert("Sign Out", isPresented: $viewModel.showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { viewModel.logout() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedOut) {
            LoginView()
        }
    }
}

// MARK: - ProfileHeaderCard
// Android: Box { Image(profile_bg) + IconButton(edit, topEnd) + Column { avatar, name(warm_green), id, email, points, progressBar } }

private struct ProfileHeaderCard: View {
    let user: User
    let onEditClick: () -> Void
    let onAvatarClick: () -> Void

    @State private var animatedProgress: CGFloat = 0

    private var fraction: CGFloat {
        CGFloat(min(user.totalESGScore, 1000)) / 1000.0
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // profile_bg dark green gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color(hex: "0F2B1F"), Color(hex: "1B4332")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            // Edit icon — top end
            Button(action: onEditClick) {
                Image(systemName: "pencil")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .padding(16)
            }

            // Content column — start aligned
            VStack(alignment: .leading, spacing: 0) {

                // Avatar circle
                Button(action: onAvatarClick) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 64, height: 64)
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 16)

                // Name — warm_green (#A8E6CF matches Android's warm_green)
                Text(user.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(hex: "A8E6CF"))

                Text("My ID: \(user.studentID ?? "—")")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                Text("Email: \(user.email)")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                Spacer().frame(height: 20)

                Text("Points: \(user.totalESGScore)/1000")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                Spacer().frame(height: 8)

                // Progress bar — dark bg + warm_green fill, height 18dp, rounded
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "0A1F15"))
                            .frame(height: 18)
                        Capsule()
                            .fill(Color(hex: "A8E6CF"))
                            .frame(width: max(0, geo.size.width * animatedProgress), height: 18)
                    }
                }
                .frame(height: 18)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        animatedProgress = fraction
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - BadgesSection
// Android: Column { Text("Badges"), FlowRow(maxLines=2 or all) { BadgeItem }, OutlinedButton("View more/less") }

private struct BadgesSection: View {
    let badges: [Badge]
    @State private var expanded = false

    var displayed: [Badge] {
        expanded ? badges : Array(badges.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Badges")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 8)

            if badges.isEmpty {
                Text("No badges earned yet")
                    .foregroundStyle(.gray)
            } else {
                // Wrap layout
                WrapLayout(spacing: 8) {
                    ForEach(displayed) { badge in
                        BadgePill(badge: badge)
                    }
                }

                Spacer().frame(height: 8)

                // View more / less — OutlinedButton style
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Text(expanded ? "View less" : "View more")
                            .font(.system(size: 16))
                            .foregroundStyle(.black)
                        Image(systemName: expanded ? "chevron.up" : "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - BadgePill
// Android BadgeItem: Card(shape=Capsule, color by type) { Row { Image(badge icon 24dp), Text(name) } }

private struct BadgePill: View {
    let badge: Badge

    var style: (bg: Color, fg: Color) {
        switch badge.type {
        case .environmental: return (Color(hex: "4CAF50"), .white)
        case .social:        return (Color(hex: "A8E6CF"), .black)
        case .governance:    return (Color(hex: "1A4A30"), Color(hex: "A8E6CF"))
        default:             return (.white, .black)
        }
    }

    var sfSymbol: String {
        let s = badge.icon.lowercased()
        if s.contains("event_champion") { return "trophy.fill" }
        if s.contains("event_legend")   { return "star.fill" }
        if s.contains("event_master")   { return "medal.fill" }
        if s.contains("gold")           { return "circle.fill" }
        if s.contains("silver")         { return "circle.fill" }
        if s.contains("bronze")         { return "circle.fill" }
        if s.contains("shopaholic")     { return "bag.fill" }
        if s.contains("big_spender")    { return "creditcard.fill" }
        if s.contains("collector")      { return "tray.full.fill" }
        return "rosette"
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: sfSymbol)
                .font(.system(size: 16))
                .foregroundStyle(style.fg)
                .frame(width: 24, height: 24)
            Text(badge.title)
                .font(.system(size: 16))
                .foregroundStyle(style.fg)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(style.bg)
        .clipShape(Capsule())
    }
}

// MARK: - NavigationCardList
// Android NavigationCard: for each item → Row(padding top/bottom 20dp, start 28dp) { icon(green,20dp) + text(weight=1) + chevron } + HorizontalDivider

private struct NavigationCardList: View {
    let items: [(String, String)] // (sfSymbol, label)

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.1) { item in
                Button {} label: {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 8)
                        Image(systemName: item.0)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryGreen)
                            .frame(width: 20, height: 20)
                        Spacer().frame(width: 12)
                        Text(item.1)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .frame(width: 32, height: 32)
                    }
                    .padding(.vertical, 20)
                    .padding(.leading, 28)
                    .padding(.trailing, 20)
                }
                .buttonStyle(.plain)

                Divider().background(Color(hex: "DDDDDD"))
            }
        }
    }
}

// MARK: - ManagerMemberActions

private struct ManagerMemberActions: View {
    let role: String

    var body: some View {
        VStack(spacing: 0) {
            if role == "manager" {
                Spacer().frame(height: 16)
                CapsuleButton(title: "Add Event") {}
                CapsuleButton(title: "View Student Requests") {}
                CapsuleButton(title: "View All Student Purchases") {}
            }
            if role == "member" || role == "manager" {
                CapsuleButton(title: "Add Project") {}
            }
        }
    }
}

private struct CapsuleButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.primaryGreen)
                .clipShape(Capsule())
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EditProfileDialog
// Android: AlertDialog { OutlinedTextField(studentId) + OutlinedTextField(email) }

struct EditProfileDialog: View {
    @Environment(\.dismiss) private var dismiss
    @State var studentId: String
    @State var email: String
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer().frame(height: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Student ID (optional)")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    TextField("Student ID", text: $studentId)
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primaryGreen, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Email")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primaryGreen, lineWidth: 1))
                }

                Spacer()

                Button {
                    onSave(studentId, email)
                    dismiss()
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "4CAF50"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button("Cancel") { dismiss() }
                    .foregroundStyle(.gray)
            }
            .padding(20)
            .navigationTitle("Edit credentials")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - RatingView stub

struct RatingView: View {
    var body: some View {
        Text("Rating Screen")
            .navigationTitle("Ratings")
    }
}

// MARK: - WrapLayout (FlowRow equivalent)

private struct WrapLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
