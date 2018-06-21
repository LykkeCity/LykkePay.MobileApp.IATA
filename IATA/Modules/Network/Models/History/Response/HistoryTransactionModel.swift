import Foundation
import UIKit
import ObjectMapper
import Rswift

class HistoryTransactionModel: Mappable, Reflectable {
    
    public enum PropertyKey: String {
        case id
        case merchantLogoUrl
        case title
        case timeStamp
        case amount
        case assetId
        case soldBy
        case blockHeight
        case blockConfirmations
        case txHash
        case invoiceNumber
        case billingCategory
    }
    
    internal var id: String?
    internal var merchantLogoUrl: String?
    internal var title: String?
    internal var timeStamp: String?
    internal var amount: String?
    internal var assetId: String?
    internal var soldBy: String?
    internal var blockHeight: String?
    internal var blockConfirmations: String?
    internal var txHash: String?
    internal var invoiceNumber: String?
    internal var billingCategory: String?

    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        self.id <- map[PropertyKey.id.rawValue]
        self.merchantLogoUrl <- map[PropertyKey.merchantLogoUrl.rawValue]
        self.title <- map[PropertyKey.title.rawValue]
        self.timeStamp <- map[PropertyKey.timeStamp.rawValue]
        self.amount <- map[PropertyKey.amount.rawValue]
        self.assetId <- map[PropertyKey.assetId.rawValue]
        self.soldBy <- map[PropertyKey.soldBy.rawValue]
        self.blockHeight <- map[PropertyKey.blockHeight.rawValue]
        self.blockConfirmations <- map[PropertyKey.blockConfirmations.rawValue]
        self.txHash <- map[PropertyKey.txHash.rawValue]
        self.invoiceNumber <- map[PropertyKey.invoiceNumber.rawValue]
        self.billingCategory <- map[PropertyKey.billingCategory.rawValue]
    }
    
    func valueFor() -> [PropertyKeyTransactionModel] {
        var items = [PropertyKeyTransactionModel]()
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            if let name = name, let structInfo = PropertyKeyTransactionModel(keyValue: name, value: value as? String), structInfo.title != nil {
                guard let value = value as? String, !value.isEmpty else {
                    continue
                }
                structInfo.title = localizedTitles[name]
                items.append(structInfo)
            }
        }
        return items
    }

    let localizedTitles = [PropertyKey.timeStamp.rawValue : R.string.localizable.historyTransactionDetailsTimeStamp(),
                           PropertyKey.amount.rawValue : R.string.localizable.historyTransactionDetailsAmount(),
                           PropertyKey.soldBy.rawValue : R.string.localizable.historyTransactionDetailsSoldBy(),
                           PropertyKey.blockHeight.rawValue : R.string.localizable.historyTransactionDetailsBlockHeight(),
                           PropertyKey.txHash.rawValue : R.string.localizable.historyTransactionDetailsTxHash(),
                           PropertyKey.invoiceNumber.rawValue : R.string.localizable.historyTransactionDetailsInvoiceNumber(),
                           PropertyKey.billingCategory.rawValue : R.string.localizable.historyTransactionDetailsBillingCategory()]
}

protocol Reflectable {
    func properties() -> [String]
}

extension Reflectable {
    func properties() -> [String]{
        var s = [String]()
        for c in Mirror(reflecting: self).children {
            if let name = c.label {
                s.append(name)
            }
        }
        return s
    }
}
