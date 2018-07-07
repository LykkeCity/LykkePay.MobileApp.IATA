
import UIKit
import ObjectMapper

class CashInViewController: BaseViewController<CashOutViewModel, DefaultCashOutState>, UINavigationControllerDelegate {
    
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
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tabView: UITableView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var heightAchor: NSLayoutConstraint?
    var heightAchorMaximum: NSLayoutConstraint?
    var totalSum: Double?
    var assertId: String?
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentDownAnimation()
    }
    
    override func viewDidLoad() {
        state = DefaultCashOutState()
        super.viewDidLoad()
        self.initAllSum()
        
        self.loadingView.isHidden = true
        self.navigationController?.delegate = self
        
        self.sumTextField.keyboardType = UIKeyboardType.decimalPad
        
        Theme.shared.configureTextFieldStyle(sumTextField, title: R.string.localizable.cashOutScreenPlaceholder())
        Theme.shared.configureTextFieldStyle(assetPicker, title: R.string.localizable.cashOutScreenInCurrency())
        self.assetPicker.text = R.string.localizable.exchangeSourceUSD()
        
        
        self.assetPicker.delegate = self
        self.loadData()
        self.setEnabledConfirm(isEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func registerCells() {
        tabView.register(PickerTableViewCell.nib, forCellReuseIdentifier: PickerTableViewCell.identifier)
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showAlerWithPicker()
        return false
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.state?.reinitModel(index: indexPath.row)
        self.assetPicker.text = self.state?.viewModel.desiredAssertId
        self.tabView.reloadData()
        self.hideAlerWithPicker()
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
    
    override func beginRefreshing() {
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
    }
    
    override func loadData() {
        self.state?.getDictionary()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.setData(jsonString: result)
            })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.state?.viewModel.items?.count else {
            return 0
        }
        return count
    }
    
    override func showErrorAlert(error: Error) {
        super.showErrorAlert(error: error)
        self.loadingView.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.identifier) as?  PickerTableViewCell else {
            return PickerTableViewCell()
        }
        cell.selectionStyle = .none
        if let items = self.state?.viewModel.items {
            cell.fillCell(name: items[indexPath.row].name, isSelected: items[indexPath.row].isSelected)
        }
        return cell
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
                        strongSelf.endRefreshing()
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
    
    @IBAction func editChanged(_ sender: Any) {
        self.initEnabled()
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
            self.animate(height: 140)
        }, completion: {(finished) in
        })
    }
    
    private func hideAlerWithPicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(height: 0)
        }, completion: {(finished) in
            self.shadowView.isHidden = true
            self.shadowBackground.isHidden = true
        })
    }
    
    private func animate(height: Int) {
        self.heightConstraint.constant = CGFloat(height)
        self.shadowBackground.layoutIfNeeded()
        self.tabView.layoutIfNeeded()
    }
    
    private func setData(jsonString: String) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
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
        self.sumAllLabel.insets = UIEdgeInsetsMake(5, 20, 4, 20)
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
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            setEnabledConfirm(isEnabled: false)
        } else {
            setEnabledConfirm(isEnabled: true)
        }
    }
    
    private func endRefreshing() {
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    
}
