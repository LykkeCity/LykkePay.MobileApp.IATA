import Foundation
import UIKit

extension InvoiceViewModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "InvoiceHeaderView") as! InvoiceHeaderView
        
        headerView.title.text = items[section].sectionTitle
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.section]
        if (item.type ==  .paymentRange) {
             return 150
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .airlines:
            if let item = item as? InvoiceViewModelAirlinesItem, let cell = tableView.dequeueReusableCell(withIdentifier: AirlinesTableViewCell.identifier, for: indexPath) as? AirlinesTableViewCell {
                let airlines = item.airlines[indexPath.row]
                cell.item = airlines
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        case .currencies:
            if let item = item as? InvoiceCurrenciesViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
                let settlementPeriod = item.currencies[indexPath.row]
                cell.item = settlementPeriod
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            break
        case .settlementPeriod:
            if let item = item as? InvoiceSettlementPeriodViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
                let settlementPeriod = item.settlementPeriod[indexPath.row]
                cell.item = settlementPeriod
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            break
        case .paymentRange:
            if let item = item as? InvoicePaymentRangeItem, let cell = tableView.dequeueReusableCell(withIdentifier: PaymentRangeTableViewCell.identifier, for: indexPath) as? PaymentRangeTableViewCell {
                let paymentRange = item.paymentRange
                cell.item = paymentRange
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            break
        case .billingCategories:
            if let item = item as? InvoiceBillingCategoriesItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
                let billingCategories = item.billingCategories[indexPath.row]
                cell.item = billingCategories
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
}
