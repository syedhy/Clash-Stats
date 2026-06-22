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
    @Published var errorMessage: String? = nil
    
    func fetchData(for tag: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dashboardData = try await APIClient.shared.fetchDashboard(playerTag: tag)
            
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
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
