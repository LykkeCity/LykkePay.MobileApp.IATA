import Foundation
import UIKit
import ObjectMapper

extension InvoiceViewController {
    
    // MARK: payments process
    func makePayment(alert: UIAlertAction!) {
        self.view.endEditing(true)
        if isPayingAvailable() {
            let viewController = PinViewController()
            viewController.isValidationTransaction = true
            viewController.navController = self
            viewController.messageTouch = R.string.localizable.invoiceScreenPayConfirmation()
            let items = self.state?.getItemsId()
            viewController.completion = {
                self.state?.makePayment(items: items, amount: self.sumTextField.text)
                    .then(execute: {[weak self] (result: BaseMappable) -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.paymentSuccess()
                    }).catch(execute: { [weak self] error -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                    strongSelf.handleError(error: error)
                })
        }
            self.navigationController?.present(viewController, animated: true, completion: nil)
        } else {
            self.showErrorAlert(error: IATAOpError.serverError(message: R.string.localizable.invoiceScreenPayOverpaying()))
        }
    }
    
    func paymentSuccess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.loadData()
        })
        self.hideMenu()
    }
    
    func getAmount() {
        self.state?.getAmount()
            .then(execute: { [weak self] (result: PaymentAmount) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.saveAmount(amount: result.amountToPay)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }
    
    
    private func saveAmount(amount: Double?) {
        if let amountValue = amount, self.downViewHeightConstraint.constant != 0 {
            self.state?.amount = amountValue
            self.sumTextField.text = Formatter.formattedWithSeparator(valueDouble: amountValue)
        }
        self.sumChanged(self.sumTextField)
        self.loadView(isShowLoading: true, isHiddenSelected: false)
    }
    
    func animate(isShow: Bool) {
        UIView.animate(withDuration: 0.5 , animations: {
            self.downView.alpha = isShow ? 1 : 0
            self.payHeight.constant = isShow ? 48 : 0
            self.downViewHeightConstraint.constant = isShow ? 90 : 0
            self.btnPay.layoutIfNeeded()
            self.downView.layoutIfNeeded()
        }, completion: {(finished) in
        })
        view.endEditing(!isShow)
        if !isShow {
            self.state?.clearSelectedItems()
        }
        
        self.loadView(isShowLoading: false, isHiddenSelected: true)
    }
    
    func loadView(isShowLoading: Bool, isHiddenSelected: Bool) {
        self.loading.isHidden = isShowLoading
        self.sumTextField.isHidden = isHiddenSelected
        self.selectedItemTextField.isHidden = isHiddenSelected
        isHiddenSelected ? self.loading.startAnimating() : self.loading.stopAnimating()
        setEnabledPay(isEnabled: isShowLoading)
    }
    
    func setEnabledPay(isEnabled: Bool) {
        self.btnPay.isEnabled = isEnabled
        self.btnPay.alpha = isEnabled ? 1 : 0.2
        self.sumTextField.alpha = isEnabled ? 1 : 0.2
    }
    
    func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.animate(isShow: false)
        self.beginRefreshing()
        self.loadData()
    }

     func checkCurrentBalance() {
        if let id = UserPreference.shared.getCurrentCurrency()?.id {
            self.walletsState?.getWalletsStringJson(id: id)
                .then(execute: { [weak self] (result: String) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                        strongSelf.mappingBalance(jsonString: result)
                })
        }
    }

    private func mappingBalance(jsonString: String!) {
        self.walletsState?.mapping(jsonString: jsonString)
        var balance = 0.0
        if let wallets = self.walletsState?.items {
        for wallet in wallets {
            if let convertedBalance = wallet.totalConvertedBalance, let assertId = wallet.assetId, let baseAseertId = UserPreference.shared.getCurrentCurrency()?.id, assertId.elementsEqual(baseAseertId) {
                balance += convertedBalance
                }
            }
        }
       self.totalBalance = balance
    }

    private func isPayingAvailable() -> Bool {
        checkCurrentBalance()
        if let balance = self.totalBalance, let amount = Formatter.formattedToDouble(valueString: self.sumTextField.text) , balance >= amount    {
            return true
        } else {
            return false
        }
    }
    
}
