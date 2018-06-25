import UIKit

class ExhangeViewController: BaseNavController {

    @IBOutlet weak var heightSellAll: NSLayoutConstraint!
    @IBOutlet weak var notBaseInfo: UILabel!
    @IBOutlet weak var notBaseSum: UILabel!
    @IBOutlet weak var notBaseIcon: UIImageView!
    
    @IBOutlet weak var baseInfo: UILabel!
    @IBOutlet weak var baseSum: UIStackView!
    @IBOutlet weak var baseIcon: UIImageView!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var sellAllView: UIView!
    @IBOutlet weak var sumAllLabel: UiStatusView!
    
    @IBOutlet weak var rateExchange: UILabel!
    @IBOutlet weak var exchangeSumResult: UILabel!
    @IBOutlet weak var topView: UIView!
    
    
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initTheme()
        
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        
        editChanged(self.sumTextField)
        self.initKeyboardEvents()
        self.initAllSum()
    }
    
    
    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }
    @IBAction func clickChangeBaseAssert(_ sender: Any) {
    }
    
    @IBAction func editChanged(_ sender: Any) {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            self.sumTextField.text = "0"
            setEnabledExchange(isEnabled: false)
        } else {
            setEnabledExchange(isEnabled: true)
        }
    }
    
    @IBAction func clickConfirm(_ sender: Any) {
        let viewController = PinViewController()
        viewController.isValidationTransaction = true
        viewController.completion = {
            //todo exchange
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstraint.constant = keyboardSize.size.height/2 + 70
                self.sellAllView.isHidden = true
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 0
        self.sellAllView.isHidden = false
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func sellAll() {
    
    }
    
    private func initTheme() {
        self.topView.layer.borderWidth = 0.5
        self.topView.layer.cornerRadius = 4
        self.topView.layer.borderColor = Theme.shared.exchangeTopViewBorderColor.cgColor
    }
    
    private func initAllSum() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sellAllView.addGestureRecognizer(tap)
        
        //self.sumAllLabel.text = todo sume
        self.sumAllLabel.color = UIColor.clear
        self.sumAllLabel.sizeToFit()
        self.sumAllLabel.insets = UIEdgeInsetsMake(5, 20, 4, 20)
        self.sumAllLabel.backgroundColor = Theme.shared.greySumAll
        self.sumAllLabel.textColor = Theme.shared.textPinColor
        self.sumAllLabel.cornerRadius = 10
        self.sumAllLabel.commonInit()
    }
    
    private func setEnabledExchange(isEnabled: Bool) {
        self.btnConfirm.isEnabled = isEnabled
        self.btnConfirm.alpha = isEnabled ? 1 : 0.2
        self.sumTextField.alpha = isEnabled ? 1 : 0.2
        if (isEnabled) {
            //todo send request for exchange view
        }
    }
    
    private func initKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}
