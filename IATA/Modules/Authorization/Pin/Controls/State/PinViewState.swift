import PromiseKit
import Foundation

protocol PinViewState : BaseViewState {
    
    func validatePin(pin: String) -> Promise<PinValidationResponse>
    
}
