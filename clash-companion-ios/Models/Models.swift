import Foundation

struct PlayerSummary: Codable, Equatable {
    let tag: String
    let name: String
    let townHallLevel: Int
    let trophies: Int?
    let bestTrophies: Int?
    let leagueName: String?
    let leagueIconUrl: String?
    let attackWins: Int?
    let defenseWins: Int?
    let builderHallLevel: Int?
    let builderBaseTrophies: Int?
    let bestBuilderBaseTrophies: Int?
    let clanTag: String?
    let clanName: String?
    let clanBadgeUrl: String?
    let donations: Int?
    let donationsReceived: Int?
    let heroes: [Hero]?
    let lastUpdated: String?
}

struct DashboardResponse: Codable {
    let summary: PlayerSummary?
    let heroes: [Hero]?
    let donations: DonationStats?
    let warStatus: WarStatus?
    let laboratory: LaboratoryData?
    let completionProgress: CompletionProgress?
}

struct CompletionProgress: Codable {
    let heroes: Double
    let laboratory: Double
}

struct Hero: Codable, Equatable, Hashable {
    let name: String
    let level: Int
    let maxLevel: Int
    let village: String
    let iconUrl: String?
    let equipment: [HeroEquipment]?
    
    var progress: Double {
        return maxLevel > 0 ? Double(level) / Double(maxLevel) : 0
    }
}

struct HeroEquipment: Codable, Equatable, Hashable {
    let name: String
    let level: Int
    let maxLevel: Int
    
    var progress: Double {
        return maxLevel > 0 ? Double(level) / Double(maxLevel) : 0
    }
}

struct Troop: Codable, Equatable, Hashable {
    let name: String
    let level: Int
    let maxLevel: Int
    let village: String
    let progress: Double
    let iconUrl: String?
}

struct LaboratoryData: Codable, Equatable {
    let troops: [Troop]
    let spells: [Troop]
    let pets: [Troop]
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
    let isSpectator: Bool?
    let attacksPerMember: Int?
    let attacksUsed: Int?
    let attacksLeft: Int?
    let playerStars: Int?
    let clanStars: Int?
    let opponentStars: Int?
    let clanDestruction: Double?
    let opponentDestruction: Double?
    let playerDestruction: Double?
    let phaseEndsAt: String?
    let warStartTime: String?
    let warEndTime: String?
    let lastUpdated: String?
}

extension WarStatus {
    var parsedPhaseEndsAt: Date? {
        guard let phaseEndsAt = phaseEndsAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss.SSSZ"
        return formatter.date(from: phaseEndsAt)
    }
}
