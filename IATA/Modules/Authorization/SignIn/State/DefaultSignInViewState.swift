import PromiseKit
import Foundation

class DefaultSignInViewState : SignInViewState {
    public lazy var service: AuthenticationService = DefaultAuthenticationService()
    
    func signIn(email: String, password: String) -> Promise<TokenObject> {
        return service.signIn(email: email, password: password)
    }
    

    func getHashPass(email: String, password: String) -> String {
        return ((password + email).sha1().data(using: .bytesHexLiteral)?.base64EncodedString())!
    }
    
    func getError(_ name:String, values: [String]) -> NSError {
        var resMessage = ""
        for message in values {
            resMessage.append(message)
            resMessage.append("\n")
        }
        let userInfo = [NSLocalizedDescriptionKey: resMessage]
        return NSError(domain: name, code: 123, userInfo: userInfo)
    }
    
}
