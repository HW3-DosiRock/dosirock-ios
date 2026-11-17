import SwiftUI

@main struct DosiRockApp: App {
    private let container = AppContainer.live()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.container , container)
        }
    }
}
