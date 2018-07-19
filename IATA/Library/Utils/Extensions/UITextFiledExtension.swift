
import UIKit

extension UITextField {
    internal func filterNumbers(with string: String) -> Bool {
        if let separator = NSLocale.current.decimalSeparator {
            let aSet = NSCharacterSet(charactersIn:"0123456789"+separator).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if string != numberFiltered {
                return false
            }
        }
        return true
    }
}
