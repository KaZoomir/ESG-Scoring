//
//  ExploreView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.27.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "fbfbfb").ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(.systemGray))
                        TextField("Search events and projects...", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // MARK: - Tabs (All / Events / Projects) — Android TabBar
                    ExploreTabBarView(selectedTab: $viewModel.selectedTab)

                    Rectangle()
                        .fill(Color(hex: "e1e1e3"))
                        .frame(height: 1)

                    // MARK: - Feed
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {

                            // Upcoming Events — horizontal scroll
                            if viewModel.showEventsRow {
                                let filtered = filteredEvents
                                ExploreEventsSectionView(
                                    events: filtered,
                                    isLoading: viewModel.isLoading
                                )
                                .padding(.top, 8)
                            }

                            // Projects feed
                            let filteredProjects = self.filteredProjects
                            if filteredProjects.isEmpty && !viewModel.isLoading
                                && (viewModel.selectedTab == .projects || viewModel.selectedTab == .all) {
                                ExploreEmptyView(query: searchText)
                            } else {
                                ForEach(filteredProjects) { project in
                                    ProjectCardView(
                                        project: project,
                                        onLike: { viewModel.likeProject(project) }
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }

                            Color.clear.frame(height: 80)
                        }
                        .padding(.top, 4)
                    }
                    .refreshable { viewModel.refresh() }
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
    }

    // MARK: - Search filtering

    private var filteredEvents: [Event] {
        guard !searchText.isEmpty else { return viewModel.upcomingEvents }
        return viewModel.upcomingEvents.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.location ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredProjects: [Project] {
        let base = viewModel.feedProjects
        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Tab Bar (same style as HomeTabBarView)

private struct ExploreTabBarView: View {
    @Binding var selectedTab: HomeTab

    // Android ExploreScreen tabs: All, Events, Projects (no Live)
    private let tabs: [HomeTab] = [.all, .events, .projects]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(selectedTab == tab ? Color(.label) : Color(.systemGray))
                            .padding(.horizontal, 8)
                            .padding(.top, 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(selectedTab == tab ? Color.primaryGreen : Color.clear)
                            .frame(width: 20, height: 4)
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

// MARK: - Events Section (same as HomeView but for Explore)

private struct ExploreEventsSectionView: View {
    let events: [Event]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Events")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("See All")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primaryGreen)
            }
            .padding(.horizontal, 16)

            if isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .frame(height: 220)
            } else if events.isEmpty {
                Text("No upcoming events")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal, 16)
                    .frame(height: 60)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(events) { event in
                            NavigationLink(destination: Text("Event: \(event.title)")) {
                                EventCardView(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
            }
        }
    }
}

// MARK: - Empty State

private struct ExploreEmptyView: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Image(systemName: query.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color(.systemGray3))
            Text(query.isEmpty ? "No projects yet" : "No results for \"\(query)\"")
                .font(.system(size: 16))
                .foregroundStyle(Color(.systemGray))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ExploreView()
}
