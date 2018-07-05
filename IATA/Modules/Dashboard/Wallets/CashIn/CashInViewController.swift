
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
    
    var totalSum: Double?
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentDownAnimation()
    }
    
    override func viewDidLoad() {
        state = DefaultCashOutState()
        super.viewDidLoad()
        self.initAllSum()
        
        self.loadingView.isHidden = true
        self.navigationController?.delegate = self
        Theme.shared.configureTextFieldStyle(sumTextField, title: R.string.localizable.cashOutScreenPlaceholder())
        Theme.shared.configureTextFieldStyle(assetPicker, title: R.string.localizable.cashOutScreenInCurrency())
        
        
        self.assetPicker.delegate = self
        self.initScrollView()
        self.loadData()
        self.setEnabledConfirm(isEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarBack(), color: UIColor.white)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.cashOutScreenTitle()
    }
    
    override func beginRefreshing() {
        var offset = self.scrollView.contentOffset
        offset.y = -81
        self.refreshControl.beginRefreshing()
        self.scrollView.contentOffset = offset
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
    
    @objc func clickPicker() {
       
    }
    
    @objc func didPullToRefresh() {
        self.loadData()
    }
    
    
    @IBAction func clickConfirm(_ sender: Any) {
        self.beginRefreshing()
        self.state?.cashOut(amount: Formatter.formattedToDouble(valueString: self.sumTextField.text))
            .then(execute: { [weak self] (result: BaseMappable) -> Void in
                guard let strongSelf = self else {
                    return
                }
                
            })
    }
    
    @IBAction func editChanged(_ sender: Any) {
        self.initEnabled()
    }
    
    private func showAlerWithPicker() {
        self.shadowView.isHidden = false
        self.shadowBackground.isHidden = false
    }
    
    private func hideAlerWithPicker() {
        self.shadowView.isHidden = true
        self.shadowBackground.isHidden = true
    }
    
    private func setData(jsonString: String) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
    
    private func initAllSum() {
        self.state?.viewModel.totalSum = totalSum
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sellAll))
        self.sumAllView.addGestureRecognizer(tap)
        
        self.sumAllLabel.color = UIColor.clear
        self.sumAllLabel.sizeToFit()
        self.sumAllLabel.insets = UIEdgeInsetsMake(5, 20, 4, 20)
        self.sumAllLabel.backgroundColor = Theme.shared.greySumAll
        self.sumAllLabel.textColor = Theme.shared.textPinColor
        self.sumAllLabel.cornerRadius = 10
        self.sumAllLabel.commonInit()
        if let amount = self.state?.viewModel.totalSum, let symbol = self.state?.viewModel.symbol {
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
    
    private func initScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        self.refreshControl.attributedTitle = NSAttributedString(string: R.string.localizable.commonLoadingMessage())
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    
}
