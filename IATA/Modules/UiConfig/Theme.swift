import UIKit
import Material

class Theme: NSObject {
    
    public let navBarAdditionalColor = Utils.rgb(243, 244, 245)
    public let buttonsColor = Utils.rgb(239, 82, 86)
    public let greenColor = Utils.rgb(44, 183, 1)
    public let tabBarItemSelectedColor = Utils.rgb(113, 142, 172)
    public let tabBarItemColor = Utils.rgb(100, 100, 110)
    public let munsellColor = Utils.rgb(243, 242, 248)
    public let tintTextFieldColor = Utils.rgb(44, 183, 1)
    public let textFieldColor = Utils.rgb(8, 42, 76)
    public let placeholderTextFieldColor = Utils.rgb(169, 175, 184)
    public let dotColor = Utils.rgb(230, 232, 234)
    public let dotFillColor = Utils.rgb(44, 183, 1)
    public let textPinColor = Utils.rgb(51, 51, 51)
    public let shadowPinColor = UIColor(red: CGFloat(230) / 255.0,
                                        green: CGFloat(232) / 255.0,
                                        blue: CGFloat(234) / 255.0,
                                        alpha: 0.5)
    public let navigationBarColor = Utils.rgb(19, 68, 117)
    public let tabBarBackgroundColor = Utils.rgb(19, 68, 117)
    public let tabBarItemUnselectedColor = Utils.rgb(113, 142, 172)
    public let selectedBaseCurrencyBorderCell = Utils.rgb(44, 183, 1)
    public let unselectedBaseCurrencyBorderCell = Utils.rgb(205, 205, 210)
    public let navBarTitle = Utils.rgb(17, 17, 17)
    public let logoutTitle = Utils.rgb(239, 23, 63)
    
    
    public let grayDisputeColor = Utils.rgb(101, 113, 128)
    public let pinkDisputeColor = Utils.rgb(254, 53, 96)
    public let blueProgressStatusColor = Utils.rgb(53, 153, 254)
    public let redErrorStatusColor = Utils.rgb(254, 53, 96)
    public let greyStatusColor = Utils.rgb(178, 184, 191)
    
    public private(set) lazy var buttonsFont = boldFontOfSize(16)
    public private(set) lazy var linksFont = boldFontOfSize(15)
    
    public private(set) lazy var fontTextSizeTextField = regularFontOfSize(16)
    public private(set) lazy var fontPlaceholderSizeTextField = regularFontOfSize(10)
    public private(set) lazy var fontCurrencyTextField = regularFontOfSize(24)
    
    override init() {
        super.init()
    }
    
    public func configureSolidButton(_ button: UIButton) {
        Utils.setButtonBackground(button, havingColor: buttonsColor, for: .normal)
        Utils.setButtonBackground(button, havingColor: greenColor, for: .disabled)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * button.intrinsicContentSize.height
        
        button.titleLabel?.font = buttonsFont
        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    public func configureBorderedButton(_ button: UIButton) {
        Utils.addOvalBorder(to: button, havingColor: buttonsColor, cornerRadius: 0.5 * button.bounds.size.height)
        
        button.titleLabel?.font = buttonsFont
        button.setTitleColor(buttonsColor, for: .normal)
    }
    
    private func boldFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "GothamPro-Bold", size: size)
    }
    
    private func lightFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "GothamPro-Light", size: size)
    }
    
    private func mediumFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "GothamPro-Medium", size: size)
    }
    
    private func regularFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "GothamPro", size: size)
    }
    
    public func getTitle(title: String!, color: UIColor) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font =  UIFont(name: "GothamPro-Bold", size: 17)
        titleLabel.tintColor = color
        titleLabel.textColor = color
        titleLabel.frame = CGRect(x: 0.0,
                                  y: 0.0,
                                  width: titleLabel.intrinsicContentSize.width,
                                  height: titleLabel.intrinsicContentSize.height)
        
        return titleLabel
    }
    
    public func getCancel(title: String!, color: UIColor) -> UIButton {
        let backButton = UIButton()
        backButton.setTitle(title, for: .normal)
        backButton.titleLabel?.font =  UIFont(name: "GothamPro", size: 17)
        backButton.tintColor = color
        backButton.setTitleColor(color, for: .normal)
        backButton.frame = CGRect(x: 0.0,
                                  y: 0.0,
                                  width: backButton.intrinsicContentSize.width,
                                  height: backButton.intrinsicContentSize.height)
        return backButton
    }
    
    public func getRightButton(title: String!, color: UIColor) -> UIButton {
        let rightButton = UIButton()
        rightButton.setTitle(title, for: .normal)
        rightButton.titleLabel?.font =  UIFont(name: "GothamPro-Bold", size: 17)
        rightButton.tintColor = color
        rightButton.setTitleColor(color, for: .normal)
        rightButton.frame = CGRect(x: 0.0,
                                  y: 0.0,
                                  width: rightButton.intrinsicContentSize.width,
                                  height: rightButton.intrinsicContentSize.height)
        return rightButton
    }
    
    public func configureTextFieldStyle(_ textField: ErrorTextField?, title: String){
        textField?.placeholder = title.localize()
        textField?.isPlaceholderUppercasedWhenEditing = true
        textField?.dividerActiveColor = Theme.shared.greenColor
        textField?.placeholderActiveColor = Theme.shared.greenColor
    }
    
    public func configureTextFieldCurrencyStyle(_ textField: ErrorTextField?, title: String){
        configureTextFieldStyle(textField, title: title)
        textField?.font = fontCurrencyTextField
        textField?.textColor = navBarTitle
    }
    
    public func configureTextFieldPasswordStyle(_ textField: ErrorTextField?, title: String){
        configureTextFieldStyle(textField, title: title)
        textField?.isSecureTextEntry = true
    }
    
    public func showError(_ textField: ErrorTextField?, _ message: String) {
        textField?.detail = message
        textField?.isErrorRevealed = true
    }
    
    public static private(set) var shared = Theme()
}
