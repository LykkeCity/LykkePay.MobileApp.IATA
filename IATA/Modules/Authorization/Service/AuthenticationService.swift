import Foundation
import PromiseKit

protocol AuthenticationService {
    
    func signIn(email: String, password: String) -> Promise<TokenObject>
}
