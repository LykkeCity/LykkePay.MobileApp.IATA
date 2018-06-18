import PromiseKit
import Foundation

class DefaultSignInViewState : DefaultBaseViewState, SignInViewState {
    
    func signIn(email: String, password: String) -> Promise<TokenObject> {
        return service.signIn(email: email, password: password)
    }
    
    func getHashPass(email: String, password: String) -> String {
        return self.getHashPass(value: password + email)
    }
    
    func savePreference(tokenObject: TokenObject, email: String) {
        CredentialManager.shared.saveTokenObject(tokenObject, userName: email)
        UserPreference.shared.saveForceUpdatePassword(tokenObject.forcePasswordUpdate)
        UserPreference.shared.saveForceUpdatePin(tokenObject.forcePasswordUpdate! ? true : tokenObject.forceUpdatePin)
        FilterPreference.shared.saveMinValue(0)
        FilterPreference.shared.saveMaxValue(1000000)
    }
    
}
