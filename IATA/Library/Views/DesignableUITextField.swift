import UIKit
import MaterialTextField

@IBDesignable
class DesignableUITextField: MFTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initRightView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initRightView()
    }
    
    private func initRightView() {
        let label = BottomAlignedLabel(frame: CGRect(x: 0, y: 0, width: 25, height: 45))
        label.contentMode = .bottom
        label.text = "$"
        label.backgroundColor = .white
        label.font = Theme.shared.fontCurrencyTextField
        label.textColor = Theme.shared.navBarTitle
        label.textAlignment = .center
        
        self.rightView = label
        self.rightViewMode = .always
    }
}
