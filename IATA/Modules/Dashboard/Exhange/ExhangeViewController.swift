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
        
        self.sumTextField.delegate = self
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
        self.exchangeSumResult.text = "0"
        self.rateExchange.text = ""
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
            self.initAmounts()
            setEnabledExchange(isEnabled: true)
        }
    }
    
    @IBAction func clickConfirm(_ sender: Any) {
        func makePayment(alert: UIAlertAction!) {
            let viewController = PinViewController()
            viewController.isValidationTransaction = true
            viewController.completion = {
                self.makeExchange()
            }
            self.navigationController?.present(viewController, animated: true, completion: nil)
            
        }
    }
    
    
    @objc func sellAll() {
        self.sumTextField.text = sumAllLabel.text
        self.editChanged(self.sumTextField)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.sumTextField) {
            
            if let text = self.sumTextField.getOldText(), let textNsString = text as? NSString {
                
                let newString = textNsString.replacingCharacters(in: range, with: string)
                if let text = self.sumTextField.text, text.contains("."), string.elementsEqual(".") {
                    return false
                }
                
                if let indexOf = newString.index(of: ".") {
                    let valueString = newString.substring(from: indexOf)
                    
                    if valueString.characters.count > 6 {
                        return false
                    }
                }
                
                if !(TextFieldUtil.validateMinValue(newString: newString, minValue:  0, range: range, replacementString: string, true)) {
                    return false
                }
                
                if let maxValue = self.state?.maxValue, !(TextFieldUtil.validateMaxValue(newString: newString, maxValue: maxValue, range: range, replacementString: string)){
                    ViewUtils.shared.showToast(message: R.string.localizable.invoiceScreenErrorChangingAmount(), view: self.view)
                    return false
                    
                }
            }
            
        }
        return true
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
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.loadExchangeInfo()
    }
    
    private func loadExchangeInfo() {
        //todo get info
        self.state?.exchangeModel.rate = 0.12
        if let text = self.sumTextField.text {
            self.state?.exchangeModel.sourceAmount = Double(text)
        }
        self.initAsset()
       /* self.state?.makeExchange(sourceAmount: self.sumTextField.text)
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
                strongSelf.handleError(error: error)
            })*/
    }
    
    private func makeExchange() {
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
                strongSelf.handleError(error: error)
            })
    }
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
    }
    
    private func initAsset() {
        self.initAmounts()
        self.editChanged(self.sumTextField)
        
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
    
    private func initAmounts() {
        if let sourceAmountString = self.sumTextField.text, let souceAmount = Double(sourceAmountString), let symbolDest = self.state?.exchangeModel.symbolDest, let symbolSource = self.state?.exchangeModel.symbolSource, let rate = self.state?.exchangeModel.rate  {
            
            self.exchangeSumResult.text = Formatter.formattedWithSeparator(value: String(souceAmount * rate)) + " " + symbolDest
            self.rateExchange.text = R.string.localizable.exchangeSourceRate(symbolSource, Formatter.formattedWithSeparator(value: String(rate)), symbolDest)
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
