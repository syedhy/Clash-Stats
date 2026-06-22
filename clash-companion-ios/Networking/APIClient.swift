import Foundation

class APIClient {
    static let shared = APIClient()
    
    // Use backendURL from WidgetDataStore if set, otherwise fallback to default
    var baseURL: String {
        WidgetDataStore.shared.backendURL ?? "https://clash-stats-6mvy.onrender.com/api"
    }
    
    private init() {}
    
    struct VerifyResponse: Codable {
        let success: Bool
        let error: String?
        let player: PlayerSummary?
    }
    
    func verifyPlayer(playerTag: String, token: String) async throws -> PlayerSummary {
        guard let url = URL(string: "\(baseURL)/auth/verify") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "Bypass-Tunnel-Reminder") // For localtunnel
        
        let body = ["playerTag": playerTag, "playerApiToken": token]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpRes = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if httpRes.statusCode == 401 { throw APIError.unauthorized }
        
        let res = try JSONDecoder().decode(VerifyResponse.self, from: data)
        if res.success, let player = res.player {
            return player
        } else {
            throw APIError.serverError(res.error ?? "Unknown error during verification")
        }
    }
    
    func fetchPlayerSummary(playerTag: String) async throws -> PlayerSummary {
        return try await fetch(endpoint: "/player/\(encode(playerTag))/summary")
    }
    
    func fetchWarStatus(playerTag: String) async throws -> WarStatus {
        return try await fetch(endpoint: "/player/\(encode(playerTag))/war")
    }
    
    struct HeroesResponse: Codable { let heroes: [Hero] }
    func fetchHeroLevels(playerTag: String) async throws -> [Hero] {
        let res: HeroesResponse = try await fetch(endpoint: "/player/\(encode(playerTag))/heroes")
        return res.heroes
    }
    
    func fetchDonationStats(playerTag: String) async throws -> DonationStats {
        return try await fetch(endpoint: "/player/\(encode(playerTag))/donations")
    }
    
    func fetchLaboratory(playerTag: String) async throws -> LaboratoryData {
        return try await fetch(endpoint: "/player/\(encode(playerTag))/laboratory")
    }

    func fetchDashboard(playerTag: String) async throws -> DashboardResponse {
        return try await fetch(endpoint: "/player/\(encode(playerTag))/dashboard")
    }
    
    private func fetch<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("true", forHTTPHeaderField: "Bypass-Tunnel-Reminder") // For localtunnel
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpRes = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if !(200...299).contains(httpRes.statusCode) {
            throw APIError.serverError("Server returned status \(httpRes.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    private func encode(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
    }
}
