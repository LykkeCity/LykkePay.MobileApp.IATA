import Foundation
import PromiseKit

protocol PaymentService {
    
    func getInVoices() -> Promise<String>
}
