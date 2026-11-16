import SwiftUI

// MARK: - Shared theme (used by all views)
enum Theme {
    static let accent = Color(red: 0.40, green: 0.35, blue: 0.95)
    static let gradient = LinearGradient(
        colors: [Color(red: 0.36, green: 0.40, blue: 0.98),
                 Color(red: 0.62, green: 0.33, blue: 0.93)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @FocusState private var focused: Field?

    private enum Field { case email, password }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    var body: some View {
        ZStack {
            Theme.gradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header
                    card
                    switchModeButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 70)
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: Header
    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "checklist")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 84, height: 84)
                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)

            Text(isSignUp ? "Create account" : "Welcome back")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(isSignUp ? "Sign up to start organizing your tasks."
                          : "Log in to see your tasks.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    // MARK: Card
    private var card: some View {
        VStack(spacing: 16) {
            inputRow(icon: "envelope.fill") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
            }

            inputRow(icon: "lock.fill") {
                SecureField("Password (min 6 characters)", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }
            }

            if let error = auth.errorMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error).font(.footnote)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.red)
                .padding(12)
                .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button(action: submit) {
                Group {
                    if auth.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isSignUp ? "Create Account" : "Log In")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Group {
                        if canSubmit && !auth.isLoading {
                            Theme.gradient
                        } else {
                            Color.gray.opacity(0.35)
                        }
                    },
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
            }
            .disabled(!canSubmit || auth.isLoading)
        }
        .padding(20)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 10)
    }

    private var switchModeButton: some View {
        Button {
            auth.errorMessage = nil
            withAnimation(.easeInOut(duration: 0.2)) { isSignUp.toggle() }
        } label: {
            Text(isSignUp ? "Already have an account? **Log In**"
                          : "No account? **Sign Up**")
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    // MARK: Helpers
    private func inputRow<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .frame(width: 20)
            content()
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func submit() {
        guard canSubmit, !auth.isLoading else { return }
        focused = nil
        Task {
            let e = email.trimmingCharacters(in: .whitespaces)
            if isSignUp { await auth.signUp(email: e, password: password) }
            else { await auth.signIn(email: e, password: password) }
        }
    }
}
