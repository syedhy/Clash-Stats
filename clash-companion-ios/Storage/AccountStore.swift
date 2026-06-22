import Foundation

class AccountStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var activeAccount: SavedAccount?
    @Published var savedAccounts: [SavedAccount] = []
    
    // Legacy key for cleanup
    private let legacyTagKey = "clash_companion_player_tag"
    
    // New keys
    private let accountsKey = "clash_companion_saved_accounts_v2"
    private let activeTagKey = "clash_companion_active_tag_v2"
    
    init() {
        loadAccounts()
        
        // Migrate old user
        if savedAccounts.isEmpty {
            if let data = KeychainStore.shared.load(key: legacyTagKey),
               let oldTag = String(data: data, encoding: .utf8) {
                let migratedAccount = SavedAccount(tag: oldTag, inGameName: "Main Account", nickname: nil)
                login(account: migratedAccount)
                let _ = KeychainStore.shared.delete(key: legacyTagKey)
            }
        }
    }
    
    private func loadAccounts() {
        if let data = KeychainStore.shared.load(key: accountsKey),
           let accounts = try? JSONDecoder().decode([SavedAccount].self, from: data) {
            self.savedAccounts = accounts
            
            if let activeData = KeychainStore.shared.load(key: activeTagKey),
               let activeTag = String(data: activeData, encoding: .utf8),
               let active = accounts.first(where: { $0.tag == activeTag }) {
                self.activeAccount = active
                self.isLoggedIn = true
                WidgetDataStore.shared.playerTag = active.tag
            } else if let first = accounts.first {
                self.activeAccount = first
                self.isLoggedIn = true
                WidgetDataStore.shared.playerTag = first.tag
                saveActiveTag(tag: first.tag)
            }
        }
    }
    
    func login(account: SavedAccount) {
        // Update or append
        if let index = savedAccounts.firstIndex(where: { $0.tag == account.tag }) {
            savedAccounts[index] = account
        } else {
            savedAccounts.append(account)
        }
        
        saveAllAccounts()
        saveActiveTag(tag: account.tag)
        
        DispatchQueue.main.async {
            self.activeAccount = account
            self.isLoggedIn = true
            WidgetDataStore.shared.playerTag = account.tag
        }
    }
    
    func switchAccount(to tag: String) {
        guard let account = savedAccounts.first(where: { $0.tag == tag }) else { return }
        saveActiveTag(tag: tag)
        DispatchQueue.main.async {
            self.activeAccount = account
            self.isLoggedIn = true
            WidgetDataStore.shared.playerTag = account.tag
        }
    }
    
    func deleteAccount(tag: String) {
        savedAccounts.removeAll(where: { $0.tag == tag })
        saveAllAccounts()
        
        DispatchQueue.main.async {
            if self.activeAccount?.tag == tag {
                if let next = self.savedAccounts.first {
                    self.switchAccount(to: next.tag)
                } else {
                    self.logout()
                }
            }
        }
    }
    
    func logout() {
        let _ = KeychainStore.shared.delete(key: accountsKey)
        let _ = KeychainStore.shared.delete(key: activeTagKey)
        DispatchQueue.main.async {
            self.savedAccounts = []
            self.activeAccount = nil
            self.isLoggedIn = false
            WidgetDataStore.shared.playerTag = nil
        }
    }
    
    private func saveAllAccounts() {
        if let data = try? JSONEncoder().encode(savedAccounts) {
            let _ = KeychainStore.shared.save(key: accountsKey, data: data)
        }
    }
    
    private func saveActiveTag(tag: String) {
        if let data = tag.data(using: .utf8) {
            let _ = KeychainStore.shared.save(key: activeTagKey, data: data)
        }
    }
}
