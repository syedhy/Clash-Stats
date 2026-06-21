import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var playerTag: String = ""
    @Published var apiToken: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func connect(accountStore: AccountStore) async {
        guard !playerTag.isEmpty, !apiToken.isEmpty else {
            errorMessage = "Please enter both Player Tag and API Token."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await APIClient.shared.verifyPlayer(playerTag: playerTag, token: apiToken)
            accountStore.login(tag: playerTag)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
