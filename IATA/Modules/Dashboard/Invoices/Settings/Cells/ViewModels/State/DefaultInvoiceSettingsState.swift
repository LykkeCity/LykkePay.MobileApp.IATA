import Foundation
import UIKit

class DefaultInvoiceSettingsState: InvoiceSettingsState {
    
    var items = [InvoiceViewModelItem]()
    
    func stateChanged(isSelected: Bool, item: Any) {
        if let item = item as? InvoiceSettingAirlinesModel {
            let values = (items[0] as! InvoiceViewModelAirlinesItem).airlines
            if let index = values.index(where: {$0.name == item.name}) {
                values[index].checked = isSelected
            }
        }
        if let item = item as? InvoiceSettingModel {
            if (item.type?.isEqual(InvoiceViewModelItemType.billingCategories))!{
                let values = (items[1] as! InvoiceBillingCategoriesItem).billingCategories
                if let index = values.index(where: {$0.name == item.name}) {
                    values[index].checked = isSelected
                }
            } else if (item.type?.isEqual(InvoiceViewModelItemType.currencies))! {
                let values = (items[2] as! InvoiceCurrenciesViewModeItem).currencies
                if let index = values.index(where: {$0.name == item.name}) {
                    values[index].checked = isSelected
                }
            } else if (item.type?.isEqual(InvoiceViewModelItemType.currencies))! {
                let values = (items[3] as! InvoiceSettlementPeriodViewModeItem).settlementPeriod
                if let index = values.index(where: {$0.name == item.name}) {
                    values[index].checked = isSelected
                }
            }
        }
    }
    
    func clickDone() {
        for item in items {
            if (item is InvoiceViewModelAirlinesItem) {
                for value in (item as! InvoiceViewModelAirlinesItem).airlines {
                     FilterPreference.shared.setChecked(type:  InvoiceViewModelItemType.airlines, isChecked: value.checked == nil ? false : value.checked!, name: (value.name)!)
                }
            } else if (item is InvoiceSettlementPeriodViewModeItem) {
                for value in (item as! InvoiceSettlementPeriodViewModeItem).settlementPeriod {
                    FilterPreference.shared.setChecked(type:  InvoiceViewModelItemType.settlementPeriod, isChecked: value.checked == nil ? false : value.checked!, name: (value.name)!)
                }
            } else if (item is InvoiceBillingCategoriesItem) {
                for value in (item as! InvoiceBillingCategoriesItem).billingCategories {
                    FilterPreference.shared.setChecked(type:  InvoiceViewModelItemType.billingCategories, isChecked: value.checked == nil ? false : value.checked!, name: (value.name)!)
                }
            } else if (item is InvoiceCurrenciesViewModeItem) {
                for value in (item as! InvoiceCurrenciesViewModeItem).currencies {
                    FilterPreference.shared.setChecked(type:  InvoiceViewModelItemType.currencies, isChecked: value.checked == nil ? false : value.checked!, name: (value.name)!)
                }
            } else if (item is InvoicePaymentRangeItem) {
                let value = (item as! InvoicePaymentRangeItem).paymentRange
                FilterPreference.shared.saveMaxValue(value.max)
                FilterPreference.shared.saveMinValue(value.min)
            }
        }
    }
    
    func getHeight(indexPath: IndexPath) -> CGFloat! {
        let item = items[indexPath.section]
        if (item.type ==  .paymentRange) {
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
            self.initAirlines(airlines)
        }
        
        let billingCategories = model.billingCategories
        if !(model.billingCategories.isEmpty) {
            self.initBillings(billingCategories)
        }
        
        let currencies = model.currencies
        if !(model.currencies.isEmpty) {
            self.initCurrencies(currencies)
        }
        
        items.append(InvoicePaymentRangeItem(paymentRange: model.paymentRange))
        
        let settlementPeriod = model.settlementPeriod
        if !(model.settlementPeriod.isEmpty) {
            self.initSettlementPeriod(settlementPeriod)
        }
    }
    
    private func initBillings(_ billingCategories: [InvoiceSettingModel]) {
        let billingCategoriesItems = InvoiceBillingCategoriesItem(billingCategories: billingCategories)
        for billingCategory in billingCategoriesItems.billingCategories {
            billingCategory.checked = FilterPreference.shared.getChecked(name: billingCategory.name, type: InvoiceViewModelItemType.billingCategories)
        }
        self.items.append(billingCategoriesItems)
    }
    
    private func initCurrencies(_ currencies: [InvoiceSettingModel]) {
        let currenciesItems = InvoiceCurrenciesViewModeItem(currencies: currencies)
        for currency in currenciesItems.currencies {
            currency.checked = FilterPreference.shared.getChecked(name: currency.name, type: InvoiceViewModelItemType.currencies)
        }
        self.items.append(currenciesItems)
    }
    
    private func initAirlines(_ airlines: [InvoiceSettingAirlinesModel]) {
        let airlinesItems = InvoiceViewModelAirlinesItem(airlines: airlines)
        for airline in airlinesItems.airlines {
            airline.checked = FilterPreference.shared.getChecked(name: airline.id, type: InvoiceViewModelItemType.airlines)
        }
        self.items.append(airlinesItems)
    }
    
    private func initSettlementPeriod(_ settlementPeriod: [InvoiceSettingModel]) {
        let settlementPeriod = InvoiceSettlementPeriodViewModeItem(settlementPeriod: settlementPeriod)
        for period in settlementPeriod.settlementPeriod {
            period.checked = FilterPreference.shared.getChecked(name: period.name, type: InvoiceViewModelItemType.settlementPeriod)
        }
        self.items.append(settlementPeriod)
    }
}
