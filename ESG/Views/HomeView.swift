//
//  HomeView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateProject = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "fbfbfb").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Top Bar
                    HomeTopBarView()
                    
                    // MARK: - Tab Bar
                    HomeTabBarView(selectedTab: $viewModel.selectedTab)
                    
                    Rectangle()
                        .fill(Color(hex: "e1e1e3"))
                        .frame(height: 1)
                    
                    // MARK: - Feed
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            
                            // Upcoming Events horizontal row
                            if viewModel.showEventsRow {
                                UpcomingEventsSectionView(
                                    events: viewModel.upcomingEvents,
                                    isLoading: viewModel.isLoading
                                )
                                .padding(.top, 8)
                            }
                            
                            // Live events list
                            if !viewModel.feedLiveEvents.isEmpty {
                                ForEach(viewModel.feedLiveEvents) { event in
                                    NavigationLink(destination: Text("Event: \(event.title)")) {
                                        LiveEventRowView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // Empty state
                            if viewModel.feedProjects.isEmpty && !viewModel.isLoading
                                && (viewModel.selectedTab == .projects || viewModel.selectedTab == .all) {
                                EmptyFeedView(tab: viewModel.selectedTab)
                            }
                            
                            // Projects feed
                            ForEach(viewModel.feedProjects) { project in
                                ProjectCardView(
                                    project: project,
                                    onLike: { viewModel.likeProject(project) }
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            Color.clear.frame(height: 80)
                        }
                        .padding(.top, 4)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

// MARK: - Top Bar

private struct HomeTopBarView: View {
    var body: some View {
        HStack(spacing: 10) {
            
            // ESG Logo
            ZStack {
                Circle()
                    .strokeBorder(Color.primaryGreen, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Circle()
                    .strokeBorder(Color.primaryGreen.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 30, height: 30)
                Image(systemName: "globe.europe.africa.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(Color.primaryGreen)
            }
            
            Text("ESG Events")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(.label))
            
            Spacer()
            
            Button {
                // TODO: Notifications
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(.label))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "fbfbfb"))
    }
}

// MARK: - Tab Bar

private struct HomeTabBarView: View {
    @Binding var selectedTab: HomeTab
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(HomeTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
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

// MARK: - Upcoming Events Section

private struct UpcomingEventsSectionView: View {
    let events: [Event]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text("Upcoming Events")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                NavigationLink(destination: Text("All Events")) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.primaryGreen)
                }
            }
            .padding(.horizontal, 16)
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 220)
            } else if events.isEmpty {
                Text("No upcoming events")
                    .font(.bodyMedium)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal, 16)
                    .frame(height: 60)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(events) { event in
                            NavigationLink(destination: Text("Event detail: \(event.title)")) {
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

// MARK: - Event Card

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Top section: date + illustration
            HStack(alignment: .top, spacing: 0) {
                
                // Date + time
                VStack(spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryGreen)
                            .frame(width: 62, height: 62)
                        VStack(spacing: 0) {
                            Text(event.date.formatted("d"))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text(event.date.formatted("MMM"))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primaryGreen)
                            .frame(width: 62, height: 30)
                        Text(event.date.formatted("HH:mm"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 12)
                
                Spacer()
                
                // Stars + illustration
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.primaryGreen)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryGreen.opacity(0.1))
                            .frame(width: 96, height: 88)
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.primaryGreen.opacity(0.6))
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 12)
            }
            
            Color.clear.frame(height: 16)
            
            // Title
            Text(event.title)
                .font(.h6)
                .foregroundStyle(Color(.label))
                .lineLimit(2)
                .padding(.horizontal, 12)
            
            Color.clear.frame(height: 6)
            
            // Participants
            HStack(spacing: -8) {
                ForEach(0..<min(3, max(1, event.currentParticipants)), id: \.self) { _ in
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(.label))
                }
            }
            .padding(.leading, 12)
            
            Text("+\(event.currentParticipants) Going")
                .font(.bodySmall)
                .foregroundStyle(Color.primaryGreen)
                .padding(.leading, 12)
                .padding(.top, 2)
            
            Spacer(minLength: 10)
            
            // Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "e1e1e3"))
                Text(event.location ?? "")
                    .font(.bodySmall)
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .frame(width: 188, height: 242)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }
}

// MARK: - Project Card

private struct ProjectCardView: View {
    let project: Project
    let onLike: () -> Void
    
