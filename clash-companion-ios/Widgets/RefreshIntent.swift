import AppIntents
import WidgetKit
import Foundation

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Clash Stats"
    static var description: IntentDescription = IntentDescription("Fetches the latest Clash of Clans data.")
    
    init() {}

    func perform() async throws -> some IntentResult {
        let lastRefreshKey = "last_manual_refresh"
        let now = Date()
        
        if let lastRefresh = WidgetDataStore.shared.sharedDefaults?.object(forKey: lastRefreshKey) as? Date {
            // 120 seconds cooldown (2 minutes)
            if now.timeIntervalSince(lastRefresh) < 120 {
                return .result()
            }
        }
        
        // Update the last refresh timestamp
        WidgetDataStore.shared.sharedDefaults?.set(now, forKey: lastRefreshKey)
        
        // Attempt to fetch fresh data if a player tag is saved
        if let playerTag = WidgetDataStore.shared.playerTag {
            do {
                async let fetchedWar = try APIClient.shared.fetchWarStatus(playerTag: playerTag)
                async let fetchedHeroes = try APIClient.shared.fetchHeroLevels(playerTag: playerTag)
                async let fetchedDonations = try APIClient.shared.fetchDonationStats(playerTag: playerTag)
                
                let (war, heroes, donations) = try await (fetchedWar, fetchedHeroes, fetchedDonations)
                
                // Update the app group cache
                WidgetDataStore.shared.save(war, forKey: "widget_war_status")
                WidgetDataStore.shared.save(heroes, forKey: "widget_heroes")
                WidgetDataStore.shared.save(donations, forKey: "widget_donations")
                
            } catch {
                print("AppIntent fetch failed: \(error)")
            }
        }
        
        // Returning from an AppIntent automatically tells WidgetKit to reload timelines
        return .result()
    }
}
