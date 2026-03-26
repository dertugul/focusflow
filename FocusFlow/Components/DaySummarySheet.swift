import SwiftUI

struct DaySummarySheet: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isPresented: Bool
    @State private var animateBars: Bool = false

    var todaySessions: [FocusSession] { focusVM.todaySessions }
    var todayTasks: [FocusTask] { taskVM.todayTasks }
    var doneTasks: [FocusTask] { todayTasks.filter { $0.isDone } }
    var totalFocusSeconds: Int { todaySessions.reduce(0) { $0 + $1.duration } }

    var categoryBreakdown: [(TaskCategory, Int)] {
        taskVM.categoryBreakdown(sessions: todaySessions)
    }

    var topCategory: TaskCategory? { categoryBreakdown.first?.0 }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 6) {
                            Text(greeting + "!")
                                .font(.custom("DM Serif Display", size: 28))
                                .foregroundColor(.white)
                            Text(Date(), style: .date)
                                .font(.custom("DM Mono", size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 8)

                        // Stats row
                        HStack(spacing: 16) {
                            SummaryStatCard(value: formatTime(totalFocusSeconds), label: "focused")
                            SummaryStatCard(value: "\(doneTasks.count)/\(todayTasks.count)", label: "tasks done")
                            SummaryStatCard(value: "\(todaySessions.count)", label: "sessions")
                        }

                        // Category breakdown
                        if !categoryBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time by Category")
                                    .font(.custom("DM Serif Display", size: 18))
                                    .foregroundColor(.white)

                                ForEach(categoryBreakdown, id: \.0) { cat, secs in
                                    CategoryBar(category: cat, seconds: secs, total: totalFocusSeconds, animate: animateBars)
                                }
                            }
                            .padding(16)
                            .cardStyle()
                        }

                        // Top category highlight
                        if let top = topCategory {
                            Text("Your top focus today was \(top.emoji) \(top.rawValue). Keep the momentum going!")
                                .font(.custom("DM Sans", size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }

                        // Completed tasks
                        if !doneTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Completed Tasks")
                                    .font(.custom("DM Serif Display", size: 18))
                                    .foregroundColor(.white)

                                ForEach(doneTasks) { task in
                                    HStack {
                                        CategoryPill(category: task.category, small: true)
                                        Text(task.text)
                                            .font(.custom("DM Sans", size: 13))
                                            .foregroundColor(.white.opacity(0.8))
                                        Spacer()
                                        Text(task.formattedTimeSpent)
                                            .font(.custom("DM Mono", size: 12))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                            .padding(16)
                            .cardStyle()
                        }

                        if todaySessions.isEmpty && doneTasks.isEmpty {
                            VStack(spacing: 12) {
                                Text("🌅")
                                    .font(.system(size: 48))
                                Text("Nothing logged yet today\nStart a focus session to track your day!")
                                    .font(.custom("DM Sans", size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Day Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                        .foregroundColor(Color(hex: "#F07A5A"))
                        .font(.custom("DM Sans", size: 16).weight(.semibold))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateBars = true
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct SummaryStatCard: View {
    var value: String
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("DM Mono", size: 20).bold())
                .foregroundColor(.white)
            Text(label)
                .font(.custom("DM Sans", size: 11))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }
}

struct CategoryBar: View {
    var category: TaskCategory
    var seconds: Int
    var total: Int
    var animate: Bool

    var fraction: Double {
        total > 0 ? Double(seconds) / Double(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category.emoji + " " + category.rawValue)
                    .font(.custom("DM Sans", size: 13))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(formatTime(seconds))
                    .font(.custom("DM Mono", size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.06))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: category.color))
                        .frame(width: animate ? geo.size.width * fraction : 0)
                }
            }
            .frame(height: 8)
        }
    }

    private func formatTime(_ s: Int) -> String {
        let m = s / 60
        if m >= 60 { return "\(m/60)h \(m%60)m" }
        return "\(m)m"
    }
}
