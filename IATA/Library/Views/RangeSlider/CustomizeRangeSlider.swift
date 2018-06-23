
import UIKit
import Foundation

class CustomizeRangeSlider: RangeSlider {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.thumbBorderWidth = 0.2
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.thumbBorderWidth = 0.2
    }
}
