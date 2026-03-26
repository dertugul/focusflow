import SwiftUI
import Foundation

struct User: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var bio: String = ""
    var avatarColor: String = "#F07A5A"
    var team: Team = .flowState
    var photoData: Data? = nil
    var friendIDs: [String] = []
    var joinedGroupIDs: [String] = []
    var createdAt: Date = Date()

    enum Team: String, Codable, CaseIterable {
        case theStack = "The Stack"
        case flowState = "Flow State"
        case pageTurners = "Page Turners"
        case nest = "Nest"

        var description: String {
            switch self {
            case .theStack: return "study"
            case .flowState: return "work"
            case .pageTurners: return "reading"
            case .nest: return "home"
            }
        }

        var emoji: String {
            switch self {
            case .theStack: return "📚"
            case .flowState: return "💼"
            case .pageTurners: return "📖"
            case .nest: return "🏡"
            }
        }
    }
}

struct MockUser {
    static let samples: [User] = [
        User(id: "u1", name: "Alex Chen", email: "alex@example.com", avatarColor: "#9B7EC8", team: .flowState),
        User(id: "u2", name: "Jordan Kim", email: "jordan@example.com", avatarColor: "#F5C26A", team: .theStack),
        User(id: "u3", name: "Sam Rivera", email: "sam@example.com", avatarColor: "#D4607E", team: .pageTurners),
        User(id: "u4", name: "Morgan Lee", email: "morgan@example.com", avatarColor: "#F07A5A", team: .nest),
        User(id: "u5", name: "Taylor Brooks", email: "taylor@example.com", avatarColor: "#6BA3BE", team: .flowState)
    ]
}
