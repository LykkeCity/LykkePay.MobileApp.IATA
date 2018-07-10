
import UIKit
import ObjectMapper

class CashInViewController: BaseViewController<CashOutViewModel, DefaultCashOutState>, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var sumAllView: UIView!
    @IBOutlet weak var sumAllLabel: UiStatusView!
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var desiredAssertView: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var assetPicker: FloatTextField!
    @IBOutlet weak var shadowBackground: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    let numberOfRows = 10000//Int.max
  
    var heightAchor: NSLayoutConstraint?
    var heightAchorMaximum: NSLayoutConstraint?
    var totalSum: Double?
    var assertId: String?
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentDownAnimation()
    }
    
    override func viewDidLoad() {
        state = DefaultCashOutState()
        self.tabBarController?.tabBar.isTranslucent = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.tabBarController?.tabBar.isHidden = true
          })
        
        self.view?.layoutIfNeeded()
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        self.sumTextField.keyboardType = UIKeyboardType.decimalPad
        
        Theme.shared.configureTextFieldStyle(sumTextField, title: R.string.localizable.cashOutScreenPlaceholder())
        Theme.shared.configureTextFieldStyle(assetPicker, title: R.string.localizable.cashOutScreenInCurrency())
        self.assetPicker.text = R.string.localizable.exchangeSourceUSD()
        self.initAllSum()
        
        self.initShadow()
        self.assetPicker.delegate = self
        self.loadData()
        self.setEnabledConfirm(isEnabled: false)
        
        // Connect data:
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.selectRow(numberOfRows / 2 + 1, inComponent: 0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.showAlerWithPicker()
        return false
    }
    
    override func beginRefreshing(){
        refreshControl.beginRefreshing()
        let contentOffset = CGPoint(x: 0, y: -refreshControl.bounds.size.height)
        self.scrollView.setContentOffset(contentOffset, animated: true)
        isRefreshing = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func getNavView() -> UIView? {
        return navView
    }
    
    override func getNavBar() -> UINavigationBar? {
        return navBar
    }
    
    override func getNavItem() -> UINavigationItem? {
        return navItem
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarClose(), color: UIColor.white)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.cashOutScreenTitle()
    }
    
    
    @objc override func loadData() {
        self.state?.getDictionary()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.setData(jsonString: result)
            })
    }
    
    
    override func showErrorAlert(error: Error) {
        super.showErrorAlert(error: error)
        self.superviewDidDisappear()
    }
    
    override func addRefreshControl() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        self.refreshControl.attributedTitle = NSAttributedString(string: R.string.localizable.commonLoadingMessage())
        self.refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func sellAll() {
        self.sumTextField.text = Formatter.formattedWithSeparator(valueDouble: self.state?.viewModel.totalSum)
        self.editChanged(self.sumTextField)
    }
    
    @objc func didPullToRefresh() {
        self.loadData()
    }
    
    
    @IBAction func clickConfirm(_ sender: Any) {
        var resultTotalSum = 0.0
        if let totalSum = self.state?.viewModel.totalSum {
            let totalSumString = Formatter.formattedWithSeparator(valueDouble: totalSum)
            if let res =  Formatter.formattedToDouble(valueString: totalSumString) {
                resultTotalSum = res
            }
        }
        if let value = Formatter.formattedToDouble(valueString: self.sumTextField.text), value <= resultTotalSum {
            let viewController = PinViewController()
            viewController.navController = self
            viewController.isValidationTransaction = true
            viewController.messageTouch = R.string.localizable.exchangeSourcePayConfirmation()
            viewController.completion = {
                self.state?.cashOut(amount: Formatter.formattedToDouble(valueString: self.sumTextField.text))
                    .then(execute: { [weak self] (result: BaseMappable) -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.superviewDidDisappear()
                        strongSelf.navigationController?.popViewController(animated: true)
                    }).catch(execute: { [weak self] error -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.showErrorAlert(error: error)
                })
            }
            self.navigationController?.present(viewController, animated: true, completion: nil)
        } else {
            self.showErrorAlert(error: getError(R.string.localizable.commonOverPayError()))
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let itemsCount = self.state?.viewModel.items?.count else {
            return ""
        }
        return self.state?.viewModel.items?[row % itemsCount].name
    }
    
 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let itemCount = self.state?.viewModel.items?.count else {
            return
        }
        self.state?.reinitModel(index: row % itemCount)
        self.assetPicker.text = self.state?.viewModel.desiredAssertId
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func editChanged(_ sender: Any) {
        self.initEnabled()
    }
    
    @objc func hideShadow() {
        self.pickerView.reloadAllComponents()
        self.hideAlerWithPicker()
    }
    
    
    @objc func pickerTap() {
       self.hideAlerWithPicker()
    }
    
    private func getError(_ message: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: message, code: 123, userInfo: userInfo)
    }
    
    private func showAlerWithPicker() {
        self.heightConstraint.constant = 0
        self.shadowView.isHidden = false
        self.shadowBackground.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(height: 130)
            self.shadowBackground.alpha = 0.4
        }, completion: {(finished) in
        })
    }
    
    private func hideAlerWithPicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(height: 0)
            self.shadowBackground.alpha = 0
        }, completion: {(finished) in
            self.shadowView.isHidden = true
            self.shadowBackground.isHidden = true
        })
    }
    
    private func animate(height: Int) {
        self.heightConstraint.constant = CGFloat(height)
        self.shadowBackground.layoutIfNeeded()
        self.pickerView.layoutIfNeeded()
    }
    
    private func setData(jsonString: String) {
        self.state?.mapping(jsonString: jsonString)
        self.pickerView.reloadAllComponents()
        self.superviewDidDisappear()
    }
    
    private func initAllSum() {
        self.state?.viewModel.totalSum = totalSum
        self.state?.viewModel.assertId = assertId
        self.sumTextField.symbolValue = self.state?.viewModel.symbol
        self.sumTextField.text = "0"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sumAllView.addGestureRecognizer(tap)
        
        self.sumAllLabel.color = UIColor.clear
        self.sumAllLabel.sizeToFit()
        self.sumAllLabel.insets = UIEdgeInsetsMake(7, 20, 6, 20)
        self.sumAllLabel.backgroundColor = Theme.shared.greySumAll
        self.sumAllLabel.textColor = Theme.shared.textPinColor
        self.sumAllLabel.cornerRadius = 10
        self.sumAllLabel.commonInit()
        if let amount = self.state?.viewModel.totalSum, let symbol = self.sumTextField.symbolValue {
            self.sumAllLabel.text = Formatter.formattedWithSeparator(valueDouble: amount) + " " + symbol
        }
    }
    
    private func setEnabledConfirm(isEnabled: Bool) {
        self.btnConfirm.isEnabled = isEnabled
        self.btnConfirm.alpha = isEnabled ? 1 : 0.2
    }
    
    private func initEnabled() {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || Formatter.formattedToDouble(valueString: text) == 0 {
            setEnabledConfirm(isEnabled: false)
        } else {
            setEnabledConfirm(isEnabled: true)
        }
    }
    
    
    private func initShadow() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let tapHideShadow: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideShadow))
        tapHideShadow.cancelsTouchesInView = false
        self.shadowBackground.addGestureRecognizer(tapHideShadow)
        
        pickerView.isUserInteractionEnabled = true
    }
    
}
