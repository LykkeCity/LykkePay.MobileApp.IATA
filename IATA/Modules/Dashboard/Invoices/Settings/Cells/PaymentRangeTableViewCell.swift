import MaterialTextField
import UIKit
import WARangeSlider

class PaymentRangeTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var minValueTextField: MFTextField!
    @IBOutlet weak var maxValueTextField: MFTextField!
    
    @IBAction func minValueChanged(_ sender: Any) {
        if let valueString = self.minValueTextField.text as? String {
            if var value = Int(valueString) {
                self.rangeSlider.lowerValue = Double(value)
                FilterPreference.shared.saveMinValue(value)
            }
        }
    }
    
    @IBAction func maxValueChanged(_ sender: Any) {
        if let valueString = self.maxValueTextField.text as? String {
            if var value = Int(valueString) {
                self.rangeSlider.upperValue = Double(value)
                FilterPreference.shared.saveMaxValue(value)
            }
        }
    }
    
    var item: InvoiceSettingPaymentRangeItemModel? {
        didSet {
            guard let item = item else {
                return
            }
            minValueTextField.text = item.min?.description
            maxValueTextField.text = item.max?.description
            
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
}
