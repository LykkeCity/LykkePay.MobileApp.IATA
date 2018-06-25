import UIKit
import Material

@IBDesignable
class CurrencyUiTextField: DesignableUITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func initDecimal(value: String) -> String? {
        if let text = self.text, let last = text.characters.last, String(last).elementsEqual(".") {
            return  Formatter.formattedWithSeparator(value: value) + "."
        }
        return Formatter.formattedWithSeparator(value: value)
    }
}
