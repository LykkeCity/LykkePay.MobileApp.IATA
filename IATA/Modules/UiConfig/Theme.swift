import UIKit
import MaterialTextField

class Theme: NSObject {
    public let buttonsColor = Utils.rgb(239, 82, 86)
    public let disabledButtonsColor = Utils.rgb(225, 223, 237)
    public let tabBarItemSelectedColor = Utils.rgb(243, 88, 92)
    public let tabBarItemColor = Utils.rgb(100, 100, 110)
    public let munsellColor = Utils.rgb(243, 242, 248)
    public let tintTextFieldColor = Utils.rgb(44, 183, 1)
    public let textFieldColor = Utils.rgb(8, 42, 76)
    public let placeholderTextFieldColor = Utils.rgb(169, 175, 184)
    public let dotColor = Utils.rgb(230, 232, 234)
    
    public private(set) lazy var buttonsFont = boldFontOfSize(16)
    public private(set) lazy var linksFont = boldFontOfSize(15)
    
    public private(set) lazy var fontTextSizeTextField = boldFontOfSize(14)
    public private(set) lazy var fontPlaceholderSizeTextField = regularFontOfSize(12)
    
    override init() {
        super.init()
        applyTabBarStyle()
    }
    
    public func configureSolidButton(_ button: UIButton) {
        Utils.setButtonBackground(button, havingColor: buttonsColor, for: .normal)
        Utils.setButtonBackground(button, havingColor: disabledButtonsColor, for: .disabled)
        
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
    
    public func configureLinkButton(_ button: UIButton) {
        button.titleLabel?.font = linksFont
        button.setTitleColor(buttonsColor, for: .normal)
    }
    
    
    private func boldFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Gotham-Bold", size: size)
    }
    
    private func regularFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-Regular", size: size)
    }
    
    private func mediumFontOfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-Medium", size: size)
    }
    
    private func applyTabBarStyle() {
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: tabBarItemColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: tabBarItemSelectedColor], for: .selected)
    }
    
    public func configureTextFieldStyle(_ textField: MFTextField){
        textField.placeholderAnimatesOnFocus = true
        
        textField.tintColor = tintTextFieldColor
        textField.textColor = textFieldColor
        textField.defaultPlaceholderColor = placeholderTextFieldColor
        textField.placeholderFont  = fontPlaceholderSizeTextField
        textField.font = fontTextSizeTextField
    }
    
    public static private(set) var shared = Theme()
}
