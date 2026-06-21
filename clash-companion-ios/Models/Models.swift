import Foundation

struct PlayerSummary: Codable, Equatable {
    let tag: String
    let name: String
    let townHallLevel: Int
    let trophies: Int?
    let bestTrophies: Int?
    let leagueName: String?
    let leagueIconUrl: String?
    let clanTag: String?
    let clanName: String?
    let clanBadgeUrl: String?
    let donations: Int?
    let donationsReceived: Int?
    let heroes: [Hero]?
    let lastUpdated: String?
}

struct Hero: Codable, Equatable, Hashable {
    let name: String
    let level: Int
    let maxLevel: Int
    let village: String
    
    var progress: Double {
        return maxLevel > 0 ? Double(level) / Double(maxLevel) : 0
    }
}

struct DonationStats: Codable, Equatable {
    let donations: Int
    let donationsReceived: Int
    let balance: Int
    let ratio: Double
    let mood: String
}

struct WarStatus: Codable, Equatable {
    let state: String
    let title: String
    let clanName: String?
    let opponentName: String?
    let teamSize: Int?
    let attacksPerMember: Int?
    let attacksUsed: Int?
    let attacksLeft: Int?
    let playerStars: Int?
    let clanStars: Int?
    let opponentStars: Int?
    let clanDestruction: Double?
    let opponentDestruction: Double?
    let phaseEndsAt: String?
    let warStartTime: String?
    let warEndTime: String?
    let lastUpdated: String?
}
