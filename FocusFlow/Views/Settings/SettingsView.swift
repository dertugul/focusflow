import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var selectedAvatarColor: String = "#F07A5A"
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showSignOutConfirm = false
    @State private var saved = false
    @Environment(\.dismiss) var dismiss

    let avatarColors = ["#F07A5A","#F5C26A","#D4607E","#9B7EC8","#6BA3BE","#7EC87E","#E8A05A","#A05AE8"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#0D0A1A"), Color(hex: "#1A1035")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Profile section
                    VStack(spacing: 16) {
                        SettingsSectionHeader("Profile")

                        // Photo
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 12) {
                                AvatarView(user: authVM.currentUser, size: 52)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Profile Photo")
                                        .font(.custom("DM Sans", size: 15))
                                        .foregroundColor(.white)
                                    Text("Tap to change")
                                        .font(.custom("DM Sans", size: 12))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.25))
                                    .font(.system(size: 13))
                            }
                            .padding(14)
                            .cardStyle()
                        }
                        .onChange(of: selectedPhoto) { item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self) {
                                    authVM.saveProfilePhoto(data)
                                }
                            }
                        }

                        // Name
                        SettingsTextField(label: "Display Name", placeholder: "Your name", text: $displayName)

                        // Bio
                        SettingsTextField(label: "Bio", placeholder: "A bit about yourself...", text: $bio)

                        // Avatar color
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Avatar Color")
                                .font(.custom("DM Sans", size: 13))
                                .foregroundColor(.white.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)

                            HStack(spacing: 12) {
                                ForEach(avatarColors, id: \.self) { hex in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.25)) { selectedAvatarColor = hex }
                                    }) {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                selectedAvatarColor == hex ? Circle().stroke(Color.white, lineWidth: 2.5) : nil
                                            )
                                            .scaleEffect(selectedAvatarColor == hex ? 1.1 : 1.0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)

                        // Save profile button
                        Button(action: saveProfile) {
                            HStack {
                                Image(systemName: saved ? "checkmark" : "square.and.arrow.down")
                                Text(saved ? "Saved!" : "Save Profile")
                            }
                            .font(.custom("DM Sans", size: 15).weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                saved ? Color(hex: "#7EC87E").opacity(0.3) :
                                LinearGradient(colors: [Color(hex: "#F07A5A"), Color(hex: "#D4607E")], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Language section
                    VStack(spacing: 12) {
                        SettingsSectionHeader("Language")

                        HStack(spacing: 10) {
                            ForEach([("en", "🇬🇧 English"), ("tr", "🇹🇷 Türkçe")], id: \.0) { code, label in
                                Button(action: {
                                    withAnimation(.spring(response: 0.25)) { appVM.language = code }
                                }) {
                                    Text(label)
                                        .font(.custom("DM Sans", size: 14).weight(appVM.language == code ? .semibold : .regular))
                                        .foregroundColor(appVM.language == code ? .white : .white.opacity(0.45))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(appVM.language == code ? Color(hex: "#F07A5A").opacity(0.18) : Color.white.opacity(0.04))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                                            appVM.language == code ? Color(hex: "#F07A5A").opacity(0.4) : Color.white.opacity(0.07), lineWidth: 1))
                                }
                            }
                        }
                    }

                    // Theme section
                    VStack(spacing: 12) {
                        SettingsSectionHeader("Background Theme")

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 14) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) { appVM.theme = theme }
                                }) {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(AngularGradient(
                                                    colors: theme.previewColors + [theme.previewColors[0]],
                                                    center: .center
                                                ))
                                                .frame(width: 52, height: 52)
                                                .overlay(
                                                    appVM.theme == theme ?
                                                    Circle().stroke(Color.white, lineWidth: 2.5) : nil
                                                )
                                        }
                                        Text(theme.rawValue)
                                            .font(.custom("DM Sans", size: 9))
                                            .foregroundColor(appVM.theme == theme ? .white : .white.opacity(0.4))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                    }

                    // Account section
                    VStack(spacing: 12) {
                        SettingsSectionHeader("Account")

                        Button(action: { showSignOutConfirm = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(Color(hex: "#D4607E"))
                                Text("Sign Out")
                                    .font(.custom("DM Sans", size: 15))
                                    .foregroundColor(Color(hex: "#D4607E"))
                                Spacer()
                            }
                            .padding(14)
                            .cardStyle()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .onAppear { loadCurrentValues() }
        .alert("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { authVM.signOut() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    private func loadCurrentValues() {
        displayName = authVM.currentUser?.name ?? ""
        bio = authVM.currentUser?.bio ?? ""
        selectedAvatarColor = authVM.currentUser?.avatarColor ?? "#F07A5A"
    }

    private func saveProfile() {
        guard var user = authVM.currentUser else { return }
        user.name = displayName
        user.bio = bio
        user.avatarColor = selectedAvatarColor
        authVM.updateUser(user)
        withAnimation { saved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { saved = false }
        }
    }
}

struct SettingsSectionHeader: View {
    var title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("DM Serif Display", size: 18))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct SettingsTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("DM Sans", size: 12))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
                .tracking(1)
            TextField(placeholder, text: $text)
                .font(.custom("DM Sans", size: 15))
                .foregroundColor(.white)
                .tint(Color(hex: "#F07A5A"))
                .padding(12)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
