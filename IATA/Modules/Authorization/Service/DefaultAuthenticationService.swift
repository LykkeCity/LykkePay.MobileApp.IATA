import UIKit
import PromiseKit

class DefaultAuthenticationService: NSObject, AuthenticationService {
    
    internal func signIn(email: String, password: String) -> Promise<TokenObject> {
        let request = SignInRequest()
        request.email = email
        request.password = password
        return Network.shared.post(path: AuthNetworkConfig.shared.tokenSignIn,
                                   object: request)
    }
    
    
    internal func pinValidation(pinCode: String) -> Promise<PinValidationResponse> {
        let request = PinValidationRequest()
        request.pinCode = pinCode
        return Network.shared.post(path: AuthNetworkConfig.shared.pinValidation,
                                   object: request)
    }
    
    
    internal func changePassword(oldPassword: String, newPassword: String) -> Promise<Void> {
        let request = ChangePasswordRequest()
        request.newPasswordHash = newPassword
        request.currentPasssword = oldPassword
        return Network.shared.post(path: AuthNetworkConfig.shared.changePassword,
                                   object: request)
    }
    
    internal func savePin(pinCode: String) -> Promise<Void> {
        let request = SavePinRequest()
        request.newPinCodeHash = pinCode
        return Network.shared.post(path: AuthNetworkConfig.shared.savePin,
                                   object: request)
    }

}
