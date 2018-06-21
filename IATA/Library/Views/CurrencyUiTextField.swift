import UIKit
import Material

@IBDesignable
class CurrencyUiTextField: FloatTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    private func initCommon() {
        self.minimumFontSize = 24
        self.adjustsFontSizeToFitWidth = false
        self.initRightView()
    }
    
    private func initRightView() {
        let label = BottomAlignedLabel(frame: CGRect(x: 0, y: 0, width: 15, height: 26))
        label.contentMode = .center
        label.text = UserPreference.shared.getCurrentCurrency()?.symbol
        label.backgroundColor = .clear
        label.font = Theme.shared.regularFontOfSize(26)
        label.textColor = Theme.shared.navBarTitle
        label.textAlignment = .center
        
        self.rightView = label
        self.rightViewMode = .always
    }
}
