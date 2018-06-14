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
        
        for clientMerchantId in invoceParams.clientMerchantIds {
            params[InvoiceRequest.InvoiceParamsKey.clientMerchantIds.rawValue] = String(clientMerchantId)
        }
        
        for billingCategory in invoceParams.billingCategories {
            params[InvoiceRequest.InvoiceParamsKey.billingCategories.rawValue] = String(billingCategory)
        }
      
        return Network.shared.get(path: PaymentConfig.shared.invoices , params: params)
    }

    func getWallets(convertAssetIdParams: String) -> Promise<String> {
        var params = [String : String]()
        params["convertAssetIdParams"] = convertAssetIdParams
        return Network.shared.get(path: PaymentConfig.shared.wallets, params: params)
    }
    
}
