
import UIKit

extension UITextField {
    internal func filterNumbers(with string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if string != numberFiltered {
            return false
        }
        return true
    }
}
