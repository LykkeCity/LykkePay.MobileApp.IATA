import UIKit

class DisputInvoiceViewController: BaseNavController {

    var invoiceId: String?

    @IBOutlet weak var reasonTextField: UITextField!

    let state = DefaultDisputInvoiceState()

    override func viewDidLoad() {
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
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: .black)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.customView?.alpha = 0.3
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func initLeftButton() {
        let leftButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarCancel(), color: .black)
        leftButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftItem
    }

    @IBAction func startEditing(_ sender: UITextField!) {
        self.navigationItem.rightBarButtonItem?.customView?.alpha = 1
        self.navigationItem.rightBarButtonItem?.isEnabled = false
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
                //NavPushingUtil.shared.pop(navigationController: self?.navigationController)
                self?.dismiss(animated: true, completion: {

                })
                
            })
        }
    }

    @objc func clickCancel() {
       //NavPushingUtil.shared.pop(navigationController: navigationController)
        self.dismiss(animated: true) {
         
        }
    }
}
