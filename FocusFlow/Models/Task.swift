import Foundation

struct FocusTask: Codable, Identifiable {
    var id: String = UUID().uuidString
    var text: String
    var category: TaskCategory
    var bookTitle: String? = nil
    var timeSpent: Int = 0  // seconds
    var isDone: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    var userID: String

    var formattedTimeSpent: String {
        let minutes = timeSpent / 60
        let seconds = timeSpent % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case work = "Work"
    case reading = "Reading"
    case study = "Study"
    case wellness = "Wellness"
    case home = "Home"
    case personal = "Personal"

    var color: String {
        switch self {
        case .work: return "#F07A5A"
        case .reading: return "#F5C26A"
        case .study: return "#9B7EC8"
        case .wellness: return "#7EC87E"
        case .home: return "#6BA3BE"
        case .personal: return "#D4607E"
        }
    }

    var emoji: String {
        switch self {
        case .work: return "💼"
        case .reading: return "📖"
        case .study: return "📚"
        case .wellness: return "🌿"
        case .home: return "🏡"
        case .personal: return "✨"
        }
    }
}
