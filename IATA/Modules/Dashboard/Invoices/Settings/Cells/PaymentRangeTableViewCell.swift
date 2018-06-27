import UIKit

class PaymentRangeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var maxValueLabel: UILabel!
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
                self.minValueTextField?.text = Formatter.formattedWithSeparator(value: String(min)) + " " + symbol
            }
            
            if let max = item.max, let symbol =  UserPreference.shared.getCurrentCurrency()?.symbol {
                self.maxValueTextField?.text = Formatter.formattedWithSeparator(value: String(max)) + " " + symbol
            }
            
            self.minValueChanged(self.minValueTextField)
            self.maxValueChanged(self.maxValueTextField)
            
            if let maxValueRange = item.maxRangeInBaseAsset {
                self.rangeSlider?.maximumValue = maxValueRange
                self.maxValueLabel.text = getMaxValue(maxValue: maxValueRange)
            }
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    @IBAction func editingDidEnd(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.enable.rawValue), object: nil)
    }
    
    @IBAction func editingDidBegin(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.disable.rawValue), object: nil)
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
    
    @IBAction func minValueChanged(_ sender: Any) {
        if let valueString = self.minValueTextField?.text {
            if let value = Int(valueString) {
                self.rangeSlider?.lowerValue = Double(value)
                self.item?.min = value
            }
        }
        self.delegate?.updatePaymentRangeMin(min: self.item?.min)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Theme.shared.configureTextFieldStyle(self.minValueTextField, title: R.string.localizable.invoiceSettingsRangeFrom())
        Theme.shared.configureTextFieldStyle(self.maxValueTextField, title: R.string.localizable.invoiceSettingsRangeTo())
        
        self.minValueTextField?.keyboardType = UIKeyboardType.decimalPad
        self.maxValueTextField?.keyboardType = UIKeyboardType.decimalPad
        
        self.minValueTextField?.delegate = self
        self.maxValueTextField?.delegate = self
        
        self.minValueTextField?.addTarget(self, action: #selector(editingFinishMin), for: .editingDidEnd)
        self.maxValueTextField?.addTarget(self, action: #selector(editingFinishMax), for: .editingDidEnd)
        self.rangeSlider?.addTarget(self, action: #selector(rangeSliderValueChanged(sender:)),
                                    for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    //todo rewrite - in future
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.maxValueTextField) {
            
            if let text = self.maxValueTextField?.getOldText(), let textNsString = text as? NSString {
                
                let newString = textNsString.replacingCharacters(in: range, with: string)
                if let character = newString.characters.last, String(character).elementsEqual(".") {
                    return false
                }
                
                if  let maxValueRange = self.item?.maxRangeInBaseAsset,
                    !(TextFieldUtil.validateMaxValue(newString: newString, maxValue: maxValueRange, range: range, replacementString: string, symbol: self.maxValueTextField?.symbolValue)) {
                    return false
                }
                
            }
        }
        return true
    }
    
    @objc func editingFinishMin() {
        if let text = self.minValueTextField?.text {
            if text.isEmpty, let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
                self.minValueTextField?.text = "0 " + symbol
            }
            
            if let valueText = self.maxValueTextField?.text,
                let value = Double(valueText), !TextFieldUtil.validateMaxValueText(text, value) {
                ViewUtils.shared.showToast(message: R.string.localizable.invoiceSettingsErrorFrom(), view: self.contentView)
                NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.disable.rawValue), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.enable.rawValue), object: nil)
            }
        }
    }
    
    
    @objc func editingFinishMax() {
        if let text = self.maxValueTextField?.text {
            if text.isEmpty, let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
                self.minValueTextField?.text = "0 " + symbol
            }
            if  let valueText = self.minValueTextField?.text, let value = Double(valueText),
                !TextFieldUtil.validateMinValueText(text, value, true) {
                //check max value and min value
                ViewUtils.shared.showToast(message: R.string.localizable.invoiceSettingsErrorTo(), view: self.contentView)
                NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.disable.rawValue), object: nil)
           
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.enable.rawValue), object: nil)
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
      
        self.minValueTextField?.addObservers()
        self.maxValueTextField?.addObservers()
        
        self.minValueTextField?.text = Formatter.formattedWithSeparator(value: String(Int(round(min))))
        self.maxValueTextField?.text = Formatter.formattedWithSeparator(value: String(Int(round(max))))
        self.delegate?.updatePaymentRangeMax(max: self.item?.max)
        self.delegate?.updatePaymentRangeMin(min: self.item?.min)
        self.contentView.endEditing(true)
    }
    
    private func getMaxValue(maxValue: Double) -> String {
        let intValue = 1000 * Int((maxValue / 1000.0).rounded())
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        if let value = formatter.string(for: Double(intValue)/1000){
            return R.string.localizable.invoiceSettingsMaxRange(value)
        } else {
            return ""
        }
    }
}
