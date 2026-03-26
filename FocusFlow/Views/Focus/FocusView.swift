import SwiftUI

struct FocusView: View {
    @EnvironmentObject var focusVM: FocusViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showTaskPicker = false

    var buttonColors: (Color, Color) {
        if focusVM.isRunning {
            return (Color(hex: "#D4607E"), Color(hex: "#9B7EC8"))
        } else {
            return (Color(hex: "#F07A5A"), Color(hex: "#F5C26A"))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Task selector
                    if let task = focusVM.selectedTask {
                        SelectedTaskCard(task: task) {
                            showTaskPicker = true
                        }
                    } else {
                        Button(action: { showTaskPicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color(hex: "#F07A5A"))
                                Text("Select a task to focus on")
                                    .font(.custom("DM Sans", size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.25))
                                    .font(.system(size: 13))
                            }
                            .padding(16)
                            .cardStyle()
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Ring timer
                    RingTimerView(
                        progress: focusVM.progress,
                        isRunning: focusVM.isRunning,
                        timeString: focusVM.timeRemaining
                    )

                    Spacer()

                    // Controls
                    VStack(spacing: 16) {
                        // Play/Pause button
                        Button(action: toggleTimer) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [buttonColors.0, buttonColors.1],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: buttonColors.0.opacity(0.5), radius: 20)

                                if focusVM.isRunning {
                                    PauseShape()
                                        .fill(Color.white)
                                        .frame(width: 22, height: 22)
                                } else {
                                    PlayShape()
                                        .fill(Color.white)
                                        .frame(width: 22, height: 26)
                                        .offset(x: 2)
                                }
                            }
                        }
                        .breatheEffect(isActive: focusVM.isRunning)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: focusVM.isRunning)

                        // Action row
                        HStack(spacing: 24) {
                            if focusVM.elapsedSeconds > 0 {
                                // Save session
                                ActionButton(icon: "plus.circle", label: "Save", color: Color(hex: "#F5C26A")) {
                                    focusVM.saveSession(userID: authVM.currentUser?.id ?? "", taskVM: taskVM)
                                }

                                // Complete task
                                if focusVM.selectedTask != nil {
                                    ActionButton(icon: "checkmark.circle", label: "Complete", color: Color(hex: "#7EC87E")) {
                                        focusVM.completeTaskAndSave(userID: authVM.currentUser?.id ?? "", taskVM: taskVM)
                                    }
                                }

                                // Reset
                                ActionButton(icon: "arrow.counterclockwise", label: "Reset", color: .white.opacity(0.4)) {
                                    focusVM.resetTimer()
                                }
                            }
                        }
                        .animation(.spring(response: 0.3), value: focusVM.elapsedSeconds > 0)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet()
        }
    }

    private func toggleTimer() {
        if focusVM.isRunning {
            focusVM.pauseTimer()
        } else {
            focusVM.startTimer()
        }
    }
}

struct SelectedTaskCard: View {
    var task: FocusTask
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color(hex: task.category.color))
                    .frame(width: 3)
                    .clipShape(Capsule())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focusing on")
                        .font(.custom("DM Mono", size: 10))
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(1)
                    Text(task.text)
                        .font(.custom("DM Sans", size: 15).weight(.medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                Spacer()
                CategoryPill(category: task.category, small: true)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .cardStyle()
        }
        .padding(.horizontal, 24)
    }
}

struct ActionButton: View {
    var icon: String
    var label: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                Text(label)
                    .font(.custom("DM Mono", size: 10))
                    .foregroundColor(color.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(1)
            }
        }
    }
}

struct TaskPickerSheet: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @Environment(\.dismiss) var dismiss

    var incompleteTasks: [FocusTask] {
        taskVM.tasks.filter { !$0.isDone }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()

                if incompleteTasks.isEmpty {
                    VStack(spacing: 14) {
                        Text("🌅")
                            .font(.system(size: 48))
                        Text("No tasks to focus on")
                            .font(.custom("DM Serif Display", size: 20))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Add tasks in the Tasks tab first")
                            .font(.custom("DM Sans", size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(incompleteTasks) { task in
                                Button(action: {
                                    focusVM.selectedTask = task
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        Rectangle()
                                            .fill(Color(hex: task.category.color))
                                            .frame(width: 3)
                                            .clipShape(Capsule())
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.text)
                                                .font(.custom("DM Sans", size: 15).weight(.medium))
                                                .foregroundColor(.white)
                                            CategoryPill(category: task.category, small: true)
                                        }
                                        Spacer()
                                        if focusVM.selectedTask?.id == task.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(hex: "#F07A5A"))
                                        }
                                    }
                                    .padding(14)
                                    .cardStyle()
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Pick a Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
}
