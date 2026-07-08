import Foundation

struct FocusSession: Codable, Identifiable {
    var id: String = UUID().uuidString
    var taskID: String
    var taskText: String
    var category: TaskCategory
    var duration: Int  // seconds
    var startedAt: Date
    var userID: String

    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    var shortDuration: String {
        let minutes = duration / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

struct MockSession {
    static func samples(userID: String) -> [FocusSession] {
        [
            FocusSession(id: "ms1", taskID: "t1", taskText: "Design system review", category: .work, duration: 1500, startedAt: Date().addingTimeInterval(-3600), userID: "u1"),
            FocusSession(id: "ms2", taskID: "t2", taskText: "Chapter 5: Deep Work", category: .reading, duration: 1800, startedAt: Date().addingTimeInterval(-7200), userID: "u2"),
            FocusSession(id: "ms3", taskID: "t3", taskText: "Algorithm practice", category: .study, duration: 2700, startedAt: Date().addingTimeInterval(-10800), userID: "u3"),
            FocusSession(id: "ms4", taskID: "t4", taskText: "Morning yoga", category: .wellness, duration: 1200, startedAt: Date().addingTimeInterval(-14400), userID: "u4"),
            FocusSession(id: "ms5", taskID: "t5", taskText: "Meal prep", category: .home, duration: 900, startedAt: Date().addingTimeInterval(-18000), userID: "u5")
        ]
    }
}
