import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var focusVM: FocusViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TasksView()
                    .tag(0)
                FocusView()
                    .tag(1)
                FeedView()
                    .tag(2)
                GroupsView()
                    .tag(3)
                ProfileView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom frosted tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $appVM.showDaySummary) {
            DaySummarySheet(isPresented: $appVM.showDaySummary)
        }
        .onAppear {
            if let uid = authVM.currentUser?.id {
                taskVM.userID = uid
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("checklist", "Tasks"),
        ("timer", "Focus"),
        ("person.2", "Feed"),
        ("rectangle.3.group", "Groups"),
        ("person.circle", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = i
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: selectedTab == i ? 22 : 20, weight: selectedTab == i ? .semibold : .regular))
                            .foregroundColor(selectedTab == i ? Color(hex: "#F07A5A") : .white.opacity(0.35))
                            .scaleEffect(selectedTab == i ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)

                        Text(tabs[i].label)
                            .font(.custom("DM Sans", size: 10))
                            .foregroundColor(selectedTab == i ? Color(hex: "#F07A5A") : .white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
        }
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                VStack {
                    LinearGradient(
                        colors: [Color(hex: "#F07A5A").opacity(0.15), Color.clear],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 1)
                    Spacer()
                }
            }
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(red: 1, green: 220/255, blue: 180/255).opacity(0.12)),
            alignment: .top
        )
    }
}
