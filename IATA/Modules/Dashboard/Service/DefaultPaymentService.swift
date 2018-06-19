import UIKit
import PromiseKit
import ObjectMapper

class DefaultPaymentService: NSObject, PaymentService {
    
    
    func getInVoices(invoceParams: InvoiceRequest)-> Promise<String> {
        var params = [String : String]()
       
        if (invoceParams.dispute != nil) {
            params[InvoiceRequest.InvoiceParamsKey.dispute.rawValue] = invoceParams.dispute! ? "true" : "false"
        }
        if (!invoceParams.statuses.elementsEqual(InvoiceStatuses.all.rawValue)) {
            params[InvoiceRequest.InvoiceParamsKey.statuses.rawValue] = invoceParams.statuses
        }
        
        params[InvoiceRequest.InvoiceParamsKey.lessThan.rawValue] = String(invoceParams.lessThan!)
        params[InvoiceRequest.InvoiceParamsKey.greaterThan.rawValue] = String(invoceParams.greaterThan!)
        
        if let values = invoceParams.clientMerchantIds {
            for clientMerchantId in values {
                params[InvoiceRequest.InvoiceParamsKey.clientMerchantIds.rawValue] = String(clientMerchantId)
            }
        }
        
        if let values = invoceParams.billingCategories {
            for billingCategory in values {
                params[InvoiceRequest.InvoiceParamsKey.billingCategories.rawValue] = String(billingCategory)
            }
        }
        
        if let values = invoceParams.settlementAssets {
            for settlementAssets in values {
                params[InvoiceRequest.InvoiceParamsKey.settlementAssets.rawValue] = String(settlementAssets)
            }
        }
      
        return Network.shared.get(path: PaymentConfig.shared.invoices , params: params)
    }
    
    func getHistory() -> Promise<String> {
        return Network.shared.get(path: PaymentConfig.shared.historyIndex , params: [:])
    }
    
}
