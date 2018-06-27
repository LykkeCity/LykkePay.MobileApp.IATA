import UIKit
import Material

@IBDesignable
class DesignableUITextField: FloatTextField {
    
    var isObserving: Bool = false
    var symbolValue: String? = UserPreference.shared.getCurrentCurrency()?.symbol {
        didSet {
            self.text = super.text
        }
    }
    
    dynamic override var text: String? {
        get {
            if let stringValue = super.text, let symbol = symbolValue {
                let replaced = stringValue.replace(target: symbol, withString: " ")
                return replaced.removingWhitespaces()
            }
            return super.text
        }
        set {
            if var value = newValue, let symbol = symbolValue {
                let newValue = value.replace(target: symbol, withString: " ")
                value =  newValue.removingWhitespaces()
                if let res = initDecimal(value: value) {
                    super.text = res  + " " + symbol
                }
                checkPosition()
            } else {
                super.text = newValue
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        checkPosition()
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    
    @objc func removeObservers() {
        if (isObserving) {
            self.removeObserver(self, forKeyPath: "selectedTextRange", context: nil)
            isObserving = false
        }
    }
    
    @objc func editChanged(_ sender: Any) {
        if let text = self.text, let isEmpty = self.text?.isEmpty, isEmpty || (Int(text) == 0) {
            self.text = "0"
        } else if let text = self.text {
            var valueString = text
            if text.starts(with: "0") && !text.starts(with: "0.") {
                let fromIndex = text.index(text.startIndex, offsetBy: 1)
                valueString = text.substring(from: fromIndex)
                self.text = valueString
            }
        }
    }
    
    @objc func editingDidBegin() {
        if let text = self.text {
            self.text = initDecimal(value: text)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkPosition()
        }
    }
    
    @objc func editingDidEnd() {
        if let text = self.text {
            self.text = initDecimal(value: text)
        }
    }
    
    func scrollToPosition(position: Int) {
        DispatchQueue.main.async {
            if let newPosition = self.position(from: self.beginningOfDocument, offset: position) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func addObservers() {
        if (!isObserving) {
            self.isObserving = true
            self.addObserver(self, forKeyPath: "selectedTextRange", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        }
    }
    
    func initDecimal(value: String) -> String? {
        return Formatter.formattedWithSeparator(value: value)
    }
    
    func getOldText() -> String? {
        return super.text
    }
    
    
    func checkPosition() {
        if let start = self.selectedTextRange?.start {
            let currentPosition =  self.offset(from: self.beginningOfDocument, to: start)
            if let end = self.getOldText()?.count, (currentPosition > end - 2) {
                scrollToPosition(position: end - 2)
            }
        }
    }
    
    private func initCommon() {
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editChanged), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeObservers), name: NSNotification.Name(NotificateEnum.destroy.rawValue), object: nil)
        self.minimumFontSize = 24
        self.adjustsFontSizeToFitWidth = false
    }
}
