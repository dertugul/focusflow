import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Codable {
    case aurora = "Aurora"
    case embers = "Embers"
    case firstLight = "First Light"
    case roseHour = "Rose Hour"
    case goldenGate = "Golden Gate"
    case indigo = "Indigo"
    case dusk = "Dusk"
    case volcano = "Volcano"

    var colors: [Color] {
        switch self {
        case .aurora:     return [Color(hex: "#0D1B2A"), Color(hex: "#1B3A4B"), Color(hex: "#2D6A4F")]
        case .embers:     return [Color(hex: "#1A0A00"), Color(hex: "#3D1500"), Color(hex: "#6B2D0A")]
        case .firstLight: return [Color(hex: "#0D0D1A"), Color(hex: "#1A1040"), Color(hex: "#3D2060")]
        case .roseHour:   return [Color(hex: "#1A0D12"), Color(hex: "#3D1525"), Color(hex: "#6B2040")]
        case .goldenGate: return [Color(hex: "#1A0D00"), Color(hex: "#3D2000"), Color(hex: "#6B3A00")]
        case .indigo:     return [Color(hex: "#060B18"), Color(hex: "#0D1535"), Color(hex: "#1A2560")]
        case .dusk:       return [Color(hex: "#0D0A1A"), Color(hex: "#1A1535"), Color(hex: "#2D2050")]
        case .volcano:    return [Color(hex: "#1A0500"), Color(hex: "#3D0A00"), Color(hex: "#6B1000")]
        }
    }

    var previewColors: [Color] {
        switch self {
        case .aurora:     return [Color(hex: "#2D6A4F"), Color(hex: "#74C69D"), Color(hex: "#B7E4C7")]
        case .embers:     return [Color(hex: "#F07A5A"), Color(hex: "#F5C26A"), Color(hex: "#D4607E")]
        case .firstLight: return [Color(hex: "#9B7EC8"), Color(hex: "#C8A8E8"), Color(hex: "#F07A5A")]
        case .roseHour:   return [Color(hex: "#D4607E"), Color(hex: "#F07A5A"), Color(hex: "#F5C26A")]
        case .goldenGate: return [Color(hex: "#F5C26A"), Color(hex: "#F07A5A"), Color(hex: "#D4607E")]
        case .indigo:     return [Color(hex: "#4A6FA5"), Color(hex: "#9B7EC8"), Color(hex: "#6BA3BE")]
        case .dusk:       return [Color(hex: "#9B7EC8"), Color(hex: "#D4607E"), Color(hex: "#F07A5A")]
        case .volcano:    return [Color(hex: "#F07A5A"), Color(hex: "#D4607E"), Color(hex: "#F5C26A")]
        }
    }
}

class AppViewModel: ObservableObject {
    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: "appTheme") }
    }
    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "appLanguage") }
    }
    @Published var showDaySummary: Bool = false
    @Published var groups: [FocusGroup] = []
    @Published var posts: [Post] = []
    @Published var mockSessions: [FocusSession] = []

    private var summaryTimer: Timer?

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.embers.rawValue
        self.theme = AppTheme(rawValue: savedTheme) ?? .embers
        self.language = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        loadGroups()
        loadPosts()
        mockSessions = MockSession.samples(userID: "")
        scheduleDailySummary()
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func loadGroups() {
        if let data = UserDefaults.standard.data(forKey: "groups"),
           let decoded = try? JSONDecoder().decode([FocusGroup].self, from: data) {
            groups = decoded
        } else {
            groups = MockGroup.samples
        }
    }

    func saveGroups() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: "groups")
        }
    }

    func loadPosts() {
        if let data = UserDefaults.standard.data(forKey: "posts"),
           let decoded = try? JSONDecoder().decode([Post].self, from: data) {
            posts = decoded
        } else {
            posts = MockPost.samples
        }
    }

    func savePosts() {
        if let data = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(data, forKey: "posts")
        }
    }

    func addGroup(_ group: FocusGroup) {
        groups.insert(group, at: 0)
        saveGroups()
    }

    func toggleJoinGroup(groupID: String, userID: String) {
        guard let idx = groups.firstIndex(where: { $0.id == groupID }) else { return }
        if groups[idx].memberIDs.contains(userID) {
            groups[idx].memberIDs.removeAll { $0 == userID }
        } else {
            groups[idx].memberIDs.append(userID)
        }
        saveGroups()
    }

    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
        savePosts()
    }

    func toggleLike(postID: String, userID: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        if posts[idx].likedBy.contains(userID) {
            posts[idx].likedBy.removeAll { $0 == userID }
            posts[idx].likeCount = max(0, posts[idx].likeCount - 1)
        } else {
            posts[idx].likedBy.append(userID)
            posts[idx].likeCount += 1
        }
        savePosts()
    }

    func addComment(postID: String, comment: Comment) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[idx].comments.append(comment)
        savePosts()
    }

    func incrementClap(sessionID: String) {
        guard let idx = mockSessions.firstIndex(where: { $0.id == sessionID }) else { return }
        _ = idx // claps tracked separately in feed
    }

    private func scheduleDailySummary() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 21
        components.minute = 0
        if let fireDate = calendar.date(from: components), fireDate > Date() {
            let interval = fireDate.timeIntervalSinceNow
            summaryTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                let lastShown = UserDefaults.standard.string(forKey: "lastSummaryDate") ?? ""
                let today = DateFormatter.shortDate.string(from: Date())
                if lastShown != today {
                    self?.showDaySummary = true
                    UserDefaults.standard.set(today, forKey: "lastSummaryDate")
                }
            }
        }
    }

    func triggerSummary() {
        showDaySummary = true
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()
}
