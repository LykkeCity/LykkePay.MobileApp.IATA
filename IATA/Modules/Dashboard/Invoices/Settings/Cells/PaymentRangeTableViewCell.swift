import MaterialTextField
import UIKit
import WARangeSlider

class PaymentRangeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var minValueTextField: MFTextField!
    @IBOutlet weak var maxValueTextField: MFTextField!
    
    @IBAction func minValueChanged(_ sender: Any) {
        if let valueString = self.minValueTextField.text {
            if let value = Int(valueString) {
                self.rangeSlider.lowerValue = Double(value)
                self.item?.min = value
            }
        }
    }
    
    @IBAction func maxValueChanged(_ sender: Any) {
        if let valueString = self.maxValueTextField.text {
            if let value = Int(valueString) {
                self.rangeSlider.upperValue = Double(value)
                self.item?.max = value
            }
        }
    }
    
    var item: InvoiceSettingPaymentRangeItemModel? {
        didSet {
            guard let item = self.item else {
                return
            }
            self.minValueTextField.text = item.min?.description
            self.maxValueTextField.text = item.max?.description
            
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
        
        Theme.shared.configureTextFieldStyle(self.minValueTextField)
        Theme.shared.configureTextFieldStyle(self.maxValueTextField)
        
        self.minValueTextField.placeholder = "Invoice.Settings.Range.From".localize()
        self.maxValueTextField.placeholder = "Invoice.Settings.Range.To".localize()
        
        self.minValueTextField.delegate = self
        self.maxValueTextField.delegate = self
        self.rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(sender:)),
                                   for: .valueChanged)
    }
    
    @objc func rangeSliderValueChanged(sender: Any?) {
        self.minValueTextField.text = String(Int(round(rangeSlider.lowerValue)))
        self.maxValueTextField.text = String(Int(round(rangeSlider.upperValue)))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == self.minValueTextField) {
            guard let valueString = self.maxValueTextField.text else {
                return false
            }
            
            guard let value = Double(valueString) else {
                return false
            }
            
            return TextFieldUtil.validateMaxValue(textField: textField, maxValue: value, range: range, replacementString: string)
            
        }
        
        if(textField == self.maxValueTextField) {
            guard let valueString = self.minValueTextField.text else {
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
