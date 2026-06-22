import SwiftUI

@main
struct ClashCompanionApp: App {
    @StateObject private var accountStore = AccountStore()

    var body: some Scene {
        WindowGroup {
            if accountStore.isLoggedIn {
                DashboardView()
                    .environmentObject(accountStore)
            } else {
                OnboardingView()
                    .environmentObject(accountStore)
            }
        }
    }
}
