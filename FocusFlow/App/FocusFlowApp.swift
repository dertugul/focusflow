import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var appVM = AppViewModel()
    @StateObject private var taskVM = TaskViewModel()
    @StateObject private var focusVM = FocusViewModel()

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environmentObject(authVM)
                .environmentObject(appVM)
                .environmentObject(taskVM)
                .environmentObject(focusVM)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentRootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                MainTabView()
            } else if authVM.showOnboarding {
                OnboardingView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authVM.isAuthenticated)
    }
}
