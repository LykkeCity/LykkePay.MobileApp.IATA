import Foundation
import UIKit
import ObjectMapper

class FiltersInvoiceList: Mappable {
    
    private enum PropertyKey: String {
        case groupMerchants
        case billingCategories
        case settlementAssets
        case maxRangeInBaseAsset
    }
    
    internal var groupMerchants: [InvoiceFiltersModel]?
    internal var billingCategories: [InvoiceFiltersModel]?
    internal var settlementAssets: [InvoiceFiltersModel]?
    internal var maxRangeInBaseAsset: Double?
    
    internal required init?(map: Map) {
    }
    
    internal required init?() {
    }
    
    internal func mapping(map: Map) {
        self.groupMerchants <- map[PropertyKey.groupMerchants.rawValue]
        self.billingCategories <- map[PropertyKey.billingCategories.rawValue]
        self.settlementAssets <- map[PropertyKey.settlementAssets.rawValue]
        self.maxRangeInBaseAsset <- map[PropertyKey.maxRangeInBaseAsset.rawValue]
    }
}
