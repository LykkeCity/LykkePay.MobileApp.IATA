import Foundation

class InvoiceRequest {
    
    public enum InvoiceParamsKey: String {
        case clientMerchantIds
        case statuses
        case dispute
        case billingCategories
        case settlementAssets
        case greaterThan
        case lessThan
    }
    
    var clientMerchantIds: [String] = []
    var billingCategories: [String] = []
    var dispute: Bool?
    var greaterThan: Int?
    var lessThan: Int?
    var statuses: String = InvoiceStatuses.all.rawValue
    
    internal required init?() {
    }
    
}
