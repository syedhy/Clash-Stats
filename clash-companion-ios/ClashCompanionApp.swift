import SwiftUI

@main
struct ClashCompanionApp: App {
    @StateObject private var accountStore = AccountStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if accountStore.isLoggedIn {
                    DashboardView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(accountStore)
            .environment(\.font, .custom("Clash-Regular", size: 16, relativeTo: .body))
        }
    }
}
