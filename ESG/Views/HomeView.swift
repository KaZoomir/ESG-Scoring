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
                Color(.systemBackground).ignoresSafeArea()
                
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
                            
                            // Empty state
                            if viewModel.feedProjects.isEmpty && !viewModel.isLoading
                                && (viewModel.selectedTab == .projects || viewModel.selectedTab == .all) {
                                EmptyFeedView()
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
// Matches Android EventCard: 260×260dp, date col + image side by side, time string field

struct EventCardView: View {
    let event: Event
    
    // Android uses event.time string field, not date formatting
    private var timeString: String {
        event.time.isEmpty ? "--:--" : event.time
    }
    
    // Android: event.registeredUsers?.size ?: 0
    private var participantCount: Int {
        event.registeredUsers.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Top row: date column + event_picture image side by side
            // Android: Row { Column{dateBox, timeBox} + Image(event_picture, height=132dp) }
            HStack(alignment: .top, spacing: 8) {
                
                // Left: date + time boxes
                // Android: Column { Box(60×56, green, rounded12) + Box(60×32, green, rounded8) }
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryGreen)
                            .frame(width: 60, height: 56)
                        VStack(spacing: 0) {
                            Text(event.dayNumber)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(event.monthName)
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primaryGreen)
                            .frame(width: 60, height: 32)
                        Text(timeString)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                
                // Right: event illustration — Android: Image(event_picture, height=132dp, ContentScale.Fit)
                Image("event_picture")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 132)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.leading, 20)
            .padding(.trailing, 2)
            .padding(.top, 8)
            
            Color.clear.frame(height: 20)
            
            // Title — Android: fontSize=18, fontWeight=W500
            Text(event.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(.label))
                .lineLimit(1)
                .padding(.horizontal, 20)
            
            Color.clear.frame(height: 4)
            
            // Participants — Android: repeat(3){ AccountCircle(28dp) } + Spacer(12) + "+N Going"
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(.label))
                    }
                }
                
                Color.clear.frame(width: 12)
                
                Text("+\(participantCount) Going")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.primaryGreen)
            }
            .padding(.leading, 20)
            
            Spacer(minLength: 0)
            
            // Location — Android: Row { LocationOn(gray_outline) + Text(event.location, gray_outline) }
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "e1e1e3"))
                Text(event.location ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "e1e1e3"))
                    .lineLimit(1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        // Android: width=260dp, height=260dp
        .frame(width: 260, height: 260)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "e1e1e3"), lineWidth: 1)
        )
    }
}

// MARK: - Project Card

struct ProjectCardView: View {
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
                    // Android: Box(52dp circle border) { Image(event_picture, ContentScale.Crop) }
                    Image("event_picture")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color(.systemGray4), lineWidth: 1))
                    
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

// MARK: - Empty Feed

private struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 52))
                .foregroundStyle(Color(hex: "e1e1e3"))
            Text("Nothing here yet")
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
