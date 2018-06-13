import UIKit
import PromiseKit
import ObjectMapper

class DefaultPaymentService: NSObject, PaymentService {
    
    func getInVoices() -> Promise<String> {
        return Network.shared.get(path: PaymentConfig.shared.invoices , params: [:])
    }
    
}
