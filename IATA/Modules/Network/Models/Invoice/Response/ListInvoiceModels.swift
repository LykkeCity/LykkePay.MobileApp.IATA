import Foundation
import ObjectMapper

class ListInvoiceModels<T>: Mappable {
    
    var result: [T]?
    
    internal required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        result <- map
    }
    
    
}
