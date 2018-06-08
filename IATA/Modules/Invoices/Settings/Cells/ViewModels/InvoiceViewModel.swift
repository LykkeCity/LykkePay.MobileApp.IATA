import Foundation
import UIKit

protocol InvoiceViewModelItem {
    var type: InvoiceViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

class InvoiceViewModel: NSObject {
    var items = [InvoiceViewModelItem]()
    
    override init() {
        super.init()
        guard let data = dataFromFile("ServerData"), let model = InvoiceScreenModel(data: data) else {
            return
        }
        
        let airlines = model.airlines
        if !(model.airlines.isEmpty) {
            let airlinesItems = InvoiceViewModelAirlinesItem(airlines: airlines)
            items.append(airlinesItems)
        }
        
        let billingCategories = model.billingCategories
        if !(model.billingCategories.isEmpty) {
            let billingCategoriesItems = InvoiceBillingCategoriesItem(billingCategories: billingCategories)
            items.append(billingCategoriesItems)
        }
        
        let currencies = model.currencies
        if !(model.currencies.isEmpty) {
            let currenciesItems = InvoiceCurrenciesViewModeItem(currencies: currencies)
            items.append(currenciesItems)
        }
        
        items.append(InvoicePaymentRangeItem(paymentRange: model.paymentRange))
        
        let settlementPeriod = model.settlementPeriod
        if !(model.settlementPeriod.isEmpty) {
            let settlementPeriod = InvoiceSettlementPeriodViewModeItem(settlementPeriod: settlementPeriod)
            items.append(settlementPeriod)
        }
    }
}
