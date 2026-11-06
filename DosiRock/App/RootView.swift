import SwiftUI

struct RootView: View {

    @State private var isReady = false

    var body: some View {
        ZStack {
            if isReady {
                Text("Hello, world!")
                    .transition(.opacity)
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
