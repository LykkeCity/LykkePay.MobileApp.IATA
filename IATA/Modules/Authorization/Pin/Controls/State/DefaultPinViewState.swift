import PromiseKit
import Foundation

class DefaultPinViewState: DefaultBaseViewState, PinViewState {
    
    func validatePin(pin: String) -> Promise<PinValidationResponse> {
        let value =  pin + CredentialManager.shared.getUserName()!
        return self.service.pinValidation(pinCode: getHashPass(value: value))
    }
    
    func savePin(pin: String) -> Promise<Void> {
        let value =  pin + CredentialManager.shared.getUserName()!
        return self.service.savePin(pinCode: getHashPass(value: value))
    }
}
