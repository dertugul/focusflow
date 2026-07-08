import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
        ZStack {
            appVM.backgroundGradient.ignoresSafeArea()
            Group {
                switch authVM.onboardingStep {
                case 0: NameStepView()
                case 1: AvatarColorStepView()
                case 2: TeamSelectionStepView()
                default: NameStepView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: authVM.onboardingStep)
        }
    }
}

struct NameStepView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            OnboardingHeader(step: 1, of: 3, title: "What's your name?", subtitle: "How should we call you?")

            TextField("Your name", text: $authVM.onboardingName)
                .font(.custom("DM Sans", size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .tint(Color(hex: "#F07A5A"))
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 32)
                .focused($focused)

            Spacer()

            OnboardingNextButton(label: "Continue", isEnabled: !authVM.onboardingName.trimmingCharacters(in: .whitespaces).isEmpty) {
                withAnimation { authVM.onboardingStep = 1 }
            }
        }
        .padding(.bottom, 48)
        .onAppear { focused = true }
    }
}

struct AvatarColorStepView: View {
    @EnvironmentObject var authVM: AuthViewModel
    let colors = ["#F07A5A","#F5C26A","#D4607E","#9B7EC8","#6BA3BE","#7EC87E","#E8A05A","#A05AE8"]
    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            OnboardingHeader(step: 2, of: 3, title: "Pick your color", subtitle: "Choose your avatar color")

            AvatarView(name: authVM.onboardingName, colorHex: authVM.onboardingAvatarColor, size: 80)
                .shadow(color: Color(hex: authVM.onboardingAvatarColor).opacity(0.5), radius: 20)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(colors, id: \.self) { hex in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            authVM.onboardingAvatarColor = hex
                        }
                    }) {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 52, height: 52)
                            .overlay(
                                authVM.onboardingAvatarColor == hex ?
                                Circle().stroke(Color.white, lineWidth: 3) : nil
                            )
                            .scaleEffect(authVM.onboardingAvatarColor == hex ? 1.1 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            OnboardingNextButton(label: "Continue", isEnabled: true) {
                withAnimation { authVM.onboardingStep = 2 }
            }
        }
        .padding(.bottom, 48)
    }
}

struct TeamSelectionStepView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            OnboardingHeader(step: 3, of: 3, title: "Join a team", subtitle: "Find your focus community")

            VStack(spacing: 12) {
                ForEach(User.Team.allCases, id: \.self) { team in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            authVM.onboardingTeam = team
                        }
                    }) {
                        HStack(spacing: 14) {
                            Text(team.emoji)
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(team.rawValue)
                                    .font(.custom("DM Sans", size: 16).weight(.semibold))
                                    .foregroundColor(.white)
                                Text("Focus on " + team.description)
                                    .font(.custom("DM Sans", size: 13))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                            if authVM.onboardingTeam == team {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#F07A5A"))
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(16)
                        .background(authVM.onboardingTeam == team ? Color(hex: "#F07A5A").opacity(0.12) : Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
                            authVM.onboardingTeam == team ? Color(hex: "#F07A5A").opacity(0.4) : Color.white.opacity(0.07),
                            lineWidth: 1
                        ))
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingNextButton(label: "Get Started →", isEnabled: true) {
                authVM.completeOnboarding()
            }
        }
        .padding(.bottom, 48)
    }
}

struct OnboardingHeader: View {
    var step: Int
    var of: Int
    var title: String
    var subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(1...of, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color(hex: "#F07A5A") : Color.white.opacity(0.15))
                        .frame(width: i == step ? 24 : 8, height: 4)
                }
            }
            Text(title)
                .font(.custom("DM Serif Display", size: 28))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.custom("DM Sans", size: 15))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

struct OnboardingNextButton: View {
    var label: String
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom("DM Sans", size: 16).weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isEnabled ? [Color(hex: "#F07A5A"), Color(hex: "#D4607E")] : [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 24)
    }
}
