import Foundation
import UIKit

class InvoiceRootViewModel: SwipeTableViewCellDelegate, OnChangeStateSelected {
    
    var viewController: InvoiceViewController?
    var state: DefaultInvoiceState?
    
    required init(state: DefaultInvoiceState?, viewController: InvoiceViewController?) {
        self.state = state
        self.viewController = viewController
    }
  
    func loadData() {
        self.state?.getInvoiceStringJson()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.viewController?.reloadTable(jsonString: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.viewController?.handleError(error: error)
                strongSelf.viewController?.endRefreshAnimation(wasEmpty: false, dataFetched: true)
                strongSelf.viewController?.tabView.reloadData()
            })
    }
    
    func getTitleView() -> UIView {
        guard let state = self.state, let index = self.state?.getIndex() else {
            return Theme.shared.getTitle(title: self.viewController?.getTitle(), color: UIColor.white)
        }
        self.state?.initSelected()
        let menuView = BTNavigationDropdownMenu(index: index, items: state.getMenuItems())
        menuView.backgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellBackgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellSeparatorColor = UIColor.clear
        menuView.menuTitleColor = UIColor.white
        menuView.cellSelectionColor = Theme.shared.tabBarBackgroundColor
        menuView.selectedCellTextLabelColor = Theme.shared.tabBarItemSelectedColor
        menuView.didSelectItemAtIndexHandler = {[weak self] (menu: Menu) -> () in
            FilterPreference.shared.saveIndexOfStatus(menu.type)
            self?.state?.selectedStatus(type: menu.type)
            self?.viewController?.hideMenu()
            menuView.title = menu.title
            self?.viewController?.beginRefreshing()
            self?.loadData()
        }
        return menuView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as! InvoiceTableViewCell
        cell.checkBox.tag = indexPath.row
        cell.delegateChanged = self
        cell.delegate = self
        guard let dict = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        guard let isChecked = self.state?.isChecked(model: dict) else {
            return UITableViewCell()
        }
        
        cell.initModel(model: dict, isChecked: isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        guard let state = self.state else {
            return nil
        }
        
        let stateCanBeOpenDispute = state.isCanBeOpenDispute(index: indexPath.row)
        let stateCanBeClosedDispute = state.isCanBeClosedDispute(index: indexPath.row)
        
        if (stateCanBeOpenDispute) {
            return openDisputeAction(state)
            
        } else if (stateCanBeClosedDispute) {
            return cancelDisputeAction(state)
            
        }
        return nil
    }
    
    func onItemSelected(isSelected: Bool, index: Int) {
        self.state?.newItem(isSelected: isSelected, index: index)
        self.viewController?.onItemSelected(isSelected: isSelected, index: index)
    }
    
    
    private func openDisputeAction(_ state: DefaultInvoiceState) -> [SwipeAction]? {
        let disputeAction = SwipeAction(style: .destructive, title: R.string.localizable.invoiceScreenItemsDispute()) { action, indexPath in
            let disputInvoiceVC = DisputInvoiceViewController()
            disputInvoiceVC.rootController = self.viewController
            disputInvoiceVC.completion = {
                self.viewController?.loadData()
            }
            disputInvoiceVC.invoiceId = state.getItems()[indexPath.row].id
            self.viewController?.present(disputInvoiceVC, animated: true, completion: nil)
        }
        return getTableAction(Theme.shared.pinkDisputeColor,  disputeAction, 80)
    }
    
    private func cancelDisputeAction(_ state: DefaultInvoiceState) -> [SwipeAction]? {
        let disputeAction = SwipeAction(style: .destructive, title: R.string.localizable.invoiceScreenItemsCancelDispute()) { action, indexPath in
            let model = CancelDisputInvoiceRequest()
            model?.invoiceId = state.getItems()[indexPath.row].id
            if let model = model {
                self.viewController?.refreshControl.beginRefreshing()
                self.state?.cancelDisputInvoice(model: model)
                    .then(execute: { [weak self] (result: Void) -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.viewController?.loadData()
                    })
            }
        }
        
        return getTableAction(Theme.shared.grayDisputeColor, disputeAction, 140)
    }
    
    private func getTableAction(_ backgroundColor: UIColor, _ action: SwipeAction,_ width: Int) -> [SwipeAction]? {
        if !UserPreference.shared.isSuperviser() {
            action.width = width
            action.image = UIView.from(color: backgroundColor)
            action.backgroundColor = UIColor.white
            action.font = Theme.shared.boldFontOfSize(14)
            
            return [action]
        } else {
            return nil
        }
    }

}

