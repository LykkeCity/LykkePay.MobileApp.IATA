import Foundation

class FilterPreference {
    
    private enum PropertyKey: String {
        case minValue
        case maxValue
    }
    
    static internal let shared = FilterPreference()
    static let preferences = UserDefaults.standard
    
    private init() {
    }
    
    internal func saveFilteredKey(_ isChecked: Bool?, key: String!, type: String!) {
        UserPreference.preferences.set(isChecked, forKey: type + "." + key)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getChecked(key: String!, type: String!) -> Bool? {
        if (type != nil && key != nil) {
            return UserPreference.preferences.bool(forKey: type + "." + key)
        }
        return false
    }
    
    internal func saveMinValue(_ minValue: Int?) {
        UserPreference.preferences.set(minValue, forKey: PropertyKey.minValue.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getMinValue() -> Int? {
        return UserPreference.preferences.integer(forKey: PropertyKey.minValue.rawValue)
    }
    
    internal func saveMaxValue(_ maxValue: Int?) {
        UserPreference.preferences.set(maxValue, forKey: PropertyKey.maxValue.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getMaxValue() -> Int? {
        return UserPreference.preferences.integer(forKey: PropertyKey.maxValue.rawValue)
    }
    
}

