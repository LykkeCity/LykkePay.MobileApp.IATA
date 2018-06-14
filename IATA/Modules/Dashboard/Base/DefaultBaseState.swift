import Foundation
import ObjectMapper

class DefaultBaseState<T: Mappable> {
    
    var items: [T] = []
    
    internal required init?(){}
    
    func getItems() -> [T] {
        return self.items
    }
    
}
