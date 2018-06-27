import Foundation
import UIKit
import ObjectMapper

extension InvoiceViewController {
    
    func hideMenu() {
        self.view.endEditing(true)
        self.tabView.reloadData()
        self.animate(isShow: false)
        if (self.navigationItem.titleView is BTNavigationDropdownMenu) {
            let menu = self.navigationItem.titleView as! BTNavigationDropdownMenu
            menu.hideMenu()
            if let items = self.state?.getMenuItems() {
                menu.updateItems(items)
            }
        }
    }
    
    // MARK: payments process
    func makePayment(alert: UIAlertAction!) {
        self.view.endEditing(true)
        let viewController = PinViewController()
        viewController.isValidationTransaction = true
        let items = self.state?.getItemsId()
        viewController.completion = {
            self.tabView.setContentOffset(.zero, animated: true)
            self.refresh()
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
        
    }
    
    func paymentSuccess() {
        ViewUtils.shared.showToast(message: R.string.localizable.commonSuccessMessage(), view: self.view)
        self.loadData()
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
            self.state?.amount = Double(amountValue)
            self.sumTextField.text = Formatter.formattedWithSeparator(value: String(amountValue), canBeZero: true)
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
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.animate(isShow: false)
        self.tabView.reloadData()
    }
    
}
