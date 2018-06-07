import PromiseKit
import Foundation

class DefaultSignInViewState : DefaultBaseViewState, SignInViewState {
    
    func signIn(email: String, password: String) -> Promise<TokenObject> {
        return service.signIn(email: email, password: password)
    }
    
    func getHashPass(email: String, password: String) -> String {
        return self.getHashPass(value: password + email)
    }
    
}
