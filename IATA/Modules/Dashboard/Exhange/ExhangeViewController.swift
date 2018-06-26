import UIKit

class ExhangeViewController: BaseNavController {

    @IBOutlet weak var heightSellAll: NSLayoutConstraint!
    @IBOutlet weak var notBaseInfo: UILabel!
    @IBOutlet weak var notBaseSum: UILabel!
    @IBOutlet weak var notBaseIcon: UIImageView!
    
    @IBOutlet weak var baseSum: UILabel!
    @IBOutlet weak var baseInfo: UILabel!
    @IBOutlet weak var baseIcon: UIImageView!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var sellAllView: UIView!
    @IBOutlet weak var sumAllLabel: UiStatusView!
    
    @IBOutlet weak var rateExchange: UILabel!
    @IBOutlet weak var exchangeSumResult: UILabel!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    public lazy var state = DefaultExchangeState()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initTheme()
        
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sellAllView.addGestureRecognizer(tap)
        
        self.sumTextField.addObservers()
        self.sumTextField.symbolValue = UserPreference.shared.getCurrentCurrency()?.symbol
        self.editChanged(self.sumTextField)
        self.initKeyboardEvents()
        self.initAllSum()
        self.loadData()
    }
    
    
    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }
    
    @IBAction func clickChangeBaseAssert(_ sender: Any) {
        self.state?.changeBaseAsset()
        self.sumTextField.text = "0"
        self.sumTextField.symbolValue = self.state?.currentCurrency?.symbol
        self.loadExchangeInfo()
    }
    
    @IBAction func editChanged(_ sender: Any) {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            self.sumTextField.text = "0"
            setEnabledExchange(isEnabled: false)
        } else if let text = self.sumTextField.text {
            var valueString = text
            if text.starts(with: "0") && !text.starts(with: "0.") {
                let fromIndex = text.index(text.startIndex, offsetBy: 1)
                valueString = text.substring(from: fromIndex)
                self.sumTextField.text = valueString
            }
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
    
    
    @objc func sellAll() {
        self.sumTextField.text = sumAllLabel.text
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
    
    
    private func initTheme() {
        self.topView.layer.borderWidth = 0.5
        self.topView.layer.cornerRadius = 4
        self.topView.layer.borderColor = Theme.shared.exchangeTopViewBorderColor.cgColor
    }
    
    private func initAllSum() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sellAllView.addGestureRecognizer(tap)
        
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
    
    private func loadData() {
         self.state?.loadStartData()?
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.loadExchangeInfo()
    }
    
    private func loadExchangeInfo() {
        self.state?.makeExchange(sourceAmount: self.sumTextField.text)
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.initAsset()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError()
            })
    }
    
    //for test
    private func handleError() {
        self.state?.exchangeModel.rate = 0.12
        self.state?.exchangeModel.destAmount = 0
        self.initAsset()
    }
    
    private func initAsset() {
        if let destAmount = self.state?.exchangeModel.destAmount, let sourceAmount = self.state?.exchangeModel.sourceAmount, let symbolDest = self.state?.exchangeModel.symbolDest, let symbolSource = self.state?.exchangeModel.symbolSource, let rate = self.state?.exchangeModel.rate  {
            
            self.exchangeSumResult.text = String(destAmount) + " " + symbolDest
            self.sumTextField.text = String(sourceAmount)
            self.editChanged(self.sumTextField)
            self.rateExchange.text = R.string.localizable.exchangeSourceRate(symbolSource, Formatter.formattedWithSeparator(value: String(rate)), symbolDest)
        }
       
        self.sumAllLabel.text = state?.getTotalBalance()
        if let items = self.state?.getItems() {
            for item in items {
                if let isBase = item.isBase, isBase {
                    initAsset(sum: self.baseSum, info: self.baseInfo, image: self.baseIcon, item: item)
                } else {
                    initAsset(sum: self.notBaseSum, info: self.notBaseInfo, image: self.notBaseIcon, item: item)
                }
            }
        }
    }
    
    private func initAsset(sum: UILabel, info: UILabel, image: UIImageView, item: ExchangeViewModel) {
        if let currency = item.currency, let sumValue = item.sum {
            sum.text = String(sumValue) + " " + currency
        }
        info.text = item.info
        image.image = item.icon
    }
    
}
