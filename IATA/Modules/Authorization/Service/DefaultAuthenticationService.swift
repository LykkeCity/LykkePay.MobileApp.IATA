import UIKit
import PromiseKit

class DefaultAuthenticationService: NSObject, AuthenticationService {
    
    internal func signIn(email: String, password: String) -> Promise<TokenObject> {
        let request = SignInRequest()
        request.email = email
        request.password = password
        return Network.shared.post(path: NetworkConfig.shared.tokenSignIn,
                                   object: request)
    }
    
    
    internal func pinValidation(pinCode: String) -> Promise<PinValidationResponse> {
        let request = PinValidationRequest()
        request.pinCode = pinCode
        return Network.shared.post(path: NetworkConfig.shared.pinValidation,
                                   object: request)
    }

}
