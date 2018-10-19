import Foundation
import KeychainAccess

class CredentialManager {
    
    private enum PropertyKey: String {
        case token
        case userName
    }
    
    static internal let shared = CredentialManager()
    static internal let keychainServiceName = "com.iata"
    internal var tokenObject: TokenObject?
    internal var userName: String?
    
    private init() {
    }
    
    private var keychain = Keychain(service: keychainServiceName)
    
    
    
    // MARK: Token
    internal func saveTokenObject(_ tokenObject: TokenObject?, userName: String?) {
        saveAccessToken(tokenObject?.token)
        UserPreference.shared.saveisLogged(getAccessToken() != nil)
        saveUserName(userName)
    }
    
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
    
    //#MARK UserName
    internal func getUserName() -> String? {
        if let userName = userName {
            return userName
        } else if let userNameData = keychain[data: PropertyKey.userName.rawValue] {
            return NSKeyedUnarchiver.unarchiveObject(with: userNameData) as? String
        } else {
            return nil
        }
    }
    
    private func saveUserName(_ userName: String?) {
        guard let userName = userName else {
            keychain[data: PropertyKey.userName.rawValue] = nil
            return
        }
        
        keychain[data: PropertyKey.userName.rawValue] = NSKeyedArchiver.archivedData(withRootObject: userName)
    }
    
    
    internal func clearSavedData() {
        saveTokenObject(nil)
        tokenObject = nil
        UserPreference.shared.clearSaveData()
    }
}
