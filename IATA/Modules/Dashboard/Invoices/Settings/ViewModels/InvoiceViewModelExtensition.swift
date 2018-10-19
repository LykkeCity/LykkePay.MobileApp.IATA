import Foundation
import UIKit

extension InvoiceViewModel: UITableViewDataSource, UITableViewDelegate, OnSwitchStateChangedDelegate {
    
    func updatePaymentRangeMin(min: Int?) {
        self.state.updatePaymentRangeMin(min: min)
    }
    
    func updatePaymentRangeMax(max: Int?) {
         self.state.updatePaymentRangeMax(max: max)
    }
    
    
    func stateChanged(isSelected: Bool, item: Any) {
        self.state.stateChanged(isSelected: isSelected, item: item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.state.getItems().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.state.getItems()[section].rowCount()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: InvoiceHeaderView.identifier) as! InvoiceHeaderView
        
        guard let type = self.state.getItems()[section].getType() else {
            return headerView
        }
        headerView.downDividerView.isHidden = false
        switch type {
        case .airlines:
            headerView.title.text = R.string.localizable.invoiceSettingsAirlinesTitle()
            break
        case .currencies:
            headerView.title.text = R.string.localizable.invoiceSettingsCurrenciesTitle()
            break
        case .paymentRange:
            headerView.downDividerView.isHidden = true
            headerView.title.text = R.string.localizable.invoiceSettingsPaymentRangeTitle()
            break
        case .billingCategories:
            headerView.title.text = R.string.localizable.invoiceSettingsBillingCategoriesTitle()
            break
        case .settlementPeriod:
            headerView.title.text = R.string.localizable.invoiceSettingsSettlementPeriodTitle()
            break
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.state.getHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.state.getItems()[indexPath.section]
        
        guard let type = item.getType() else {
            return UITableViewCell()
        }
        
        if (type == .paymentRange) {
            return self.initPaymentRangeCell(item, indexPath: indexPath, tableView)
        } else {
            return self.initStandardCell(item, indexPath: indexPath, tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.state.getItems()[section].getSectionTitle()
    }
    
    private func initStandardCell(_ item: InvoiceViewModelItem, indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? BaseInvoiceViewModelItem, let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceSettingsTableViewCell.identifier, for: indexPath) as? InvoiceSettingsTableViewCell {
            let items = item.items[indexPath.row]
            items.type = item.getType()?.rawValue
            cell.item = items
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
    
    private func initPaymentRangeCell(_ item: InvoiceViewModelItem, indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? InvoicePaymentRangeItem, let cell = tableView.dequeueReusableCell(withIdentifier: PaymentRangeTableViewCell.identifier, for: indexPath) as? PaymentRangeTableViewCell {
            let paymentRange = item.paymentRange
            cell.item = paymentRange
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
}
