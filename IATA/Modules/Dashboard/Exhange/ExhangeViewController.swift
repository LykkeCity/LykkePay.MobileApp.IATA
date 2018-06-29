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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rateExchange: UILabel!
    @IBOutlet weak var exchangeSumResult: UILabel!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var refresh = UIRefreshControl()
    public lazy var state = DefaultExchangeState()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initTheme()
        
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sellAllView.addGestureRecognizer(tap)
        
        self.initSumTextField()
        self.initKeyboardEvents()
        self.initAllSum()
        
        self.initScrollView()
        self.beginRefresh()
        self.loadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }
    
    @objc func didPullToRefresh() {
        self.reloadData()
    }
    
    @objc func sellAll() {
        self.sumTextField.text = Formatter.formattedWithSeparator(valueDouble: self.state.viewModel.maxValue)
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
    
    @IBAction func clickChangeBaseAssert(_ sender: Any) {
        self.state.viewModel.changeBaseAsset()
        self.loadExchangeInfo(isNeedMakePayment: false)
    }
    
    @IBAction func editChanged(_ sender: Any) {
        initEnabled()
    }
    
    @IBAction func clickConfirm(_ sender: Any) {
        self.view.endEditing(true)
        self.beginRefresh()
        self.loadExchangeInfo(isNeedMakePayment: true)
    }
  
    func loadData() {
        self.loadDataInfo(isNeedToCleanUp: false)
    }
    
    @objc private func reloadData() {
        self.loadDataInfo(isNeedToCleanUp: false)
    }
    
    func beginRefresh() {
        var offset = self.scrollView.contentOffset
        offset.y = -81
        self.refresh.beginRefreshing()
        self.scrollView.contentOffset = offset
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.sumTextField) {
            self.sumTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
            if let text = self.sumTextField.getOldText(), let textNsString = text as? NSString {
                
                let newString = textNsString.replacingCharacters(in: range, with: string)
                                
                if let maxValue = self.state.viewModel.maxValue, !(TextFieldUtil.validateMaxValue(newString: newString, maxValue: maxValue, range: range, replacementString: string, symbol: self.sumTextField.symbolValue)){
                    ViewUtils.shared.showToast(message: R.string.localizable.invoiceScreenErrorChangingAmount(), view: self.view)
                    return false
                    
                }
            }
            
        }
        return true
    }
    
    func initAsset(model: ExchangeModel?) {
        self.initAmounts(model: model)
        
        self.sumAllLabel.text = state.getTotalBalance()
        for item in self.state.viewModel.items {
            if let isBase = item.isBase, isBase {
                initAsset(sum: self.baseSum, info: self.baseInfo, image: self.baseIcon, item: item)
            } else {
                initAsset(sum: self.notBaseSum, info: self.notBaseInfo, image: self.notBaseIcon, item: item)
            }
        }
        self.refresh.endRefreshing()
    }
    
    func initEnabled() {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            setEnabledExchange(isEnabled: false)
        } else if let text = self.sumTextField.text {
            if let last = text.characters.last, let separator = NSLocale.current.decimalSeparator, !String(last).elementsEqual(separator) {
                self.initAmounts(model: nil)
            }
            setEnabledExchange(isEnabled: true)
        }
    }
    
    func setEnabledExchange(isEnabled: Bool) {
        self.btnConfirm.isEnabled = isEnabled
        self.btnConfirm.alpha = isEnabled ? 1 : 0.2
        self.sumTextField.alpha = isEnabled ? 1 : 0.2
        if (isEnabled) {
            //todo send request for exchange view
        }
    }
    
    private func initScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        self.refresh.attributedTitle = NSAttributedString(string: R.string.localizable.commonLoadingMessage())
        self.refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refresh)
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
    
    
    private func initKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
   
    
    private func initAmounts(model: ExchangeModel?) {
        if let exhcnageModel = model {
            self.state.viewModel.exchangeModel = exhcnageModel
        }
        var sourceAmount: Double = 0
        if let sourceAmountString = self.sumTextField.text,
           let souceAmountDouble = Formatter.formattedToDouble(valueString:sourceAmountString) {
            sourceAmount = souceAmountDouble
        }
        if let symbolDest = self.state.viewModel.exchangeModel.symbolDest,
            let symbolSource = self.state.viewModel.exchangeModel.symbolSource,
            let rate = self.state.viewModel.exchangeModel.rate  {
            self.sumTextField.symbolValue = symbolSource
            self.sumTextField.text = Formatter.formattedWithSeparator(valueDouble: sourceAmount)
            self.exchangeSumResult.text = Formatter.formattedWithSeparator(valueDouble: sourceAmount * rate) + " " + symbolDest
            self.rateExchange.text = R.string.localizable.exchangeSourceRate(symbolSource, Formatter.formattedWithSeparator(valueDouble: rate), symbolDest)
        }
    }
    
    private func initAsset(sum: UILabel, info: UILabel, image: UIImageView, item: ExchangeViewModel) {
        if let currency = item.currency, let sumValue = item.sum {
            sum.text = Formatter.formattedWithSeparator(valueDouble: sumValue) + " " + currency
        }
        var currency = ""
        if let isUsd = item.assetId?.isUsd(), isUsd {
            currency = R.string.localizable.exchangeSourceUSD()
        } else {
            currency = R.string.localizable.exchangeSourceEURO()
        }
        
        if let isBase = item.isBase, isBase {
            info.text = R.string.localizable.exchangeSourceSell(currency)
        } else {
            info.text = R.string.localizable.exchangeSourceBuy(currency)
        }
        image.image = item.icon
    }
    
    private func initSumTextField() {
        self.sumTextField.delegate = self
        self.sumTextField.addObservers()
        self.sumTextField.text = "0"
        self.sumTextField.symbolValue = UserPreference.shared.getCurrentCurrency()?.symbol
        self.editChanged(self.sumTextField)
    }
}


