import ObjectMapper

class WalletsModel: Mappable {

    private enum PropertyKey: String {
        case walletId
        case assetId
        case baseAssetBalance
        case convertedBalance
    }

    internal var walletId: String?
    internal var assetId: String?
    internal var baseAssetBalance: Double?
    internal var convertedBalance: Double?

    internal required init?(map: Map) {
    }

    internal init() {}

    internal func mapping(map: Map) {
        walletId <- map[PropertyKey.walletId.rawValue]
        assetId <- map[PropertyKey.assetId.rawValue]
        baseAssetBalance <- map[PropertyKey.baseAssetBalance.rawValue]
        convertedBalance <- map[PropertyKey.convertedBalance.rawValue]
    }

}
