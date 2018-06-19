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
            self.minValueTextField?.text = item.min?.description
            self.maxValueTextField?.text = item.max?.description
            
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
        
        self.minValueTextField?.delegate = self
        self.maxValueTextField?.delegate = self
        self.rangeSlider?.addTarget(self, action: #selector(rangeSliderValueChanged(sender:)),
                                    for: .valueChanged)
        
         NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
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
        self.minValueTextField?.text = String(Int(round(min)))
        self.maxValueTextField?.text = String(Int(round(max)))
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == self.minValueTextField) {
            guard let valueString = self.maxValueTextField?.text else {
                return false
            }
            
            guard let value = Double(valueString) else {
                return false
            }
            
            return TextFieldUtil.validateMaxValue(textField: textField, maxValue: value, range: range, replacementString: string)
            
        }
        
        if(textField == self.maxValueTextField) {
            guard let valueString = self.minValueTextField?.text else {
                return false
            }
            
            guard let value = Double(valueString) else {
                return false
            }
            
            return TextFieldUtil.validateMinValue(textField: textField, minValue:  value, range: range, replacementString: string)
        }
        return true
    }
}
