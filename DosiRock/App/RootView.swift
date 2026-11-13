import SwiftUI

struct RootView: View {

    @State private var isReady = false
    private let session = SessionStore.shared  // 앱 전체가 공유하는 로그인 상태
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if isReady {
                if hasSeenOnboarding {
                    if session.isLoggedIn {
                        // TODO 임시: 메인 화면을 만들면 진짜 로그아웃 버튼으로 교체
                        Button("로그아웃(임시)") {
                            Task {
                                try? await AppEnvironment.makeAuthService().logout()
                                withAnimation { session.isLoggedIn = false }
                            }
                        }
                    } else {
                        AuthFlowView(onLoginSuccess: {
                            withAnimation { session.isLoggedIn = true }
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
        // 네트워크 코드가 로그인 상태를 바꿨을 때도 화면이 부드럽게 바뀌게
        .animation(.easeInOut(duration: 0.3), value: session.isLoggedIn)
        .task {
            await bootstrap()
            withAnimation(.easeInOut(duration: 0.3)) { isReady = true }
        }
    }

    private func bootstrap() async {
        // 저장된 리프레시 토큰이 있으면 로그인된 상태로 시작하고 토큰을 갱신
        if TokenStore.read(.refresh) != nil {
            session.isLoggedIn = true
            do {
                try await AppEnvironment.makeAuthService().refresh()
            } catch let error as AuthError where error.code != nil {
                // 서버가 토큰을 거부함(만료 등) → 저장된 토큰 삭제 후 로그인 화면
                session.expire(message: error.errorDescription)
            } catch {
                // 네트워크 오류 등은 로그인 상태를 유지
            }
        }
        try? await Task.sleep(for : .seconds(1))    // 스플래시 보여주기 용 대기 시간
    }
}

#Preview {
    RootView()
}
