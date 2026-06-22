import Foundation
import WidgetKit

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var summary: PlayerSummary?
    @Published var heroes: [Hero]?
    @Published var donations: DonationStats?
    @Published var warStatus: WarStatus?
    @Published var laboratory: LaboratoryData?
    @Published var completionProgress: CompletionProgress?
    
    @Published var isLoading: Bool = false
    @Published var showLoader: Bool = false
    @Published var isOfflineMode: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchData(for tag: String) async {
        isLoading = true
        showLoader = false
        isOfflineMode = false
        errorMessage = nil
        
        let loaderTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            if !Task.isCancelled && self.isLoading {
                self.showLoader = true
            }
        }
        
        let fetchTask = Task { () -> DashboardResponse? in
            do {
                return try await APIClient.shared.fetchDashboard(playerTag: tag)
            } catch {
                print("Fetch Error inside detached task: \(error)")
                return nil
            }
        }
        
        let response = await fetchTask.value
        
        if let dashboardData = response {
            self.summary = dashboardData.summary
            self.heroes = dashboardData.heroes
            self.donations = dashboardData.donations
            self.warStatus = dashboardData.warStatus
            self.laboratory = dashboardData.laboratory
            self.completionProgress = dashboardData.completionProgress
            
            // Save to App Group for Widgets
            if let sum = dashboardData.summary { WidgetDataStore.shared.save(sum, forKey: "widget_player_summary") }
            if let hrs = dashboardData.heroes { WidgetDataStore.shared.save(hrs, forKey: "widget_heroes") }
            if let dns = dashboardData.donations { WidgetDataStore.shared.save(dns, forKey: "widget_donations") }
            if let war = dashboardData.warStatus { WidgetDataStore.shared.save(war, forKey: "widget_war_status") }
            
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
            
        } else {
            // Error occurred, attempt to load from cache
            let cachedSummary = WidgetDataStore.shared.load(forKey: "widget_player_summary", as: PlayerSummary.self)
            let cachedHeroes = WidgetDataStore.shared.load(forKey: "widget_heroes", as: [Hero].self)
            let cachedDonations = WidgetDataStore.shared.load(forKey: "widget_donations", as: DonationStats.self)
            let cachedWar = WidgetDataStore.shared.load(forKey: "widget_war_status", as: WarStatus.self)
            
            if cachedSummary != nil {
                self.summary = cachedSummary
                self.heroes = cachedHeroes
                self.donations = cachedDonations
                self.warStatus = cachedWar
                self.isOfflineMode = true
            } else {
                self.errorMessage = "Unable to reach server."
            }
        }
        
        isLoading = false
        showLoader = false
        loaderTask.cancel()
    }
}
