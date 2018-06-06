import Foundation
import KeychainAccess

class CredentialManager {
    
    private enum PropertyKey: String {
        case token
    }
    
    static internal let shared = CredentialManager()
    static internal let keychainServiceName = "com.iata"
    internal var tokenObject: TokenObject?
    
    private init() {
    }
    
    private var keychain = Keychain(service: keychainServiceName)
    
    internal var isLogged: Bool {
        return getAccessToken() != nil
    }
    
    
    // MARK: Token
    internal func saveTokenObject(_ tokenObject: TokenObject?) {
        saveAccessToken(tokenObject?.token)
    }
    
    private func saveAccessToken(_ accessToken: String?) {
        guard let accessToken = accessToken else {
            keychain[data: PropertyKey.token.rawValue] = nil
            return
        }
        
        keychain[data: PropertyKey.token.rawValue] = NSKeyedArchiver.archivedData(withRootObject: accessToken)
    }
    
    
    internal func getAccessToken() -> String? {
        if let accessToken = tokenObject?.token {
            return accessToken
        } else if let accessTokenData = keychain[data: PropertyKey.token.rawValue] {
            return NSKeyedUnarchiver.unarchiveObject(with: accessTokenData) as? String
        } else {
            return nil
        }
    }
    
    
    internal func clearSavedData() {
        saveTokenObject(nil)
        tokenObject = nil
    }
}
