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
    
    required init(isUsd: Bool, state: DefaultExchangeState, isBase: Bool, assetId: String?) {
        if isUsd {
            self.sum = state.usd?.totalBalance
            self.currency = "$"
            self.icon = R.image.ic_usFlagMediumIcn()
        } else {
            self.sum =  state.euro?.totalBalance
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
