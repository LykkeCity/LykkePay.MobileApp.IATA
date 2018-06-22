import UIKit
import WARangeSlider

class PaymentRangeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var rangeSlider: RangeSlider?
    @IBOutlet weak var minValueTextField: DesignableUITextField?
    @IBOutlet weak var maxValueTextField: DesignableUITextField?
    weak var delegate: OnSwitchStateChangedDelegate?
    
    var item: InvoiceSettingPaymentRangeItemModel? {
        didSet {
            guard let item = self.item else {
                return
            }
            if let min = item.min, let symbol =  UserPreference.shared.getCurrentCurrency()?.symbol {
                self.minValueTextField?.text = Double(min).formattedWithSeparator + " " + symbol
            }
            
            if let max = item.max, let symbol =  UserPreference.shared.getCurrentCurrency()?.symbol {
                self.maxValueTextField?.text = Double(max).formattedWithSeparator + " " + symbol
            }
            
            self.minValueChanged(self.minValueTextField)
            self.maxValueChanged(self.maxValueTextField)
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Theme.shared.configureTextFieldStyle(self.minValueTextField, title: R.string.localizable.invoiceSettingsRangeFrom())
        Theme.shared.configureTextFieldStyle(self.maxValueTextField, title: R.string.localizable.invoiceSettingsRangeTo())
        
        self.minValueTextField?.keyboardType = UIKeyboardType.decimalPad
        self.maxValueTextField?.keyboardType = UIKeyboardType.decimalPad
        
        self.minValueTextField?.delegate = self
        self.maxValueTextField?.delegate = self
        
        self.minValueTextField?.addTarget(self, action: #selector(editingFinishMax), for: .editingDidEnd)
        self.maxValueTextField?.addTarget(self, action: #selector(editingFinishMin), for: .editingDidEnd)
        self.rangeSlider?.addTarget(self, action: #selector(rangeSliderValueChanged(sender:)),
                                    for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    @objc func editingFinishMin() {
        if let text = self.minValueTextField?.text {
            if text.isEmpty, let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
                self.minValueTextField?.text = "0 " + symbol
            }
            
            if let valueText = self.maxValueTextField?.text,
                let value = Double(valueText), !TextFieldUtil.validateMaxValueText(text, value) {
                ViewUtils.showToast(message: R.string.localizable.invoiceSettingsErrorFrom(), view: self.contentView)
                NotificationCenter.default.post(name: NSNotification.Name(NotificateDoneEnum.disable.rawValue), object: nil)
            } else {
               NotificationCenter.default.post(name: NSNotification.Name(NotificateDoneEnum.enable.rawValue), object: nil)
            }
        }
    }
    
    
   @objc func editingFinishMax() {
        if let text = self.maxValueTextField?.text {
            if text.isEmpty, let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
                self.minValueTextField?.text = "0 " + symbol
            }
            if  let valueText = self.minValueTextField?.text, let value = Double(valueText), !TextFieldUtil.validateMinValueText(text, value, true) {
                ViewUtils.showToast(message: R.string.localizable.invoiceSettingsErrorTo(), view: self.contentView)
                NotificationCenter.default.post(name: NSNotification.Name(NotificateDoneEnum.disable.rawValue), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(NotificateDoneEnum.enable.rawValue), object: nil)
            }
        }
    }
    
    
    @objc func appMovedToBackground() {
        self.contentView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
        return false
    }
    
    @objc func rangeSliderValueChanged(sender: Any?) {
        guard let min = self.rangeSlider?.lowerValue, let max = self.rangeSlider?.upperValue else {
            return
        }
        self.item?.min = Int(round(min))
        self.item?.max = Int(round(max))
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            self.minValueTextField?.text = round(min).formattedWithSeparator + " " + symbol
            self.maxValueTextField?.text = round(max).formattedWithSeparator + " " + symbol
        }
        self.delegate?.updatePaymentRangeMax(max: self.item?.max)
        self.delegate?.updatePaymentRangeMin(min: self.item?.min)
        self.contentView.endEditing(true)
    }
    
    @IBAction func minValueChanged(_ sender: Any) {
        if let valueString = self.minValueTextField?.text {
            if let value = Int(valueString) {
                self.rangeSlider?.lowerValue = Double(value)
                self.item?.min = value
            }
        }
        self.delegate?.updatePaymentRangeMin(min: self.item?.min)
    }
    
    @IBAction func maxValueChanged(_ sender: Any) {
        if let valueString = self.maxValueTextField?.text {
            if let value = Int(valueString) {
                self.rangeSlider?.upperValue = Double(value)
                self.item?.max = value
            }
        }
        self.delegate?.updatePaymentRangeMax(max: self.item?.max)
    }
}
