import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>
    func getHistory() -> Promise<String>
}
