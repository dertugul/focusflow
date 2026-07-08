import SwiftUI

struct CreateGroupSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var selectedEmoji = "🧠"
    @State private var selectedColor = "#F07A5A"
    @FocusState private var focused: Bool

    let colorOptions = ["#F07A5A","#F5C26A","#D4607E","#9B7EC8","#6BA3BE","#7EC87E","#E8A05A","#A05AE8"]
    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#12080E").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: selectedColor).opacity(0.2))
                                .frame(width: 72, height: 72)
                            Text(selectedEmoji)
                                .font(.system(size: 36))
                        }
                        .padding(.top, 8)

                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            SectionLabel("Group Name")
                            TextField("e.g. Morning Readers", text: $name)
                                .font(.custom("DM Sans", size: 16)).foregroundColor(.white)
                                .tint(Color(hex: "#F07A5A")).focused($focused)
                                .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            SectionLabel("Description")
                            TextField("What's this group about?", text: $description, axis: .vertical)
                                .font(.custom("DM Sans", size: 15)).foregroundColor(.white)
                                .lineLimit(2...4).tint(Color(hex: "#F07A5A"))
                                .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Emoji picker
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Emoji")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                                ForEach(groupEmojiOptions, id: \.self) { emoji in
                                    Button(action: { selectedEmoji = emoji }) {
                                        Text(emoji)
                                            .font(.system(size: 24))
                                            .frame(width: 36, height: 36)
                                            .background(selectedEmoji == emoji ? Color.white.opacity(0.12) : Color.clear)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Color")
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(colorOptions, id: \.self) { hex in
                                    Button(action: { selectedColor = hex }) {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                selectedColor == hex ? Circle().stroke(Color.white, lineWidth: 2.5) : nil
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.white.opacity(0.5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createGroup() }
                        .font(.custom("DM Sans", size: 16).weight(.semibold))
                        .foregroundColor(name.isEmpty ? .white.opacity(0.3) : Color(hex: "#F07A5A"))
                        .disabled(name.isEmpty)
                }
            }
        }
        .onAppear { focused = true }
    }

    private func createGroup() {
        guard let user = authVM.currentUser, !name.isEmpty else { return }
        let group = FocusGroup(
            name: name,
            description: description,
            emoji: selectedEmoji,
            colorHex: selectedColor,
            memberIDs: [user.id],
            isCustom: true
        )
        appVM.addGroup(group)
        dismiss()
    }
}

struct SectionLabel: View {
    var text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.custom("DM Sans", size: 12))
            .foregroundColor(.white.opacity(0.45))
            .textCase(.uppercase)
            .tracking(1)
    }
}
