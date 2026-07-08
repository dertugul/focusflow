import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var category: TaskCategory = .work
    @State private var bookTitle = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Task text
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Task", systemImage: "pencil")
                                .font(.custom("DM Sans", size: 13))
                                .foregroundColor(.white.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)
                            TextField("What do you want to focus on?", text: $text, axis: .vertical)
                                .font(.custom("DM Sans", size: 16))
                                .foregroundColor(.white)
                                .lineLimit(3...6)
                                .tint(Color(hex: "#F07A5A"))
                                .padding(14)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .focused($focused)
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Category", systemImage: "tag")
                                .font(.custom("DM Sans", size: 13))
                                .foregroundColor(.white.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                ForEach(TaskCategory.allCases, id: \.self) { cat in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.25)) { category = cat }
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(cat.emoji).font(.system(size: 20))
                                            Text(cat.rawValue)
                                                .font(.custom("DM Sans", size: 12))
                                                .foregroundColor(category == cat ? Color(hex: cat.color) : .white.opacity(0.5))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(category == cat ? Color(hex: cat.color).opacity(0.12) : Color.white.opacity(0.04))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                            category == cat ? Color(hex: cat.color).opacity(0.5) : Color.white.opacity(0.07),
                                            lineWidth: 1
                                        ))
                                    }
                                }
                            }
                        }

                        // Book title (only for reading)
                        if category == .reading {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Book Title", systemImage: "book")
                                    .font(.custom("DM Sans", size: 13))
                                    .foregroundColor(.white.opacity(0.5))
                                    .textCase(.uppercase)
                                    .tracking(1)
                                TextField("Optional: book title", text: $bookTitle)
                                    .font(.custom("DM Sans", size: 15))
                                    .foregroundColor(.white)
                                    .tint(Color(hex: "#F5C26A"))
                                    .padding(14)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addTask) {
                        Text("Add")
                            .font(.custom("DM Sans", size: 16).weight(.semibold))
                            .foregroundColor(text.isEmpty ? .white.opacity(0.3) : Color(hex: "#F07A5A"))
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
        .onAppear { focused = true }
    }

    private func addTask() {
        let userID = authVM.currentUser?.id ?? ""
        taskVM.addTask(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            bookTitle: category == .reading && !bookTitle.isEmpty ? bookTitle : nil,
            userID: userID
        )
        dismiss()
    }
}
