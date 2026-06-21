import Foundation

class AccountStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var playerTag: String?
    
    private let tagKey = "clash_companion_player_tag"
    
    init() {
        if let data = KeychainStore.shared.load(key: tagKey),
           let tag = String(data: data, encoding: .utf8) {
            self.playerTag = tag
            self.isLoggedIn = true
            WidgetDataStore.shared.playerTag = tag
        }
    }
    
    func login(tag: String) {
        if let data = tag.data(using: .utf8) {
            let _ = KeychainStore.shared.save(key: tagKey, data: data)
            DispatchQueue.main.async {
                self.playerTag = tag
                self.isLoggedIn = true
                WidgetDataStore.shared.playerTag = tag
            }
        }
    }
    
    func logout() {
        let _ = KeychainStore.shared.delete(key: tagKey)
        DispatchQueue.main.async {
            self.playerTag = nil
            self.isLoggedIn = false
            WidgetDataStore.shared.playerTag = nil
        }
    }
}
