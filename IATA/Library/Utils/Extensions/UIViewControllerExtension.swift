import UIKit

extension UIViewController {

    func generateErrorAlert(error: Error) {
        var message = ""
        if (error is IATAOpError) {
            message = (error as! IATAOpError).localizedDescription
        } else {
            message = error.localizedDescription
        }
        let uiAlert = prepareAlert(title: R.string.localizable.commonTitleError(), message: message)
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonPositiveButtonOk().uppercased(), style: .default, handler: nil))
    }

    func generatePaymentAlert(message: String, handler: ((UIAlertAction) -> Void)?) {
        let uiAlert = prepareAlert(title: R.string.localizable.invoiceScreenPleaseConfirmPayment(), message: message)
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonNavBarCancel(), style: .cancel, handler: nil))
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.invoiceScreenPay(), style: .default, handler: handler))
    }

    private func prepareAlert(title: String, message: String) -> UIAlertController {
        let uiAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        return uiAlert
    }

}
