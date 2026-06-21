import WidgetKit
import SwiftUI

struct ClashWidgetEntry: TimelineEntry {
    let date: Date
    let warStatus: WarStatus?
    let heroes: [Hero]?
    let donations: DonationStats?
}

struct ClashTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClashWidgetEntry {
        ClashWidgetEntry(date: Date(), warStatus: mockWarStatus(), heroes: mockHeroes(), donations: mockDonations())
    }

    func getSnapshot(in context: Context, completion: @escaping (ClashWidgetEntry) -> ()) {
        let entry = ClashWidgetEntry(
            date: Date(),
            warStatus: WidgetDataStore.shared.load(forKey: "widget_war_status", as: WarStatus.self) ?? mockWarStatus(),
            heroes: WidgetDataStore.shared.load(forKey: "widget_heroes", as: [Hero].self) ?? mockHeroes(),
            donations: WidgetDataStore.shared.load(forKey: "widget_donations", as: DonationStats.self) ?? mockDonations()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClashWidgetEntry>) -> ()) {
        // Fetch from App Group (latest data from app)
        let warStatus = WidgetDataStore.shared.load(forKey: "widget_war_status", as: WarStatus.self)
        let heroes = WidgetDataStore.shared.load(forKey: "widget_heroes", as: [Hero].self)
        let donations = WidgetDataStore.shared.load(forKey: "widget_donations", as: DonationStats.self)
        
        let entry = ClashWidgetEntry(date: Date(), warStatus: warStatus, heroes: heroes, donations: donations)
        
        // Refresh policy: Request a refresh roughly every 30 minutes
        // iOS will dynamically schedule this based on user behavior and battery.
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        
        completion(timeline)
    }
    
    // Mocks for placeholder/preview
    private func mockWarStatus() -> WarStatus {
        WarStatus(state: "inWar", title: "Battle Day", clanName: "Night Riders", opponentName: "Enemy Clan", teamSize: 15, attacksPerMember: 2, attacksUsed: 1, attacksLeft: 1, playerStars: 2, clanStars: 34, opponentStars: 31, clanDestruction: 87.4, opponentDestruction: 82.1, playerDestruction: 75.0, phaseEndsAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(5*3600)), warStartTime: nil, warEndTime: nil, lastUpdated: nil)
    }
    
    private func mockHeroes() -> [Hero] {
        [
            Hero(name: "Archer Queen", level: 78, maxLevel: 95, village: "home", equipment: nil),
            Hero(name: "Barbarian King", level: 74, maxLevel: 95, village: "home", equipment: nil),
            Hero(name: "Grand Warden", level: 52, maxLevel: 70, village: "home", equipment: nil),
            Hero(name: "Royal Champion", level: 28, maxLevel: 45, village: "home", equipment: nil)
        ]
    }
    
    private func mockDonations() -> DonationStats {
        DonationStats(donations: 420, donationsReceived: 180, balance: 240, ratio: 2.33, mood: "Generous Chief")
    }
}
