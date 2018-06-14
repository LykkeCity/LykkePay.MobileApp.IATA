import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String>

    func getWallets(convertAssetIdParams: String)-> Promise<String>
}
