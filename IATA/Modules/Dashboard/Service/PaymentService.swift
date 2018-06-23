import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>
    func getAmount(invoicesIds: [String]) -> Promise<PaymentAmount> 
    func makePayment(model: PaymentRequest) -> Promise<Void>

    func getWallets(convertAssetIdParams: String)-> Promise<String>
    
    func getHistory() -> Promise<String>

    func getHistoryDetails(id: String) -> Promise<HistoryTransactionModel>
    
    func getSettings() -> Promise<String>
    func getBaseAssetsList() -> Promise<String>
    func postBaseAssets(baseAsset: String) -> Promise<Void>

}
