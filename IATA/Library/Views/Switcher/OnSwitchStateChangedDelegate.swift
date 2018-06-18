import Foundation

protocol OnSwitchStateChangedDelegate: class {
    func stateChanged(isSelected: Bool, item: Any)
    func updatePaymentRangeMin(min: Int?)
    func updatePaymentRangeMax(max: Int?)
}
