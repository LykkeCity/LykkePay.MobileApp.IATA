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
    
    func initModel(modelInvoice: InvoiceModel) -> HistoryTransactionModel {
        let model = HistoryTransactionModel()
        model.merchantLogoUrl = self.invoiceModel?.logoUrl
        model.merchantName = self.invoiceModel?.merchantName
        if let name = self.invoiceModel?.paymentAssetId {
            model.title = R.string.localizable.historyTitleTransaction(name)
            if let amount = invoiceModel?.amount {
                model.amount = Formatter.formattedWithSeparator(valueDouble: amount) + " " + name
            }
        }
        
        if let number = self.invoiceModel?.number {
            model.invoiceNumber = "#" + number
        }
        model.billingCategory = self.invoiceModel?.billingCategory
        model.invoiceStatus = InvoiceStatuses.Paid
        model.status = InvoiceStatusesStruct(type: InvoiceStatuses.Paid).title.capitalizingFirstLetter()
        model.assetId = self.invoiceModel?.settlementAssetId
    }
    
}
