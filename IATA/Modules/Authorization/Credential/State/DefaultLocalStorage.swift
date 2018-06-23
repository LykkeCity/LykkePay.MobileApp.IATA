import UIKit
import ObjectMapper

class DefaultLocalStorage: LocalStorage {
    
    private let defaults: UserDefaults
    
    internal static let shared: DefaultLocalStorage = DefaultLocalStorage()
    
    init() {
        defaults = UserDefaults.standard
    }
    
    internal func remove(for key: String) {
        defaults.removeObject(forKey: key)
    }
    
    internal func set<T: Mappable>(value: T, for key: String) {
        guard let preparedArchivedData = value.toJSONString()?.data(using: .utf8) else {
            return
        }
        
        defaults.set(preparedArchivedData, forKey: key)
    }
    
    internal func get<T: Mappable>(for key: String) -> T? {
        guard let storedData = defaults.value(forKey: key) as? Data,
            let jsonString = String(data: storedData, encoding: .utf8) else {
                return nil
        }
        
        return T(JSONString: jsonString)
    }
}
