import SwiftUI

struct GroupDetailView: View {
    var group: FocusGroup
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showNewPost = false
    @State private var commentPostID: String? = nil
    @State private var commentText = ""

    var userID: String { authVM.currentUser?.id ?? "" }
    var isJoined: Bool {
        appVM.groups.first(where: { $0.id == group.id })?.memberIDs.contains(userID) ?? false
    }
    var groupPosts: [Post] {
        appVM.posts.filter { $0.groupID == group.id }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#12080E"), Color(hex: "#1A0D12")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: group.colorHex).opacity(0.18))
                                .frame(width: 72, height: 72)
                            Text(group.emoji)
                                .font(.system(size: 36))
                        }
                        Text(group.name)
                            .font(.custom("DM Serif Display", size: 24))
                            .foregroundColor(.white)
                        Text(group.description)
                            .font(.custom("DM Sans", size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 20) {
                            Label("\(appVM.groups.first(where: { $0.id == group.id })?.memberCount ?? group.memberCount) members", systemImage: "person.2")
                                .font(.custom("DM Mono", size: 12))
                                .foregroundColor(.white.opacity(0.4))
                            Label("\(groupPosts.count) posts", systemImage: "text.bubble")
                                .font(.custom("DM Mono", size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }

                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                appVM.toggleJoinGroup(groupID: group.id, userID: userID)
                            }
                        }) {
                            Text(isJoined ? "Leave Group" : "Join Group")
                                .font(.custom("DM Sans", size: 14).weight(.semibold))
                                .foregroundColor(isJoined ? .white.opacity(0.6) : .white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    isJoined ? Color.white.opacity(0.08) :
                                    LinearGradient(colors: [Color(hex: group.colorHex), Color(hex: group.colorHex).opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 8)

                    // Post button
                    if isJoined {
                        Button(action: { showNewPost = true }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color(hex: "#F07A5A"))
                                Text("Share something with the group...")
                                    .font(.custom("DM Sans", size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                                Spacer()
                            }
                            .padding(14)
                            .cardStyle()
                        }
                        .padding(.horizontal, 20)
                    }

                    // Posts
                    if groupPosts.isEmpty {
                        VStack(spacing: 10) {
                            Text("💬")
                                .font(.system(size: 36))
                            Text("No posts yet")
                                .font(.custom("DM Sans", size: 14))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(groupPosts) { post in
                                VStack(alignment: .leading, spacing: 0) {
                                    PostCardView(
                                        post: post,
                                        currentUserID: userID,
                                        onLike: { appVM.toggleLike(postID: post.id, userID: userID) },
                                        onComment: { commentPostID = post.id }
                                    )

                                    // Comments
                                    if !post.comments.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(post.comments) { comment in
                                                HStack(alignment: .top, spacing: 8) {
                                                    Circle()
                                                        .fill(Color(hex: "#F07A5A").opacity(0.6))
                                                        .frame(width: 24, height: 24)
                                                        .overlay(Text(String(comment.userName.prefix(1))).font(.system(size: 10)).foregroundColor(.white))
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(comment.userName)
                                                            .font(.custom("DM Sans", size: 12).weight(.semibold))
                                                            .foregroundColor(.white.opacity(0.7))
                                                        Text(comment.text)
                                                            .font(.custom("DM Sans", size: 12))
                                                            .foregroundColor(.white.opacity(0.5))
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 12)
                                        .background(Color.white.opacity(0.02))
                                    }
                                }
                                .cardStyle()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewPost) {
            NewGroupPostSheet(groupID: group.id)
        }
        .sheet(item: Binding(
            get: { commentPostID.map { CommentTarget(id: $0) } },
            set: { commentPostID = $0?.id }
        )) { target in
            CommentSheet(postID: target.id)
        }
    }
}

struct CommentTarget: Identifiable {
    var id: String
}

struct NewGroupPostSheet: View {
    var groupID: String
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var category: TaskCategory = .work

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()
                VStack(spacing: 20) {
                    TextField("What's on your mind?", text: $text, axis: .vertical)
                        .font(.custom("DM Sans", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(4...8)
                        .tint(Color(hex: "#F07A5A"))
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TaskCategory.allCases, id: \.self) { cat in
                                Button(action: { category = cat }) {
                                    HStack(spacing: 4) {
                                        Text(cat.emoji).font(.system(size: 12))
                                        Text(cat.rawValue).font(.custom("DM Sans", size: 12)).foregroundColor(category == cat ? Color(hex: cat.color) : .white.opacity(0.4))
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
                        let post = Post(
                            userID: user.id, userName: user.name,
                            userAvatarColor: user.avatarColor,
                            content: text, category: category, groupID: groupID
                        )
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

struct CommentSheet: View {
    var postID: String
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @FocusState private var focused: Bool

    var post: Post? { appVM.posts.first(where: { $0.id == postID }) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()
                VStack(spacing: 0) {
                    if let post = post {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(post.comments) { comment in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle().fill(Color(hex: "#F07A5A").opacity(0.5)).frame(width: 32, height: 32)
                                            .overlay(Text(String(comment.userName.prefix(1))).font(.system(size: 13)).foregroundColor(.white))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(comment.userName).font(.custom("DM Sans", size: 13).weight(.semibold)).foregroundColor(.white.opacity(0.8))
                                            Text(comment.text).font(.custom("DM Sans", size: 13)).foregroundColor(.white.opacity(0.6))
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                }
                                if post.comments.isEmpty {
                                    Text("No comments yet").font(.custom("DM Sans", size: 14)).foregroundColor(.white.opacity(0.3)).padding(.top, 40)
                                }
                            }
                            .padding(.top, 16)
                        }
                    }
                    // Input
                    HStack(spacing: 10) {
                        TextField("Add a comment...", text: $text)
                            .font(.custom("DM Sans", size: 14)).foregroundColor(.white)
                            .tint(Color(hex: "#F07A5A")).focused($focused)
                            .padding(12).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 10))
                        Button(action: addComment) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(text.isEmpty ? .white.opacity(0.3) : Color(hex: "#F07A5A")).font(.system(size: 18))
                        }.disabled(text.isEmpty)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(Color.white.opacity(0.04))
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.foregroundColor(.white.opacity(0.5)) } }
        }
        .onAppear { focused = true }
    }

    private func addComment() {
        guard let user = authVM.currentUser, !text.isEmpty else { return }
        let comment = Comment(userID: user.id, userName: user.name, text: text)
        appVM.addComment(postID: postID, comment: comment)
        text = ""
    }
}
