import Foundation
import UIKit

class TextFieldUtil: NSObject {
    
    class func validateMaxValueText(_ valueString: String, _ maxValue: Double) -> Bool {
        if(valueString.isEmpty) {
            return true
        }
        
        let numberValue = Double(valueString.removingWhitespaces())
        
        if(numberValue == nil) {
            return true
        }
        
        return numberValue! <= maxValue
    }
    
    class func validateMaxValue(newString: String?, maxValue: Double, range: NSRange, replacementString string: String, symbol: String?) -> Bool {
        if let symbolValue = symbol {
            let replaced = newString?.replace(target: symbolValue, withString: " ")
            
            if let valueString = replaced {
                return validateMaxValueText(valueString, maxValue)
            } else {
                return false
            }
        }
        return true
    }
    
    class func validateMinValueText(_ valueString: String, _ minValue: Double, _ isEqual: Bool) -> Bool {
        if(valueString.isEmpty) {
            return true
        }
        
        let numberValue = Double(valueString.removingWhitespaces())
        
        if(numberValue == nil) {
            return true
        }
        
        return isEqual ? minValue <= numberValue! : minValue < numberValue!
    }
    
    class func validateMinValue(newString: String?, minValue: Double, range: NSRange, replacementString string: String) -> Bool {
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            let replaced = newString?.replace(target: symbol, withString: " ")
            
            if let valueString = replaced {
                return validateMinValueText(valueString, minValue, false)
            } else {
                return false
            }
        }
        return true
    }
    
    class func validateMinValue(newString: String?, minValue: Double, range: NSRange, replacementString string: String,_ isEqual: Bool, symbol: String?) -> Bool {
         if let symbolValue = symbol {
            let replaced = newString?.replace(target: symbolValue, withString: " ")
            
            if let valueString = replaced {
                return validateMinValueText(valueString, minValue, isEqual)
            } else {
                return false
            }
        }
        return true
    }
    
}
