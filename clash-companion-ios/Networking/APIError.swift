import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL configuration."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from server."
        case .decodingError(let error): return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let msg): return msg
        case .unauthorized: return "Invalid player tag or API token."
        }
    }
}
