import Foundation
import PromiseKit

protocol AuthenticationService {
    
    func signIn(email: String, password: String) -> Promise<TokenObject>
    func pinValidation(pinCode: String) -> Promise<PinValidationResponse>
}
