import Foundation
import UIKit

class TextFieldUtil: NSObject {
    
    class func validateMaxValue(newString: String?, maxValue: Double, range: NSRange, replacementString string: String) -> Bool {
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            let replaced = newString?.replace(target: symbol, withString: " ")
            if let valueString = replaced {
                if(valueString.isEmpty) {
                    return true
                }
                
                let numberValue = Double(valueString.removingWhitespaces())
                
                if(numberValue == nil) {
                    return false
                }
                
                return numberValue! <= maxValue
            } else {
                return false
            }
        }
        return true
    }
    
    class func validateMinValue(newString: String?, minValue: Double, range: NSRange, replacementString string: String) -> Bool {
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            let replaced = newString?.replace(target: symbol, withString: " ")
            
            if let valueString = replaced {
                if(valueString.isEmpty) {
                    return true
                }
                
                let numberValue = Double(valueString.removingWhitespaces())
                
                if(numberValue == nil) {
                    return false
                }
                
                return minValue <= numberValue!
            } else {
                return false
            }
        }
        return true
    }
}
