import Foundation

struct SavedAccount: Codable, Identifiable, Equatable {
    var id: String { tag }
    let tag: String
    let inGameName: String
    let nickname: String?
    
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return "\(nickname) (\(inGameName))"
        }
        return inGameName
    }
}