    @State private var shareItems: [Any]? = nil
    
    private var isLiked: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return project.isLikedBy(userId: uid)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Author row
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Color.primaryGreen)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("ESG-Campus")
                        .font(.h6)
                        .foregroundStyle(Color(.label))
                    Text(project.formattedDate)
                        .font(.bodySmall)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .fill(Color(hex: "f6f6f9"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 14)
            
            Color.clear.frame(height: 14)
            
            // MARK: - Content card
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            .frame(width: 52, height: 52)
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.h5)
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)
                        
                        Text(project.description)
                            .font(.bodyMedium)
                            .foregroundStyle(Color(.systemGray))
                            .lineLimit(3)
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 12)
                
                Color.clear.frame(height: 28)
                
                // Like + Respond
                HStack {
                    Button(action: onLike) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 15))
                                .foregroundStyle(isLiked ? Color.primaryGreen : Color(.systemGray))
                            Text("+\(project.liked.count)")
                                .font(.buttonMedium)
                                .foregroundStyle(Color.primaryGreen)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Link(destination: URL(string: project.responseLink.isEmpty ? "https://google.com" : project.responseLink) ?? URL(string: "https://google.com")!) {
                        HStack(spacing: 4) {
                            Text("Respond")
                                .font(.bodyMedium)
                                .foregroundStyle(Color(.systemGray))
                            Image(systemName: "envelope")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(.systemGray))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(hex: "f6f6f9"))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .padding(.horizontal, 12)
            
            Color.clear.frame(height: 10)
            
            // MARK: - Share button
            Button {
                shareItems = ["\(project.name)\n\(project.description)\n\(project.responseLink)"]
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.primaryGreen)
                    Text("Share")
                        .font(.buttonMedium)
                        .foregroundStyle(Color.primaryGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
        .sheet(item: Binding(
            get: { shareItems.map { ShareWrapper(items: $0) } },
            set: { if $0 == nil { shareItems = nil } }
        )) { wrapper in
            ActivityView(items: wrapper.items)
        }
    }
}

// MARK: - Live Event Row

private struct LiveEventRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primaryGreen)
                    .frame(width: 48, height: 48)
                VStack(spacing: 0) {
                    Text(event.date.formatted("d"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text(event.date.formatted("MMM"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.h6)
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.systemGray))
                    Text(event.date.formatted("HH:mm"))
                        .font(.bodySmall)
                        .foregroundStyle(Color(.systemGray))
                    
                    if let location = event.location {
                        Text("·")
                            .foregroundStyle(Color(.systemGray))
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.systemGray))
                        Text(location)
                            .font(.bodySmall)
                            .foregroundStyle(Color(.systemGray))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }
}

// MARK: - Empty Feed

private struct EmptyFeedView: View {
    let tab: HomeTab
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: tab == .live ? "antenna.radiowaves.left.and.right.slash" : "tray")
                .font(.system(size: 52))
                .foregroundStyle(Color(hex: "e1e1e3"))
            Text(tab == .live ? "No live events right now" : "Nothing here yet")
                .font(.bodyMedium)
                .foregroundStyle(Color(.systemGray))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Create Project View

struct CreateProjectView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var responseLink = ""
    @State private var isPosting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 24)
                        
                        // MARK: - Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Project Name")
                                .font(.bodyMedium)
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("", text: $name)
                                .font(.bodyLarge)
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Description")
                                .font(.bodyMedium)
                                .foregroundStyle(Color(.systemGray))
                            
                            TextEditor(text: $description)
                                .font(.bodyLarge)
                                .frame(height: 100)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Response Link
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Response Link")
                                .font(.bodyMedium)
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("https://", text: $responseLink)
                                .font(.bodyLarge)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        
                        Color.clear.frame(height: 32)
                        
                        // MARK: - Post Button
                        Button {
                            guard !name.isEmpty else { return }
                            isPosting = true
                            viewModel.createProject(name: name, description: description, responseLink: responseLink) { success in
                                isPosting = false
                                if success { dismiss() }
                            }
                        } label: {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Post Project")
                                    .font(.buttonLarge)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(name.isEmpty ? Color.primaryGreen.opacity(0.4) : Color.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .disabled(name.isEmpty || isPosting)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Color(.label))
            )
        }
    }
}

// MARK: - Share Helpers

private struct ShareWrapper: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    HomeView()
}
