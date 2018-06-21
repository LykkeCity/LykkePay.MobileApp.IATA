import UIKit
import Material

@IBDesignable
class DesignableUITextField: FloatTextField {
    
    dynamic override var text: String? {
        get {
            if let stringValue = super.text, let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
                let replaced = stringValue.replace(target: symbol, withString: " ")
                return replaced.removingWhitespaces()
            }
            return super.text
        }
        set { super.text = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        editingDidBegin()
    }
    
    
    func getOldText() -> String? {
        return super.text
    }
    
    
    @objc func editingDidBegin() {
        let currentPosition =  self.offset(from: self.beginningOfDocument, to: (self.selectedTextRange?.start)!)
        
        
        if let end = self.getOldText()?.count, (currentPosition > end - 2) {
            scrollToPosition(position: end - 2)
        }
    }
    
    @objc func editingChanged() {
        var currentPosition =  self.offset(from: self.beginningOfDocument, to: (self.selectedTextRange?.start)!)

        if let text = self.text?.removingWhitespaces(), let value = Double(text) {
            self.text = value.formattedWithSeparator
            currentPosition =  self.offset(from: self.beginningOfDocument, to: (self.selectedTextRange?.start)!)
            self.text = value.formattedWithSeparator + " $"
        }
        
        DispatchQueue.main.async {
            if let newPosition = self.position(from: self.beginningOfDocument, offset: currentPosition) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    internal func scrollToPosition(position: Int) {
        DispatchQueue.main.async {
            if let newPosition = self.position(from: self.beginningOfDocument, offset: position) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    private func initCommon() {
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addObserver(self, forKeyPath: "selectedTextRange",   options: NSKeyValueObservingOptions.new, context: nil)
        self.addObserver(self, forKeyPath: "selectedTextRange",   options: NSKeyValueObservingOptions.old, context: nil)
        self.minimumFontSize = 24
        self.adjustsFontSizeToFitWidth = false
    }
}
