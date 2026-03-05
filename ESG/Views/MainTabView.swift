//
//  MainTabView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.26.
//

import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showCreateSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {

            // Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            // Explore
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: AppTab.explore.icon)
                }
                .tag(AppTab.explore)

            // Create (центральная кнопка +)
            Color.clear
                .tabItem {
                    Label("Game", systemImage: AppTab.game.icon)
                }
                .tag(AppTab.game)

            // Shop
            ShopView()
                .tabItem{
                    Label("Shop", systemImage: AppTab.shop.icon)
                }
                .tag(AppTab.shop)

            // Profile
            ProfileView()
                           .tabItem {
                            Label("Profile", systemImage: AppTab.profile.icon)
                           }
                           .tag(AppTab.profile)
        }
        .tint(Color.primaryGreen)
        .onChange(of: selectedTab) { newTab in
            if newTab == .game {
                showCreateSheet = true
                selectedTab = .home
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            Text("Game")
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    // MARK: - Tab Bar Appearance (нативный iOS стиль)

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        // Нормальное состояние (не выбрано)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]

        // Выбранное состояние — primaryGreen
        let selectedColor = UIColor(Color.primaryGreen)
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - AppTab

enum AppTab: CaseIterable {
    case home, explore, game, shop, profile

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .explore: return "magnifyingglass"
        case .game:  return "gamecontroller.fill"
        case .shop:    return "bag.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
