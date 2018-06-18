import UIKit
import PromiseKit
import ObjectMapper

class DefaultPaymentService: NSObject, PaymentService {
   
    func makePayment(model: PaymentRequest) -> Promise<Void> {
         return Network.shared.post(path: PaymentConfig.shared.makePayment, object: model)
    }
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String> {
        var params: [String : Any] = [String : Any]()
        
        if (invoceParams.dispute != nil) {
            params[InvoiceRequest.InvoiceParamsKey.dispute.rawValue] = invoceParams.dispute! ? "true" : "false"
        }
        if (!invoceParams.statuses.elementsEqual(InvoiceStatuses.all.rawValue)) {
            params[InvoiceRequest.InvoiceParamsKey.statuses.rawValue] = invoceParams.statuses
        }
        
        params[InvoiceRequest.InvoiceParamsKey.lessThan.rawValue] = String(invoceParams.lessThan!)
        params[InvoiceRequest.InvoiceParamsKey.greaterThan.rawValue] = String(invoceParams.greaterThan!)
        
        params[InvoiceRequest.InvoiceParamsKey.clientMerchantIds.rawValue] = invoceParams.clientMerchantIds
        params[InvoiceRequest.InvoiceParamsKey.billingCategories.rawValue] = invoceParams.billingCategories
        params[InvoiceRequest.InvoiceParamsKey.settlementAssets.rawValue] = invoceParams.settlementAssets
        
        return Network.shared.get(path: PaymentConfig.shared.invoices, params: params)
    }
    
    func getAmount(invoicesIds: [String]) -> Promise<PaymentAmount> {
        var params: [String : Any] = [String : Any]()
        params[InvoiceRequest.InvoiceParamsKey.invoicesIds.rawValue] = invoicesIds
        return Network.shared.getWithBrasket(path: PaymentConfig.shared.amount, params: params)
    }
}
