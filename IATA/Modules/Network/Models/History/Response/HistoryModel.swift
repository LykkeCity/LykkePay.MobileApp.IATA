import Foundation
import UIKit
import ObjectMapper

class HistoryModel: Mappable {
    
    private enum PropertyKey: String {
        case id
        case merchantLogoUrl
        case title
        case createdOn
        case amount
        case assetId
        case iataInvoiceDate
        case settlementMonthPeriod
        case symbol
    }
    
    internal var createdOn: String?
    internal var id: String?
    internal var logo: String?
    internal var title: String?
    internal var timeStamp: String?
    internal var amount:  Double?
    internal var assetId: String?
    internal var symbol: String?
    internal var iataInvoiceDate: String?
    internal var settlementMonthPeriod: String?
    
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        self.id <- map[PropertyKey.id.rawValue]
        self.logo <- map[PropertyKey.merchantLogoUrl.rawValue]
        self.title <- map[PropertyKey.title.rawValue]
        self.timeStamp <- map[PropertyKey.createdOn.rawValue]
        self.amount <- map[PropertyKey.amount.rawValue]
        self.assetId <- map[PropertyKey.assetId.rawValue]
        self.iataInvoiceDate <- map[PropertyKey.iataInvoiceDate.rawValue]
        self.settlementMonthPeriod <- map[PropertyKey.settlementMonthPeriod.rawValue]
        self.createdOn <- map[PropertyKey.createdOn.rawValue]
        
        if let create = self.createdOn {
            self.createdOn = DateUtils.formatDateFromFormatWith7Mls(dateString: create)
        }
        
        if let iataInvoiceDate = self.iataInvoiceDate {
            self.iataInvoiceDate = DateUtils.formatDateFromFormat(dateString: iataInvoiceDate)
        }
        if let timeStamp = self.timeStamp {
            self.timeStamp = DateUtils.formatDateFromFormatWith7Mls(dateString: timeStamp)
        }
        
        if let asset = assetId {
            if (asset.isUsd()) {
                self.symbol = "$"
            } else {
                self.symbol = "€"
            }
        }
    }
}

