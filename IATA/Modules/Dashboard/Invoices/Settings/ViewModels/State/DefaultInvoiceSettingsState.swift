import Foundation
import UIKit

class DefaultInvoiceSettingsState: InvoiceSettingsState {
    
    var items: [InvoiceViewModelItem] = []
    
    func stateChanged(isSelected: Bool, item: Any) {
        self.check(isSelected: isSelected, item: item, index: 0)
        self.check(isSelected: isSelected, item: item, index: 1)
        self.check(isSelected: isSelected, item: item, index: 2)
        self.check(isSelected: isSelected, item: item, index: 3)
    }
    
    func clickDone() {
        for itemValues in items {
            if (itemValues is BaseInvoiceViewModelItem) {
                for item in (itemValues as! BaseInvoiceViewModelItem).items {
                    guard let type = item.type else {
                        return
                    }
                    
                    guard let typeInvoice = InvoiceViewModelItemType(rawValue: type) else {
                        return
                    }
                    FilterPreference.shared.setChecked(type: typeInvoice, isChecked: item.checked == nil ? false : item.checked!, id: (item.id)!)
                }
            } else if (itemValues is InvoicePaymentRangeItem) {
                let value = (itemValues as! InvoicePaymentRangeItem).paymentRange
                FilterPreference.shared.saveMaxValue(value.max)
                FilterPreference.shared.saveMinValue(value.min)
            }
        }
    }
    
    func getHeight(indexPath: IndexPath) -> CGFloat! {
        let item = items[indexPath.section]
        if (item.getType() ==  .paymentRange) {
            return 130
        } else {
            return 80
        }
    }
    
    func getItems() -> [InvoiceViewModelItem] {
        return self.items
    }
    
    func initItems(model: InvoiceScreenModel) {
        let airlines = model.airlines
        if !(model.airlines.isEmpty) {
            self.initCells(airlines, type: InvoiceViewModelItemType.airlines)
        }
        
        let billingCategories = model.billingCategories
        if !(model.billingCategories.isEmpty) {
             self.initCells(billingCategories, type: InvoiceViewModelItemType.billingCategories)
        }
        
        let currencies = model.currencies
        if !(model.currencies.isEmpty) {
             self.initCells(currencies, type: InvoiceViewModelItemType.currencies)
        }
        
        items.append(InvoicePaymentRangeItem(paymentRange: model.paymentRange))
        
        let settlementPeriod = model.settlementPeriod
        if !(model.settlementPeriod.isEmpty) {
             self.initCells(settlementPeriod, type: InvoiceViewModelItemType.settlementPeriod)
        }
    }
    
    private func initCells(_ items: [InvoiceSettingAirlinesModel], type: InvoiceViewModelItemType) {
        let items = BaseInvoiceViewModelItem(items: items)
        for item in items.items {
            item.checked = FilterPreference.shared.getChecked(id: item.id, type: type)
            item.type = type.rawValue
        }
        items.setType(type: type)
        self.items.append(items)
    }
    
    private func check(isSelected: Bool, item: Any, index: Int) {
        if let item = item as? InvoiceSettingAirlinesModel {
            let values = items[index]
            if (values is BaseInvoiceViewModelItem) {
                let items = (values as! BaseInvoiceViewModelItem).items
                if let index = items.index(where: {$0.name == item.name}) {
                    items[index].checked = isSelected
                }
            }
        }
    }
}
