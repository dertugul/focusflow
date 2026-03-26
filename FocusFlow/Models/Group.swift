import Foundation

struct FocusGroup: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var emoji: String
    var colorHex: String
    var memberIDs: [String] = []
    var postIDs: [String] = []
    var createdAt: Date = Date()
    var isCustom: Bool = false

    var memberCount: Int { memberIDs.count }
    var postCount: Int { postIDs.count }
}

struct MockGroup {
    static let samples: [FocusGroup] = [
        FocusGroup(id: "g1", name: "Deep Workers", description: "Focus on deep, distraction-free work sessions", emoji: "🧠", colorHex: "#F07A5A", memberIDs: ["u1","u2","u3"], postIDs: ["p1","p2"]),
        FocusGroup(id: "g2", name: "Book Club", description: "Reading together, growing together", emoji: "📚", colorHex: "#F5C26A", memberIDs: ["u2","u3","u4","u5"], postIDs: ["p3"]),
        FocusGroup(id: "g3", name: "Study Squad", description: "Crush exams and learn new skills", emoji: "✏️", colorHex: "#9B7EC8", memberIDs: ["u1","u4"], postIDs: []),
        FocusGroup(id: "g4", name: "Wellness Warriors", description: "Mind, body, and spirit in balance", emoji: "🌿", colorHex: "#7EC87E", memberIDs: ["u1","u2","u5"], postIDs: ["p4","p5"]),
        FocusGroup(id: "g5", name: "Morning Crew", description: "Early risers building great habits", emoji: "🌅", colorHex: "#D4607E", memberIDs: ["u3","u4","u5"], postIDs: [])
    ]
}

let groupEmojiOptions = ["🧠","📚","✏️","🌿","🌅","💼","🎯","🚀","💡","🎨","🏃","🧘","📖","🏡","⚡","🌙"]
