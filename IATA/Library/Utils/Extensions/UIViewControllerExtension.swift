import UIKit

extension UIViewController {

    internal func generateErrorAlert(error: Error) {
        var message = ""
        if (error is IATAOpError) {
            message = (error as! IATAOpError).localizedDescription
        } else {
            message = error.localizedDescription
        }
        let uiAlert = prepareAlert(title: R.string.localizable.commonTitleError(), message: message)
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonPositiveButtonOk().uppercased(), style: .default, handler: nil))
    }

    internal func generatePaymentAlert(message: String, handler: ((UIAlertAction) -> Void)?) {
        let uiAlert = prepareAlert(title: R.string.localizable.invoiceScreenPleaseConfirmPayment(), message: message)
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonNavBarCancel(), style: .default, handler: nil))
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.invoiceScreenPay(), style: .default, handler: handler))
    }

    internal func generateChangeServerAllert(handlers: [(handler: ((UIAlertAction) -> Void), title: String)]?) {
        let uiAlert = prepareAlert()
        handlers?.forEach({
            uiAlert.addAction(UIAlertAction(title: $0.title, style: .default, handler: $0.handler))
        })

        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonNavBarClose(),
                                        style: .cancel,
                                        handler: nil))
    }

    private func prepareAlert(title: String = "", message: String = "", style: UIAlertControllerStyle = .alert) -> UIAlertController {
        let uiAlert = UIAlertController(title: title, message: message, preferredStyle: style)
        self.present(uiAlert, animated: true, completion: nil)
        return uiAlert
    }

}
