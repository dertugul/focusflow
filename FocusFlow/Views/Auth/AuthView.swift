import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password, confirm }

    var body: some View {
        ZStack {
            appVM.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Logo
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#F07A5A").opacity(0.15))
                                .frame(width: 80, height: 80)
                            Text("🌅")
                                .font(.system(size: 38))
                        }
                        Text("FocusFlow")
                            .font(.custom("DM Serif Display", size: 32))
                            .foregroundColor(.white)
                        Text("Track. Focus. Thrive.")
                            .font(.custom("DM Sans", size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1)
                    }
                    .padding(.top, 70)
                    .padding(.bottom, 40)

                    // Toggle
                    HStack(spacing: 0) {
                        ForEach([true, false], id: \.self) { isSignUpTab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) { isSignUp = isSignUpTab }
                                authVM.errorMessage = ""
                            }) {
                                Text(isSignUpTab ? "Sign Up" : "Sign In")
                                    .font(.custom("DM Sans", size: 15).weight(.semibold))
                                    .foregroundColor(isSignUp == isSignUpTab ? .white : .white.opacity(0.4))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        isSignUp == isSignUpTab ?
                                        Color(hex: "#F07A5A").opacity(0.2) : Color.clear
                                    )
                            }
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Form
                    VStack(spacing: 14) {
                        AuthTextField(icon: "envelope", placeholder: "Email", text: $email)
                            .focused($focusedField, equals: .email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        ZStack(alignment: .trailing) {
                            if showPassword {
                                AuthTextField(icon: "lock", placeholder: "Password", text: $password)
                                    .focused($focusedField, equals: .password)
                            } else {
                                AuthSecureField(icon: "lock", placeholder: "Password", text: $password)
                                    .focused($focusedField, equals: .password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.white.opacity(0.35))
                                    .font(.system(size: 15))
                            }
                            .padding(.trailing, 16)
                        }

                        if isSignUp {
                            AuthSecureField(icon: "lock.shield", placeholder: "Confirm Password", text: $confirmPassword)
                                .focused($focusedField, equals: .confirm)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 24)

                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .font(.custom("DM Sans", size: 13))
                            .foregroundColor(Color(hex: "#D4607E"))
                            .padding(.top, 10)
                            .padding(.horizontal, 24)
                    }

                    // CTA Button
                    Button(action: handleSubmit) {
                        HStack {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.custom("DM Sans", size: 16).weight(.bold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#F07A5A"), Color(hex: "#D4607E")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .onTapGesture { focusedField = nil }
    }

    private func handleSubmit() {
        focusedField = nil
        if isSignUp {
            guard password == confirmPassword else {
                authVM.errorMessage = "Passwords don't match"
                return
            }
            authVM.signUp(email: email, password: password)
        } else {
            authVM.signIn(email: email, password: password)
        }
    }
}

struct AuthTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.35))
                .font(.system(size: 15))
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .font(.custom("DM Sans", size: 15))
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .tint(Color(hex: "#F07A5A"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct AuthSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.35))
                .font(.system(size: 15))
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .font(.custom("DM Sans", size: 15))
                .foregroundColor(.white)
                .tint(Color(hex: "#F07A5A"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
