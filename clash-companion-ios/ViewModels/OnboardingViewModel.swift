import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var playerTag: String = ""
    @Published var apiToken: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var nickname: String = ""
    
    func connect(accountStore: AccountStore) async {
        guard !playerTag.isEmpty, !apiToken.isEmpty else {
            errorMessage = "Please enter both Player Tag and API Token."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let player = try await APIClient.shared.verifyPlayer(playerTag: playerTag, token: apiToken)
            let newAccount = SavedAccount(
                tag: playerTag,
                inGameName: player.name,
                nickname: nickname.isEmpty ? nil : nickname
            )
            accountStore.login(account: newAccount)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
