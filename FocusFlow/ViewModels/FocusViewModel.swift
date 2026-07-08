import SwiftUI
import Combine

class FocusViewModel: ObservableObject {
    @Published var selectedTask: FocusTask? = nil
    @Published var isRunning: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var sessions: [FocusSession] = []
    @Published var clapCounts: [String: Int] = [:]

    private var timer: AnyCancellable?
    private let sessionsKey = "focusSessions"
    private let clapsKey = "clapCounts"
    let totalSeconds: Int = 25 * 60 // 25 minutes

    var progress: Double {
        guard elapsedSeconds > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(totalSeconds), 1.0)
    }

    var timeRemaining: String {
        let remaining = max(0, totalSeconds - elapsedSeconds)
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var todaySessions: [FocusSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.startedAt) }
    }

    init() {
        loadSessions()
        loadClaps()
    }

    func startTimer() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds += 1
                if self.elapsedSeconds >= self.totalSeconds {
                    self.pauseTimer()
                }
            }
    }

    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        elapsedSeconds = 0
    }

    func saveSession(userID: String, taskVM: TaskViewModel) {
        guard let task = selectedTask, elapsedSeconds > 0 else { return }
        pauseTimer()
        let session = FocusSession(
            taskID: task.id,
            taskText: task.text,
            category: task.category,
            duration: elapsedSeconds,
            startedAt: Date().addingTimeInterval(TimeInterval(-elapsedSeconds)),
            userID: userID
        )
        sessions.insert(session, at: 0)
        taskVM.addTimeToTask(id: task.id, seconds: elapsedSeconds)
        saveSessions()
        resetTimer()
    }

    func completeTaskAndSave(userID: String, taskVM: TaskViewModel) {
        guard let task = selectedTask else { return }
        saveSession(userID: userID, taskVM: taskVM)
        taskVM.completeTask(id: task.id)
        selectedTask = nil
    }

    func clapCount(for sessionID: String) -> Int {
        clapCounts[sessionID, default: 0]
    }

    func addClap(for sessionID: String) {
        clapCounts[sessionID, default: 0] += 1
        saveClaps()
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }

    func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }

    private func loadClaps() {
        if let data = UserDefaults.standard.data(forKey: clapsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            clapCounts = decoded
        }
    }

    private func saveClaps() {
        if let data = try? JSONEncoder().encode(clapCounts) {
            UserDefaults.standard.set(data, forKey: clapsKey)
        }
    }
}
