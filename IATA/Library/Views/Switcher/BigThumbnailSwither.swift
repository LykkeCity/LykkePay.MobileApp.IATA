import UIKit

class BigThumbnailSwither : UISlider {
    
    weak var delegate: OnSwitchStateChanged?
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 10.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        self.addTarget(self, action: #selector(sliderValueChanged(slider:)),
                       for: UIControlEvents.valueChanged)

    }
    
    fileprivate func initThumbColor() {
        if (self.value == 0) {
            self.thumbTintColor = nil
        } else {
            self.thumbTintColor = Theme.shared.greenColor
        }
    }
    
    @objc func handleTap(sender:UISlider!) {
        self.setValue(self.value == 0 ?  1 : 0, animated: true)
        self.delegate?.stateChanged(isSelected: self.value == 1)
        initThumbColor()
    }
    
    @objc func sliderValueChanged(slider: UISlider!) {
        initThumbColor()
    }
    
    internal func setChecked(isChecked: Bool!) {
        self.value = isChecked ? 1 : 0
        self.initThumbColor()
    }
}
