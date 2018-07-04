import Foundation
import UIKit
import ObjectMapper
import Rswift

class HistoryTransactionModel: Mappable, Reflectable {

    private let localizedTitles = [PropertyKey.timeStamp.rawValue : R.string.localizable.historyTransactionDetailsTimeStamp(),
                                   PropertyKey.amount.rawValue : R.string.localizable.historyTransactionDetailsAmount(),
                                   PropertyKey.paidBy.rawValue : R.string.localizable.historyTransactionDetailsPaidBy(),
                                   PropertyKey.soldBy.rawValue : R.string.localizable.historyTransactionDetailsSoldBy(),
                                   PropertyKey.blockConfirmations.rawValue : R.string.localizable.historyTransactionDetailsBlockHeight(),
                                   PropertyKey.txHash.rawValue : R.string.localizable.historyTransactionDetailsTxHash(),
                                   PropertyKey.invoiceNumber.rawValue : R.string.localizable.historyTransactionDetailsInvoiceNumber(),
                                   PropertyKey.billingCategory.rawValue : R.string.localizable.historyTransactionDetailsBillingCategory(),
                                   PropertyKey.employeeEmail.rawValue : R.string.localizable.historyTransactionDetailsPaidBy(),
                                   PropertyKey.invoiceStatus.rawValue : R.string.localizable.historyTransactionDetailsStatus(),
                                   PropertyKey.requestedBy.rawValue : R.string.localizable.historyTransactionDetailsRequestedBy()]

    public enum PropertyKey: String {
        case id
        case merchantLogoUrl
        case merchantName
        case title
        case requestedBy
        case invoiceNumber
        case billingCategory
        case employeeEmail
        case iataInvoiceDate
        case soldBy
        case blockHeight
        case amount
        case assetId
        case txHash
        case createdOn
        case blockConfirmations
        case invoiceStatus
        case paidBy
        case timeStamp
        case assetName
    }


    /**
     - Important:
        Order of this properties is equal to order of cells in Transaction History screen. See Reflectable protocol extension to understand it.
     */
    internal var id: String?
    internal var merchantLogoUrl: String?
    internal var merchantName: String?
    internal var title: String?
    internal var requestedBy: String?
    internal var invoiceNumber: String?
    internal var billingCategory: String?
    internal var invoiceStatus: String?
    internal var employeeEmail: String?
    internal var timeStamp: String?
    internal var assetId: String?
    internal var soldBy: String?
    internal var paidBy: String?
    internal var blockHeight: Int?
    internal var blockConfirmations: String?
    internal var txHash: String?
    internal var amount: String?
    internal var assetName: String?

    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        self.id <- map[PropertyKey.id.rawValue]
        self.assetName <- map[PropertyKey.assetName.rawValue]
        self.invoiceStatus <- map[PropertyKey.invoiceStatus.rawValue]
        self.merchantLogoUrl <- map[PropertyKey.merchantLogoUrl.rawValue]
        self.requestedBy <- map[PropertyKey.requestedBy.rawValue]
        self.title <- map[PropertyKey.title.rawValue]
        self.timeStamp <- map[PropertyKey.createdOn.rawValue]
        self.timeStamp = DateUtils.formatDateFromFormatWithUTC(dateString: self.timeStamp ?? "")
        var amountDouble: Double?
        amountDouble <- map[PropertyKey.amount.rawValue]
        self.assetId <- map[PropertyKey.assetId.rawValue]
        self.amount = Formatter.formattedWithSeparator(valueDouble: amountDouble) + " " + (self.assetId ?? "")
        self.soldBy <- map[PropertyKey.soldBy.rawValue]
        self.paidBy <- map[PropertyKey.paidBy.rawValue]
        self.blockHeight <- map[PropertyKey.blockConfirmations.rawValue]
        self.blockConfirmations = String(self.blockHeight ?? 0)
        self.txHash <- map[PropertyKey.txHash.rawValue]
        self.invoiceNumber <- map[PropertyKey.invoiceNumber.rawValue]
        self.billingCategory <- map[PropertyKey.billingCategory.rawValue]
        self.employeeEmail <- map[PropertyKey.employeeEmail.rawValue]
        self.merchantName <- map[PropertyKey.merchantName.rawValue]
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
