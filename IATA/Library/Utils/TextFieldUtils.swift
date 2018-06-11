import Foundation
import UIKit

class TextFieldUtil: NSObject {
    
    class func validateMaxValue(textField: UITextField, maxValue: Double, range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if(newString.isEmpty) {
            return true
        }
        
        let numberValue = Double(newString)
        
        if(numberValue == nil) {
            return false
        }
        
        return numberValue! <= maxValue
    }
    
    class func validateMinValue(textField: UITextField, minValue: Double, range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if(newString.isEmpty) {
            return true
        }
        
        let numberValue = Double(newString)
        
        if(numberValue == nil) {
            return false
        }
        
        return minValue <= numberValue!
    }
}
