import Foundation
import ObjectMapper


class ExchangeViewModel: Mappable  {
    var sum: Double?
    var currency: String?
    var info: String?
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
        self.info = isBase ? "Sell" : "Buy"
        self.isBase = isBase
        self.assetId = assetId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
    }
}
