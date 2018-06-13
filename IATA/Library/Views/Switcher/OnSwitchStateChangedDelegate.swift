import Foundation

protocol OnSwitchStateChangedDelegate: class {
    func stateChanged(isSelected: Bool, item: Any)
}
