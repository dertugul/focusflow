import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [FocusTask] = []
    @Published var selectedCategory: TaskCategory? = nil
    @Published var showAddTask: Bool = false

    private let tasksKey = "focusTasks"

    init() {
        loadTasks()
    }

    var userID: String = ""

    var filteredTasks: [FocusTask] {
        if let cat = selectedCategory {
            return tasks.filter { $0.category == cat && !$0.isDone }
        }
        return tasks.filter { !$0.isDone }
    }

    var completedTasks: [FocusTask] {
        tasks.filter { $0.isDone }
    }

    var todayTasks: [FocusTask] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDateInToday($0.createdAt) }
    }

    var completionPercentage: Double {
        let today = todayTasks
        guard !today.isEmpty else { return 0 }
        let done = today.filter { $0.isDone }.count
        return Double(done) / Double(today.count)
    }

    func addTask(text: String, category: TaskCategory, bookTitle: String? = nil, userID: String) {
        let task = FocusTask(text: text, category: category, bookTitle: bookTitle, userID: userID)
        tasks.insert(task, at: 0)
        saveTasks()
    }

    func completeTask(id: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].isDone = true
        tasks[idx].completedAt = Date()
        saveTasks()
    }

    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
        saveTasks()
    }

    func addTimeToTask(id: String, seconds: Int) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].timeSpent += seconds
        saveTasks()
    }

    func categoryBreakdown(sessions: [FocusSession]) -> [(TaskCategory, Int)] {
        var dict: [TaskCategory: Int] = [:]
        for s in sessions {
            dict[s.category, default: 0] += s.duration
        }
        return dict.sorted { $0.value > $1.value }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([FocusTask].self, from: data) {
            tasks = decoded
        }
    }

    func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }
}
