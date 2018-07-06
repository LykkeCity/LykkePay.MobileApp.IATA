import Foundation
import PromiseKit
import ObjectMapper

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>
    func getAmount(invoicesIds: [String]) -> Promise<PaymentAmount> 
    func makePayment(model: PaymentRequest) -> Promise<BaseMappable>

    func getWallets(convertAssetIdParams: String)-> Promise<String>
    
    func getHistory() -> Promise<String>

    func makeDisputInvoice(model: DisputInvoiceRequest) -> Promise<Void>

    func cancelDisputInvoice(model: CancelDisputInvoiceRequest) -> Promise<Void>

    func getDisputeList() -> Promise<String>

    func getHistoryDetails(id: String) -> Promise<HistoryTransactionModel>
    
    func getSettings() -> Promise<SettingsModel>
    func getBaseAssetsList() -> Promise<String>
    func postBaseAssets(baseAsset: String) -> Promise<Void>

    func makeExchange(model: ExchangeRequest) -> Promise<ExchangeModel>
    func loadExchangeInfo(model: PreExchangeRequest) -> Promise<ExchangeModel>
    
    func getDictionaryForPayments() -> Promise<String>
    func cashOut(model: CashOutRequest)  -> Promise<BaseMappable>
}
