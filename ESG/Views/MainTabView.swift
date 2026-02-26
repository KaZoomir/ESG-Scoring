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
            Text("Explore")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "fbfbfb"))
                .tabItem {
                    Label("Explore", systemImage: AppTab.explore.icon)
                }
                .tag(AppTab.explore)

            // Create (центральная кнопка +)
            Color.clear
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(AppTab.create)

            // Shop
            Text("Shop")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "fbfbfb"))
                .tabItem {
                    Label("Shop", systemImage: AppTab.shop.icon)
                }
                .tag(AppTab.shop)

            // Profile
            Text("Profile")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "fbfbfb"))
                .tabItem {
                    Label("Profile", systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .tint(Color.primaryGreen)
        .onChange(of: selectedTab) { newTab in
            if newTab == .create {
                showCreateSheet = true
                // Возвращаем предыдущий таб, чтобы "+" не оставался выбранным
                selectedTab = .home
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            // TODO: CreateEventView / CreateProjectView based on user role
            Text("Create")
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
    case home, explore, create, shop, profile

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .explore: return "magnifyingglass"
        case .create:  return "plus.circle.fill"
        case .shop:    return "bag.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
