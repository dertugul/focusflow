import SwiftUI

struct TasksView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showAddTask = false
    @State private var showSummary = false
    @State private var showCompleted = false

    var hasTodaySessions: Bool {
        !focusVM.todaySessions.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Progress header
                        ProgressHeaderView(percentage: taskVM.completionPercentage, hasSessions: hasTodaySessions) {
                            showSummary = true
                        }

                        // Category filter
                        CategoryFilterRow(selected: $taskVM.selectedCategory)

                        // Tasks list
                        if taskVM.filteredTasks.isEmpty && taskVM.completedTasks.isEmpty {
                            EmptyTasksView()
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(taskVM.filteredTasks) { task in
                                    TaskRowView(task: task)
                                }
                            }
                            .padding(.horizontal, 20)

                            if !taskVM.completedTasks.isEmpty {
                                Button(action: { withAnimation { showCompleted.toggle() } }) {
                                    HStack {
                                        Text(showCompleted ? "Hide Completed" : "Show Completed (\(taskVM.completedTasks.count))")
                                            .font(.custom("DM Sans", size: 13))
                                            .foregroundColor(.white.opacity(0.4))
                                        Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                                .padding(.top, 8)

                                if showCompleted {
                                    LazyVStack(spacing: 10) {
                                        ForEach(taskVM.completedTasks) { task in
                                            CompletedTaskRow(task: task)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }

                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showAddTask = true }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "#F07A5A"), Color(hex: "#D4607E")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color(hex: "#F07A5A").opacity(0.4), radius: 12)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .semibold))
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
        .sheet(isPresented: $showSummary) {
            DaySummarySheet(isPresented: $showSummary)
        }
    }
}

struct ProgressHeaderView: View {
    var percentage: Double
    var hasSessions: Bool
    var onSummary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's Progress")
                    .font(.custom("DM Sans", size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1)
                Spacer()
                if hasSessions {
                    Button(action: onSummary) {
                        Text("See summary")
                            .font(.custom("DM Sans", size: 13))
                            .foregroundColor(Color(hex: "#F07A5A"))
                    }
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [Color(hex: "#F07A5A"), Color(hex: "#F5C26A")],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * percentage)
                        .animation(.spring(response: 0.6), value: percentage)
                }
                .frame(height: 8)
            }
            .frame(height: 8)

            Text("\(Int(percentage * 100))% complete")
                .font(.custom("DM Mono", size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .cardStyle()
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

struct CategoryFilterRow: View {
    @Binding var selected: TaskCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", emoji: nil, isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(TaskCategory.allCases, id: \.self) { cat in
                    FilterChip(label: cat.rawValue, emoji: cat.emoji, isSelected: selected == cat) {
                        selected = selected == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct FilterChip: View {
    var label: String
    var emoji: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let e = emoji { Text(e).font(.system(size: 12)) }
                Text(label)
                    .font(.custom("DM Sans", size: 13).weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color(hex: "#F07A5A").opacity(0.2) : Color.white.opacity(0.06))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(
                isSelected ? Color(hex: "#F07A5A").opacity(0.5) : Color.white.opacity(0.08),
                lineWidth: 1
            ))
        }
    }
}

struct TaskRowView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var authVM: AuthViewModel
    var task: FocusTask
    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // Swipe background
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#7EC87E").opacity(0.2))
            HStack {
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(Color(hex: "#7EC87E"))
                    .padding(.trailing, 20)
            }

            // Main card
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(hex: task.category.color))
                    .frame(width: 3)
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.text)
                        .font(.custom("DM Sans", size: 15).weight(.medium))
                        .foregroundColor(.white)
                    HStack(spacing: 8) {
                        CategoryPill(category: task.category, small: true)
                        if let book = task.bookTitle, !book.isEmpty {
                            Text("📖 " + book)
                                .font(.custom("DM Mono", size: 10))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        if task.timeSpent > 0 {
                            Text(task.formattedTimeSpent)
                                .font(.custom("DM Mono", size: 10))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }
                }

                Spacer()

                // Play button
                Button(action: {
                    focusVM.selectedTask = task
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#F07A5A").opacity(0.15))
                            .frame(width: 36, height: 36)
                        PlayShape()
                            .fill(Color(hex: "#F07A5A"))
                            .frame(width: 12, height: 14)
                            .offset(x: 1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 1, green: 220/255, blue: 180/255).opacity(0.08), lineWidth: 1))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -60 {
                            withAnimation(.spring()) {
                                taskVM.completeTask(id: task.id)
                            }
                        } else {
                            withAnimation(.spring()) { offset = 0 }
                        }
                    }
            )
        }
    }
}

struct CompletedTaskRow: View {
    var task: FocusTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#7EC87E"))
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .font(.custom("DM Sans", size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .strikethrough(true, color: .white.opacity(0.2))
                if task.timeSpent > 0 {
                    Text(task.formattedTimeSpent + " focused")
                        .font(.custom("DM Mono", size: 11))
                        .foregroundColor(.white.opacity(0.25))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("🌅")
                .font(.system(size: 48))
            Text("No tasks yet")
                .font(.custom("DM Serif Display", size: 22))
                .foregroundColor(.white.opacity(0.7))
            Text("Tap + to add your first task")
                .font(.custom("DM Sans", size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
    }
}
