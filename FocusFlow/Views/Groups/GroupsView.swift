import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showCreateGroup = false
    @State private var selectedGroup: FocusGroup? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                appVM.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appVM.groups) { group in
                            Button(action: { selectedGroup = group }) {
                                GroupRowCard(group: group, isJoined: group.memberIDs.contains(authVM.currentUser?.id ?? ""))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 100)
                }

                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCreateGroup = true }) {
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
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .navigationDestination(item: $selectedGroup) { group in
                GroupDetailView(group: group)
            }
        }
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupSheet()
        }
    }
}

struct GroupRowCard: View {
    var group: FocusGroup
    var isJoined: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: group.colorHex).opacity(0.2))
                    .frame(width: 50, height: 50)
                Text(group.emoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(group.name)
                        .font(.custom("DM Sans", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                    if isJoined {
                        Text("Joined")
                            .font(.custom("DM Mono", size: 9))
                            .foregroundColor(Color(hex: group.colorHex))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: group.colorHex).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(group.description)
                    .font(.custom("DM Sans", size: 12))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(1)
                HStack(spacing: 10) {
                    Label("\(group.memberCount)", systemImage: "person.2")
                        .font(.custom("DM Mono", size: 11))
                        .foregroundColor(.white.opacity(0.35))
                    Label("\(group.postCount)", systemImage: "text.bubble")
                        .font(.custom("DM Mono", size: 11))
                        .foregroundColor(.white.opacity(0.35))
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(14)
        .cardStyle()
    }
}
