import Foundation
import KeychainAccess

class CredentialManager {
    
    private enum PropertyKey: String {
        case credential
        case accessToken
        case refreshToken
        case userId
    }
    
    static internal let shared = CredentialManager()
    static internal let keychainServiceName = "com.iata"
    internal var tokenObject: TokenObject?
    
    private init() {
    }
    
    private var keychain = Keychain(service: keychainServiceName)
    
    internal var isLogged: Bool {
        return false
    }
    
    // MARK: Credentials
  //  internal func saveCredential(_ credential: Credential?) {
       /* guard let credential = credential else {
            keychain[data: PropertyKey.credential.rawValue] = nil
            return
        }
        
        let encoder = JSONEncoder()
        do {
            keychain[data: PropertyKey.credential.rawValue] = try encoder.encode(credential)
        } catch {
            GlobalErrorHandler.shared.handleError(IATAOpError.keychainError)
        }*/
  //  }
    
    /*internal func getCredential() -> Credential? {
        guard let credentialData = keychain[data: PropertyKey.credential.rawValue] else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Credential.self, from: credentialData)
        } catch {
            GlobalErrorHandler.shared.handleError(EzOpError.keychainError)
            return nil
        }
    }*/
    
    // MARK: Token
    internal func saveTokenObject(_ tokenObject: TokenObject?) {
        saveAccessToken(tokenObject?.token)
    }
    
    private func saveAccessToken(_ accessToken: String?) {
        guard let accessToken = accessToken else {
            keychain[data: PropertyKey.accessToken.rawValue] = nil
            return
        }
        
        keychain[data: PropertyKey.accessToken.rawValue] = NSKeyedArchiver.archivedData(withRootObject: accessToken)
    }
    
  
    
    internal func getAccessToken() -> String? {
        if let accessToken = tokenObject?.token {
            return accessToken
        } else if let accessTokenData = keychain[data: PropertyKey.accessToken.rawValue] {
            return NSKeyedUnarchiver.unarchiveObject(with: accessTokenData) as? String
        } else {
            return nil
        }
    }
    
    internal func getRefreshToken() -> String? {
        if let refreshToken = tokenObject?.token {
            return refreshToken
        } else if let refreshTokenData = keychain[data: PropertyKey.refreshToken.rawValue] {
            return NSKeyedUnarchiver.unarchiveObject(with: refreshTokenData) as? String
        } else {
            return nil
        }
    }

    
    internal func clearSavedData() {
        saveTokenObject(nil)
        tokenObject = nil
    }
}
