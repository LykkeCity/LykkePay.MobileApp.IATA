
import Foundation
import ObjectMapper

class CashOutViewModel: Mappable {
    
    var totalSum: Double?
    var assertId: String?
    var desiredAssertId: String?
    var symbol: String? = "$"
    var desiredSymbol: String?
    var items: [DictionaryAssertId]?
    var selectedDesiredAssertId: String?
    
    required init?(map: Map) {
        
    }
    
    required init() {}
    
    func mapping(map: Map) {
        
    }
}
