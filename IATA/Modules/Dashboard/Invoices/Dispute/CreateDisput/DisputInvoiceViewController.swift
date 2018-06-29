import UIKit
import Foundation

class DisputInvoiceViewController: BaseNavController {

    @IBOutlet weak var height: NSLayoutConstraint!
    var invoiceId: String?
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem?
    @IBOutlet weak var reasonTextField: FloatTextField!

    var rootController: InvoiceViewController?
    var completion: (() -> Void) = {}
    let state = DefaultDisputInvoiceState()

    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.shared.configureTextFieldStyle(self.reasonTextField, title: R.string.localizable.invoiceDisputInvoicePlaceholderTextField())
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func initNavBar() {
        backgroundNavBar = Theme.shared.navBarAdditionalColor
        textTitleColor = Theme.shared.navBarTitle
        
        super.initNavBar()
        self.getNavBar()?.barTintColor = Theme.shared.navBarAdditionalColor
        self.initRightButton()
        self.initLeftButton()
    }
    
    override func getNavView() -> UIView? {
        return self.navView
    }
    
    override func getNavBar() -> UINavigationBar? {
        return self.navBar
    }

    override func getNavItem() -> UINavigationItem? {
        return self.navItem
    }
    
    private func initRightButton() {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: .black)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.getNavItem()?.rightBarButtonItem = rightItem
        self.getNavItem()?.rightBarButtonItem?.customView?.alpha = 0.3
        self.getNavItem()?.rightBarButtonItem?.isEnabled = false
    }

    private func initLeftButton() {
        let leftButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: .black)
        leftButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.getNavItem()?.leftBarButtonItem = leftItem
    }
    
    
    @IBAction func editingChanged(_ sender: Any) {
        if let text = self.reasonTextField.text {
            self.setEnabled(isEnabled: !text.removingWhitespaces().isEmpty)
        } 
    }
    
    @IBAction func startEditing(_ sender: UITextField!) {
        if let isEmpty = self.reasonTextField.text?.isEmpty {
            self.setEnabled(isEnabled: !isEmpty)
        }
    }

    @objc func clickDone() {
        let model = DisputInvoiceRequest()
        model?.invoiceId = invoiceId
        model?.reason = reasonTextField.text
        if let model = model {
        self.state?.makeDisputInvoice(model: model)
            .then(execute: { [weak self] (result: Void) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.rootController?.beginRefreshing()
                strongSelf.dismiss(animated: true, completion: strongSelf.completion)
            })
        }
    }

    @objc func clickCancel() {
        self.dismiss(animated: true, completion: nil)
    }


    override func getTitle() -> String? {
        return R.string.localizable.invoiceDisputInvoice().capitalizingFirstLetter()
    }

    override func getTableView() -> UITableView {
        return UITableView()
    }

    override func registerCells() {

    }
    
    private func setEnabled(isEnabled: Bool) {
        self.getNavItem()?.rightBarButtonItem?.customView?.alpha = isEnabled ? 1 : 0.3
        self.getNavItem()?.rightBarButtonItem?.isEnabled = isEnabled
    }

}
