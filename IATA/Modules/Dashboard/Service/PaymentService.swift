import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>
    func getAmount(invoicesIds: [String]) -> Promise<PaymentAmount> 
    func makePayment(model: PaymentRequest) -> Promise<Void>

    func getWallets(convertAssetIdParams: String)-> Promise<String>
    func getHistory() -> Promise<String>

    func makeDisputInvoice(model: DisputInvoiceRequest) -> Promise<Void>

    func cancelDisputInvoice(model: CancelDisputInvoiceRequest) -> Promise<Void>

    func getDisputeList() -> Promise<String>
}
