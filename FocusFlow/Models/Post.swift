import Foundation

struct Post: Codable, Identifiable {
    var id: String = UUID().uuidString
    var userID: String
    var userName: String
    var userAvatarColor: String
    var content: String
    var category: TaskCategory?
    var groupID: String? = nil
    var likeCount: Int = 0
    var likedBy: [String] = []
    var comments: [Comment] = []
    var clapCount: Int = 0
    var createdAt: Date = Date()
}

struct Comment: Codable, Identifiable {
    var id: String = UUID().uuidString
    var userID: String
    var userName: String
    var text: String
    var createdAt: Date = Date()
}

struct MockPost {
    static let samples: [Post] = [
        Post(id: "p1", userID: "u1", userName: "Alex Chen", userAvatarColor: "#9B7EC8", content: "Just crushed a 45-min deep work session on the new design system. Flow state achieved! 🔥", category: .work, likeCount: 12, likedBy: [], clapCount: 8),
        Post(id: "p2", userID: "u2", userName: "Jordan Kim", userAvatarColor: "#F5C26A", content: "Finished chapter 5 of Atomic Habits. The habit stacking concept is game-changing.", category: .reading, likeCount: 7, likedBy: [], clapCount: 4),
        Post(id: "p3", userID: "u3", userName: "Sam Rivera", userAvatarColor: "#D4607E", content: "3 study sessions today, 2.5 hours total. Feeling really good about tomorrow's exam!", category: .study, likeCount: 15, likedBy: [], clapCount: 11),
        Post(id: "p4", userID: "u4", userName: "Morgan Lee", userAvatarColor: "#F07A5A", content: "Morning run + 20 min meditation. Starting the day right 🌅", category: .wellness, likeCount: 9, likedBy: [], clapCount: 6),
        Post(id: "p5", userID: "u5", userName: "Taylor Brooks", userAvatarColor: "#6BA3BE", content: "Meal prepped for the whole week in 90 minutes. Efficiency unlocked!", category: .home, likeCount: 5, likedBy: [], clapCount: 3)
    ]
}
