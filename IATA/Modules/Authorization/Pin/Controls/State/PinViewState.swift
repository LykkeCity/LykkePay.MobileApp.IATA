import PromiseKit
import Foundation

protocol PinViewState : BaseViewState {
    
    func validatePin(pin: String) -> Promise<PinValidationResponse>
    func savePin(pin: String) -> Promise<Void>
    func initBaseAssert()
}
