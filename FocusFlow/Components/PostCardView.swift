import SwiftUI

struct PostCardView: View {
    var post: Post
    var currentUserID: String
    var onLike: () -> Void
    var onComment: () -> Void
    var showComments: Bool = false
    @State private var isLiked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                AvatarView(name: post.userName, colorHex: post.userAvatarColor, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.custom("DM Sans", size: 14).weight(.semibold))
                        .foregroundColor(.white)
                    Text(post.createdAt, style: .relative)
                        .font(.custom("DM Mono", size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                if let cat = post.category {
                    CategoryPill(category: cat)
                }
            }

            Text(post.content)
                .font(.custom("DM Sans", size: 14))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)

            HStack(spacing: 20) {
                Button(action: {
                    isLiked.toggle()
                    onLike()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "#D4607E") : .white.opacity(0.5))
                            .font(.system(size: 15))
                        Text("\(post.likeCount)")
                            .font(.custom("DM Mono", size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                Button(action: onComment) {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 15))
                        Text("\(post.comments.count)")
                            .font(.custom("DM Mono", size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
        .onAppear {
            isLiked = post.likedBy.contains(currentUserID)
        }
    }
}

struct CategoryPill: View {
    var category: TaskCategory
    var small: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Text(category.emoji)
                .font(.system(size: small ? 9 : 10))
            Text(category.rawValue)
                .font(.custom("DM Mono", size: small ? 9 : 10))
                .foregroundColor(Color(hex: category.color))
        }
        .padding(.horizontal, small ? 6 : 8)
        .padding(.vertical, small ? 3 : 4)
        .background(Color(hex: category.color).opacity(0.15))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color(hex: category.color).opacity(0.3), lineWidth: 0.5))
    }
}
