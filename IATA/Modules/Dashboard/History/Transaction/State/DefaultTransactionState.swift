import Foundation
import PromiseKit
import ObjectMapper

class DefaultTransactionState: DefaultBaseState<PropertyKeyTransactionModel> {
    
    public lazy var service: PaymentService = DefaultPaymentService()
    
    
    func getHistoryDetails(id: String) -> Promise<HistoryTransactionModel> {
        return self.service.getHistoryDetails(id: id)
    }

    func getPayedHistoryDetails(invoiceId: String) -> Promise<HistoryTransactionModel> {
        return self.service.getPayedHistoryDetails(invoiceId: invoiceId)
    }
    
    func initItems(item: HistoryTransactionModel) {
        self.items = item.valueFor()
    }
    
    func initModel(invoiceModel: InvoiceModel) -> HistoryTransactionModel {
        let model = HistoryTransactionModel()
        model.merchantLogoUrl = invoiceModel.logoUrl
        model.merchantName = invoiceModel.merchantName
        if let name = invoiceModel.paymentAssetId {
            model.title = R.string.localizable.historyTitleTransaction(name)
            if let amount = invoiceModel.amount {
                model.amount = Formatter.formattedWithSeparator(valueDouble: amount) + " " + name
            }
        }
        
        if let number = invoiceModel.number {
            model.invoiceNumber = "#" + number
        }
        model.billingCategory = invoiceModel.billingCategory
        model.invoiceStatus = InvoiceStatuses.Paid
        model.status = InvoiceStatusesStruct(type: InvoiceStatuses.Paid).title.capitalizingFirstLetter()
        model.assetId = invoiceModel.settlementAssetId
        return model
    }
    
}
