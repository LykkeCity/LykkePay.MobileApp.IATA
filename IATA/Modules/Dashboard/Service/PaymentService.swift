import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>
    func getAmount(invoicesIds: [String]) -> Promise<PaymentAmount> 
    func makePayment(model: PaymentRequest) -> Promise<Void>
}
