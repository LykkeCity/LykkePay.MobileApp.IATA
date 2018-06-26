import Foundation
import PromiseKit

class DefaultDisputInvoiceState: DefaultBaseState<DisputInvoiceRequest> {

    public lazy var service: PaymentService = DefaultPaymentService()

    func makeDisputInvoice(model: DisputInvoiceRequest) -> Promise<Void> {
            return self.service.makeDisputInvoice(model: model)
    }
}


