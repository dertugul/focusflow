import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showSettings = false
    @State private var showPostComposer = false
    @State private var selectedPhoto: PhotosPickerItem? = nil

    var user: User { authVM.currentUser ?? User(name: "You", email: "") }
    let friends = MockUser.samples

    var totalFocused: Int { focusVM.sessions.reduce(0) { $0 + $1.duration } }
    var completedTaskCount: Int { taskVM.tasks.filter { $0.isDone }.count }

    var personalPosts: [Post] {
        appVM.posts.filter { $0.userID == user.id && $0.groupID == nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar + info
                        VStack(spacing: 14) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                AvatarView(user: user, size: 90, showRing: true)
                                    .shadow(color: Color(hex: user.avatarColor).opacity(0.4), radius: 20)
                                    .overlay(alignment: .bottomTrailing) {
                                        ZStack {
                                            Circle().fill(Color(hex: "#F07A5A")).frame(width: 26, height: 26)
                                            Image(systemName: "camera.fill").font(.system(size: 11)).foregroundColor(.white)
                                        }
                                    }
                            }
                            .onChange(of: selectedPhoto) { item in
                                Task {
                                    if let data = try? await item?.loadTransferable(type: Data.self) {
                                        authVM.saveProfilePhoto(data)
                                    }
                                }
                            }

                            VStack(spacing: 4) {
                                Text(user.name.isEmpty ? "Your Name" : user.name)
                                    .font(.custom("DM Serif Display", size: 24))
                                    .foregroundColor(.white)
                                HStack(spacing: 6) {
                                    Text(user.team.emoji)
                                    Text(user.team.rawValue)
                                        .font(.custom("DM Sans", size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                if !user.bio.isEmpty {
                                    Text(user.bio)
                                        .font(.custom("DM Sans", size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                            }
                        }
                        .padding(.top, 8)

                        // Stats
                        HStack(spacing: 12) {
                            StatBadge(value: formatTime(totalFocused), label: "focused")
                            StatBadge(value: "\(focusVM.sessions.count)", label: "sessions")
                            StatBadge(value: "\(completedTaskCount)", label: "tasks done")
                        }
                        .padding(.horizontal, 20)

                        // Friends
                        FriendsRow(friends: friends)

                        // Post compose
                        Button(action: { showPostComposer = true }) {
                            HStack {
                                AvatarView(user: user, size: 32)
                                Text("Share your progress...")
                                    .font(.custom("DM Sans", size: 14))
                                    .foregroundColor(.white.opacity(0.35))
                                Spacer()
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color(hex: "#F07A5A"))
                            }
                            .padding(14)
                            .cardStyle()
                        }
                        .padding(.horizontal, 20)

                        // Personal posts
                        if personalPosts.isEmpty {
                            VStack(spacing: 10) {
                                Text("💬")
                                    .font(.system(size: 32))
                                Text("No posts yet")
                                    .font(.custom("DM Sans", size: 14))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            .padding(.top, 20)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(personalPosts) { post in
                                    PostCardView(
                                        post: post,
                                        currentUserID: user.id,
                                        onLike: { appVM.toggleLike(postID: post.id, userID: user.id) },
                                        onComment: {}
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .sheet(isPresented: $showPostComposer) {
            PersonalPostSheet()
        }
    }

    private func formatTime(_ s: Int) -> String {
        let h = s / 3600
        let m = (s % 3600) / 60
        if h > 0 { return "\(h)h\(m)m" }
        return "\(m)m"
    }
}

struct StatBadge: View {
    var value: String
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("DM Mono", size: 18).bold())
                .foregroundColor(.white)
            Text(label)
                .font(.custom("DM Sans", size: 11))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }
}

struct FriendsRow: View {
    var friends: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Friends")
                .font(.custom("DM Sans", size: 13))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(friends) { friend in
                        VStack(spacing: 6) {
                            AvatarView(user: friend, size: 44, showRing: true)
                            Text(friend.name.components(separatedBy: " ").first ?? friend.name)
                                .font(.custom("DM Sans", size: 11))
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PersonalPostSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var category: TaskCategory = .personal

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("What did you accomplish today?", text: $text, axis: .vertical)
                        .font(.custom("DM Sans", size: 16)).foregroundColor(.white)
                        .lineLimit(4...8).tint(Color(hex: "#F07A5A"))
                        .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TaskCategory.allCases, id: \.self) { cat in
                                Button(action: { category = cat }) {
                                    HStack(spacing: 4) {
                                        Text(cat.emoji).font(.system(size: 12))
                                        Text(cat.rawValue).font(.custom("DM Sans", size: 12))
                                            .foregroundColor(category == cat ? Color(hex: cat.color) : .white.opacity(0.4))
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(category == cat ? Color(hex: cat.color).opacity(0.15) : Color.white.opacity(0.05))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        guard let user = authVM.currentUser, !text.isEmpty else { return }
                        let post = Post(userID: user.id, userName: user.name, userAvatarColor: user.avatarColor, content: text, category: category)
                        appVM.addPost(post)
                        dismiss()
                    }
                    .font(.custom("DM Sans", size: 16).weight(.semibold))
                    .foregroundColor(text.isEmpty ? .white.opacity(0.3) : Color(hex: "#F07A5A"))
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}
