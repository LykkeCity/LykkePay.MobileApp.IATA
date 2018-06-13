import Foundation
import UIKit

extension InvoiceViewModel: UITableViewDataSource, UITableViewDelegate, OnSwitchStateChangedDelegate {
    
    func stateChanged(isSelected: Bool, item: Any) {
        self.state.stateChanged(isSelected: isSelected, item: item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.state.getItems().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.state.getItems()[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: InvoiceHeaderView.identifier) as! InvoiceHeaderView
        
        headerView.title.text = self.state.getItems()[section].sectionTitle
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.state.getHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.state.getItems()[indexPath.section]
        switch item.type {
        case .airlines:
            return self.initAirlineCell(item, indexPath: indexPath, tableView)
        case .currencies:
            return self.initCurrencyCell(item, indexPath: indexPath, tableView)
        case .settlementPeriod:
            return self.initSettlementCell(item, indexPath: indexPath, tableView)
        case .paymentRange:
            return self.initPaymentRangeCell(item, indexPath: indexPath, tableView)
        case .billingCategories:
            return self.initBillingCell(item, indexPath: indexPath, tableView)
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.state.getItems()[section].sectionTitle
    }
    
    private func initAirlineCell(_ item: InvoiceViewModelItem, indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? InvoiceViewModelAirlinesItem, let cell = tableView.dequeueReusableCell(withIdentifier: AirlinesTableViewCell.identifier, for: indexPath) as? AirlinesTableViewCell {
            let airlines = item.airlines[indexPath.row]
            airlines.type = InvoiceViewModelItemType.airlines.rawValue
            cell.item = airlines
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
    
    
    private func initBillingCell(_ item: InvoiceViewModelItem,indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? InvoiceBillingCategoriesItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
            let billingCategories = item.billingCategories[indexPath.row]
            billingCategories.type = InvoiceViewModelItemType.billingCategories.rawValue
            cell.item = billingCategories
            cell.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
    
    private func initCurrencyCell(_ item: InvoiceViewModelItem, indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? InvoiceCurrenciesViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
            cell.delegate = self
            let currencies = item.currencies[indexPath.row]
            currencies.type = InvoiceViewModelItemType.currencies.rawValue
            cell.item = currencies
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
    
    private func initSettlementCell(_ item: InvoiceViewModelItem, indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let item = item as? InvoiceSettlementPeriodViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
            let settlementPeriod = item.settlementPeriod[indexPath.row]
            settlementPeriod.type = InvoiceViewModelItemType.settlementPeriod.rawValue
            cell.item = settlementPeriod
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
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()
    }
}
