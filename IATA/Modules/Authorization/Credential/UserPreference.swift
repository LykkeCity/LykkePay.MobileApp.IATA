import Foundation

class UserPreference {
    
    private enum PropertyKey: String {
        case forceUpdatePassword
        case forceUpdatePin
    }
    
    static internal let shared = UserPreference()
    static let preferences = UserDefaults.standard
    
    private init() {
    }
    
    internal func saveForceUpdatePassword(_ forceUpdatePassword: Bool?) {
        UserPreference.preferences.set(forceUpdatePassword, forKey: PropertyKey.forceUpdatePassword.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
           
        }
    }
    
    internal func getUpdatePassword() -> Bool? {
        return UserPreference.preferences.bool(forKey: PropertyKey.forceUpdatePassword.rawValue)
    }
    
    internal func saveForceUpdatePin(_ forceUpdatePin: Bool?) {
        UserPreference.preferences.set(forceUpdatePin, forKey: PropertyKey.forceUpdatePin.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getUpdatePin() -> Bool? {
        return UserPreference.preferences.bool(forKey: PropertyKey.forceUpdatePin.rawValue)
    }
}
