import Foundation
import UIKit
import PromiseKit

class DefaultInvoiceSettingsState: InvoiceSettingsState {
    
    var items: [InvoiceViewModelItem] = []
    
    func getFilters() -> Promise<FiltersInvoiceList> {
        return Network.shared.get(path: PaymentConfig.shared.getFilters, params: [:])
    }
    
    func stateChanged(isSelected: Bool, item: Any) {
        self.check(isSelected: isSelected, item: item, index: 0)
        self.check(isSelected: isSelected, item: item, index: 1)
        self.check(isSelected: isSelected, item: item, index: 2)
        self.check(isSelected: isSelected, item: item, index: 3)
    }
    
    func updatePaymentRangeMin(min: Int?) {
        for item in items {
            if (item is InvoicePaymentRangeItem) {
                let value = (item as! InvoicePaymentRangeItem).paymentRange
                value.min = min
            }
        }
    }
    
    func updatePaymentRangeMax(max: Int?) {
        for item in items {
            if (item is InvoicePaymentRangeItem) {
                let value = (item as! InvoicePaymentRangeItem).paymentRange
                value.max = max
            }
        }
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
            return 150
        } else {
            return 60
        }
    }
    
    func getItems() -> [InvoiceViewModelItem] {
        return self.items
    }
    
    func initItems(model: FiltersInvoiceList) {
        
        if let airlines = model.groupMerchants, !(airlines.isEmpty) {
            self.initCells(airlines, type: InvoiceViewModelItemType.airlines)
        }
        
        if  let billingCategories = model.billingCategories , !(billingCategories.isEmpty) {
             self.initCells(billingCategories, type: InvoiceViewModelItemType.billingCategories)
        }
        
        if let currencies = model.settlementAssets, !(currencies.isEmpty) {
             self.initCells(currencies, type: InvoiceViewModelItemType.currencies)
        }
        
        var payment = InvoiceSettingPaymentRangeItemModel()
        payment?.min = FilterPreference.shared.getMinValue()
        payment?.max = FilterPreference.shared.getMaxValue()
        
        if let res = payment {
            items.append(InvoicePaymentRangeItem(paymentRange: res))
        }
        
    }
    
    private func initCells(_ items: [InvoiceFiltersModel], type: InvoiceViewModelItemType) {
        let items = BaseInvoiceViewModelItem(items: items)
        for item in items.items {
            item.checked = FilterPreference.shared.getChecked(id: item.id, type: type)
            item.type = type.rawValue
        }
        items.setType(type: type)
        self.items.append(items)
    }
    
    private func check(isSelected: Bool, item: Any, index: Int) {
        if let item = item as? InvoiceFiltersModel {
            let values = items[index]
            if (values is BaseInvoiceViewModelItem) {
                let items = (values as! BaseInvoiceViewModelItem).items
                if let index = items.index(where: {$0.id == item.id}) {
                    items[index].checked = isSelected
                }
            }
        }
    }
}
