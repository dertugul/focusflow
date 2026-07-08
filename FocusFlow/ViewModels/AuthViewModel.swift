import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var showOnboarding: Bool = false
    @Published var onboardingStep: Int = 0
    @Published var errorMessage: String = ""

    // Onboarding state
    @Published var onboardingName: String = ""
    @Published var onboardingAvatarColor: String = "#F07A5A"
    @Published var onboardingTeam: User.Team = .flowState

    private let userKey = "currentUser"
    private let credentialsKey = "userCredentials"

    init() {
        loadSession()
    }

    private func loadSession() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    func signUp(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        // Store credentials
        let credentials = ["email": email, "password": password]
        if let data = try? JSONEncoder().encode(credentials) {
            UserDefaults.standard.set(data, forKey: credentialsKey)
        }
        let user = User(name: "", email: email)
        self.currentUser = user
        self.showOnboarding = true
        self.errorMessage = ""
    }

    func signIn(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        // Validate against stored credentials
        if let data = UserDefaults.standard.data(forKey: credentialsKey),
           let creds = try? JSONDecoder().decode([String: String].self, from: data),
           creds["email"] == email, creds["password"] == password {
            loadSession()
            errorMessage = ""
        } else if let data = UserDefaults.standard.data(forKey: userKey),
                  let user = try? JSONDecoder().decode(User.self, from: data),
                  user.email == email {
            self.currentUser = user
            self.isAuthenticated = true
            self.errorMessage = ""
        } else {
            errorMessage = "Invalid credentials"
        }
    }

    func completeOnboarding() {
        guard var user = currentUser else { return }
        user.name = onboardingName
        user.avatarColor = onboardingAvatarColor
        user.team = onboardingTeam
        self.currentUser = user
        saveUser(user)
        self.showOnboarding = false
        self.isAuthenticated = true
    }

    func updateUser(_ user: User) {
        self.currentUser = user
        saveUser(user)
    }

    func signOut() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.showOnboarding = false
        UserDefaults.standard.removeObject(forKey: userKey)
    }

    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func saveProfilePhoto(_ data: Data) {
        guard var user = currentUser else { return }
        user.photoData = data
        updateUser(user)
    }
}
