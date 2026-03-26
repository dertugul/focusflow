import SwiftUI

struct FeedView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var clapAnimations: [String: Bool] = [:]

    let mockUsers = MockUser.samples
    let mockSessions = MockSession.samples(userID: "")

    var allSessions: [(FocusSession, User)] {
        var items: [(FocusSession, User)] = []
        // Your sessions
        for s in focusVM.sessions.prefix(5) {
            if let user = authVM.currentUser {
                items.append((s, user))
            }
        }
        // Mock sessions
        for s in mockSessions {
            if let user = mockUsers.first(where: { $0.id == s.userID }) {
                items.append((s, user))
            }
        }
        return items.sorted { $0.0.startedAt > $1.0.startedAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Team row
                        TeamMembersRow(users: mockUsers)

                        // Sessions feed
                        if allSessions.isEmpty {
                            VStack(spacing: 14) {
                                Text("🌅")
                                    .font(.system(size: 48))
                                    .padding(.top, 60)
                                Text("No sessions yet")
                                    .font(.custom("DM Serif Display", size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Complete a focus session to see it here")
                                    .font(.custom("DM Sans", size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(allSessions, id: \.0.id) { session, user in
                                    SessionFeedCard(
                                        session: session,
                                        user: user,
                                        isOwn: user.id == authVM.currentUser?.id,
                                        clapCount: focusVM.clapCount(for: session.id),
                                        clapAnimating: clapAnimations[session.id] ?? false
                                    ) {
                                        focusVM.addClap(for: session.id)
                                        withAnimation(.spring(response: 0.3)) {
                                            clapAnimations[session.id] = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            clapAnimations[session.id] = false
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}

struct TeamMembersRow: View {
    var users: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Team Members")
                .font(.custom("DM Sans", size: 13))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(users) { user in
                        VStack(spacing: 6) {
                            AvatarView(user: user, size: 48, showRing: true)
                            Text(user.name.components(separatedBy: " ").first ?? user.name)
                                .font(.custom("DM Sans", size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 4)
    }
}

struct SessionFeedCard: View {
    var session: FocusSession
    var user: User
    var isOwn: Bool
    var clapCount: Int
    var clapAnimating: Bool
    var onClap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                AvatarView(user: user, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(isOwn ? "You" : user.name)
                            .font(.custom("DM Sans", size: 14).weight(.semibold))
                            .foregroundColor(.white)
                        if isOwn {
                            Text("• you")
                                .font(.custom("DM Mono", size: 11))
                                .foregroundColor(Color(hex: "#F07A5A").opacity(0.7))
                        }
                    }
                    Text(session.startedAt, style: .relative)
                        .font(.custom("DM Mono", size: 11))
                        .foregroundColor(.white.opacity(0.35))
                }
                Spacer()
                CategoryPill(category: session.category)
            }

            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                Text("Focused for \(session.formattedDuration) on")
                    .font(.custom("DM Sans", size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }

            Text(session.taskText)
                .font(.custom("DM Sans", size: 14).weight(.medium))
                .foregroundColor(.white.opacity(0.9))

            if !isOwn {
                HStack {
                    Spacer()
                    Button(action: onClap) {
                        HStack(spacing: 6) {
                            Text("👏")
                                .font(.system(size: 18))
                                .scaleEffect(clapAnimating ? 1.4 : 1.0)
                            if clapCount > 0 {
                                Text("\(clapCount)")
                                    .font(.custom("DM Mono", size: 13))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
}
