import Foundation

protocol OnChangeStateSelected: class {
    func onItemSelected(isSelected: Bool, index: Int)
    func onItemSelected(index: Int)
    func isDisabled() -> Bool
}
