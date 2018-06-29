import Foundation
import ObjectMapper

class ExchangeViewModels: Mappable {
    var items = [ExchangeViewModel]()
    
    
    required init?(map: Map) {
        
    }
    
    required init() {}
    
    func mapping(map: Map) {
        
    }
}

class ExchangeViewModel: Mappable  {
    var sum: Double?
    var currency: String?
    var icon: UIImage?
    var isBase: Bool?
    var assetId: String?
    
    required init(isUsd: Bool, isBase: Bool, assetId: String?, totalUsd: Double?, totalEuro: Double?) {
        if isUsd {
            self.sum = totalUsd
            self.currency = "$"
            self.icon = R.image.ic_usFlagMediumIcn()
        } else {
            self.sum =  totalEuro
            self.currency = "€"
            self.icon = R.image.ic_eurFlagMediumIcn()
        }
        self.isBase = isBase
        self.assetId = assetId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
    }
}
