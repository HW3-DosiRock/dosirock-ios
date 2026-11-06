import SwiftUI

struct RootView: View {

    @State private var isReady = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if isReady {
                if hasSeenOnboarding {
                    Text("Hello, world!")  // 나중에 로그인 / 메인 화면
                        .transition(.opacity)
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
