import Foundation
import WidgetKit

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var summary: PlayerSummary?
    @Published var heroes: [Hero]?
    @Published var donations: DonationStats?
    @Published var warStatus: WarStatus?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchData(for tag: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchSummary = APIClient.shared.fetchPlayerSummary(playerTag: tag)
            async let fetchHeroes = APIClient.shared.fetchHeroLevels(playerTag: tag)
            async let fetchDonations = APIClient.shared.fetchDonationStats(playerTag: tag)
            async let fetchWar = APIClient.shared.fetchWarStatus(playerTag: tag)
            
            let (summaryRes, heroesRes, donationsRes, warRes) = try await (fetchSummary, fetchHeroes, fetchDonations, fetchWar)
            
            self.summary = summaryRes
            self.heroes = heroesRes
            self.donations = donationsRes
            self.warStatus = warRes
            
            // Save to App Group for Widgets
            WidgetDataStore.shared.save(summaryRes, forKey: "widget_player_summary")
            WidgetDataStore.shared.save(heroesRes, forKey: "widget_heroes")
            WidgetDataStore.shared.save(donationsRes, forKey: "widget_donations")
            WidgetDataStore.shared.save(warRes, forKey: "widget_war_status")
            
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
