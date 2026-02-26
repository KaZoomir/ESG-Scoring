//
//  MainTabView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.26.
//

import SwiftUI

// MARK: - MainTabView
// Figma: bottom tab bar — home, search, +, shop, profile

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showCreateSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - Screen content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .explore:
                    Text("Explore") // TODO: ExploreView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "fbfbfb"))
                case .shop:
                    Text("Shop") // TODO: ShopView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "fbfbfb"))
                case .profile:
                    Text("Profile") // TODO: ProfileView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "fbfbfb"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Tab Bar
            TabBarView(selectedTab: $selectedTab, onPlusTap: {
                showCreateSheet = true
            })
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showCreateSheet) {
            // TODO: CreateEventView / CreateProjectView based on user role
            Text("Create")
        }
    }
}

// MARK: - AppTab

enum AppTab: CaseIterable {
    case home, explore, shop, profile
    
    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .explore: return "magnifyingglass"
        case .shop:    return "bag.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - TabBarView
// Figma: dark pill-shaped bar, green circle on active home, + button in center

private struct TabBarView: View {
    @Binding var selectedTab: AppTab
    let onPlusTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Home
            TabBarButton(
                icon: AppTab.home.icon,
                isSelected: selectedTab == .home,
                isActive: true
            ) {
                selectedTab = .home
            }
            
            // Explore
            TabBarButton(
                icon: AppTab.explore.icon,
                isSelected: selectedTab == .explore
            ) {
                selectedTab = .explore
            }
            
            // Plus (center)
            Button(action: onPlusTap) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.label))
                }
            }
            .frame(maxWidth: .infinity)
            
            // Shop
            TabBarButton(
                icon: AppTab.shop.icon,
                isSelected: selectedTab == .shop
            ) {
                selectedTab = .shop
            }
            
            // Profile
            TabBarButton(
                icon: AppTab.profile.icon,
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(.label))
                .padding(.horizontal, 12)
        )
        .padding(.bottom, 8)
    }
}

// MARK: - TabBarButton

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected && isActive {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 44, height: 44)
                }
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .white : Color(.systemGray))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
