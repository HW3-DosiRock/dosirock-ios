import SwiftUI

struct RootView: View {

    @State private var isReady = false
    @State private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if isReady {
                if hasSeenOnboarding {
                    if isLoggedIn {
                        Text("메인")
                    } else {
                        AuthFlowView(onLoginSuccess: {
                            withAnimation { isLoggedIn = true }
                        })
                        .transition(.opacity)
                    }
                } else {
                    OnboardingView(pages: OnboardingPage.samples) {
                        withAnimation { hasSeenOnboarding = true }
                    }
                    .transition(.opacity)
                }
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            await bootstrap()
            withAnimation(.easeInOut(duration: 0.3)) { isReady = true }
        }
    }

    private func bootstrap() async {
        // TODO : 임시,  실제 준비 작업(토큰 확인 등)으로 교체
        try? await Task.sleep(for: .seconds(1))
    }
}

#Preview {
    RootView()
}
