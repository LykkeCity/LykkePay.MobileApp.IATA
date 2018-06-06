import PromiseKit
import Foundation

class DefaultPinViewState: DefaultBaseViewState, PinViewState {
    
    func validatePin(pin: String) -> Promise<PinValidationResponse> {
        return service.pinValidation(pinCode: pin)
    }
    
   
}
