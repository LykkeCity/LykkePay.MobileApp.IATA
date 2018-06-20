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
        if let imageNormal = thumbImage(for: .normal) {
            self.setThumbImage(self.scaleToSize(newSize:
                CGSize(width: CGFloat(100), height: CGFloat(100)),
                image: imageNormal), for: .normal)
        }
        
        if let imageHighlighter = thumbImage(for: .highlighted) {
            self.setThumbImage(self.scaleToSize(newSize:
                CGSize(width: CGFloat(100), height: CGFloat(100)),
                image: imageHighlighter), for: .highlighted)
        }
        
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
    
    func scaleToSize(newSize: CGSize, image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage
    }
}
