
import UIKit

class DisputeView: UIView {
    @IBOutlet weak internal var contentView: UIView!
    @IBOutlet weak var button: UIButton!
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaults()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupDefaults()
    }
    
    
    private func setupDefaults() {
        Bundle.main.loadNibNamed(R.nib.disputeView.name, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
