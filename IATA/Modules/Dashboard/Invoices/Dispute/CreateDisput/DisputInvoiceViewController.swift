import UIKit

class DisputInvoiceViewController: BaseNavController, Initializer {

    var invoiceId: String?

    @IBOutlet weak var reasonTextField: UITextField!

    let state = DefaultDisputInvoiceState()

    override func viewDidLoad() {
        initializer = self
        super.viewDidLoad()
    }

    override func initNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.barTintColor = Theme.shared.navBarAdditionalColor
        self.navigationItem.title = R.string.localizable.invoiceDisputInvoice().capitalizingFirstLetter()
        self.initRightButton()
        self.initLeftButton()
    }

    private func initRightButton() {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: Theme.shared.textFieldColor)

        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }

    private func initLeftButton() {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.textFieldColor)
        rightButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)

        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.leftBarButtonItem = rightItem
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
                NavPushingUtil.shared.pop(navigationController: self?.navigationController)
            })
        }
    }

    @objc func clickCancel() {
       NavPushingUtil.shared.pop(navigationController: navigationController)
    }


    func getTitle() -> String? {
        return ""
    }

    func getTableView() -> UITableView {
        return UITableView()
    }

    func registerCells() {

    }

}
