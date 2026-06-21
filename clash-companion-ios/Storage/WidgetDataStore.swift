import Foundation

class WidgetDataStore {
    static let shared = WidgetDataStore()
    
    // Replace with your App Group identifier
    let appGroupIdentifier = "group.com.hyder.ClashCompanion"
    
    var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    func save<T: Codable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            sharedDefaults?.set(data, forKey: key)
        }
    }
    
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        if let data = sharedDefaults?.data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
}
