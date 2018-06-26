import Foundation
import PromiseKit

protocol AuthenticationService {
    
    func signIn(email: String, password: String) -> Promise<TokenObject>
    func pinValidation(pinCode: String) -> Promise<PinValidationResponse>
    func changePassword(oldPassword: String, newPassword: String) -> Promise<Void>
    func savePin(pinCode: String) -> Promise<Void>
}
