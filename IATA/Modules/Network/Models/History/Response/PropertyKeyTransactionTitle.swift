import Foundation
import ObjectMapper

public class PropertyKeyTransactionModel : Mappable {
    var title: String?
    var key: HistoryTransactionModel.PropertyKey?
    var value: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
    }
    
    public required init?(keyValue: String, value: String?) {
        self.key = HistoryTransactionModel.PropertyKey(rawValue: keyValue)
        self.title = self.getTitle()
        self.value = value
    }
    
    func getTitle() -> String? {
        guard let value = key else {
            return ""
        }
        switch value {
        case .merchantLogoUrl, .title, .id, .assetId:
            return nil
        default:
            return value.rawValue
        }
    }
}
