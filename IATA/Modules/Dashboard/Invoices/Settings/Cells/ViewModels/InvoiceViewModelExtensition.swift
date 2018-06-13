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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.section]
        if (item.type ==  .paymentRange) {
            return 130
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .airlines:
            if let item = item as? InvoiceViewModelAirlinesItem, let cell = tableView.dequeueReusableCell(withIdentifier: AirlinesTableViewCell.identifier, for: indexPath) as? AirlinesTableViewCell {
                let airlines = item.airlines[indexPath.row]
                airlines.type = FilterTypeEnum.airlines.rawValue
                cell.item = airlines
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        case .currencies:
            if let item = item as? InvoiceCurrenciesViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
                let currencies = item.currencies[indexPath.row]
                currencies.type = FilterTypeEnum.currencies.rawValue
                cell.item = currencies
                cell.reloadValue()
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            break
        case .settlementPeriod:
            if let item = item as? InvoiceSettlementPeriodViewModeItem, let cell = tableView.dequeueReusableCell(withIdentifier: SimpleTableViewCell.identifier, for: indexPath) as? SimpleTableViewCell {
                let settlementPeriod = item.settlementPeriod[indexPath.row]
                settlementPeriod.type = FilterTypeEnum.settlementPeriod.rawValue
                cell.item = settlementPeriod
                cell.reloadValue()
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
                billingCategories.type = FilterTypeEnum.billingCategories.rawValue
                cell.item = billingCategories
                cell.reloadValue()
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
