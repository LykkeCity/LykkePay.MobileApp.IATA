import Foundation
import PromiseKit
import ObjectMapper


class DefaultWalletsState: WalletsState {

    public lazy var service: PaymentService = DefaultPaymentService()

    private var wallets: [WalletsModel] = []

    private let convertAssetIdParams = "convertAssetIdParams"

    func mapping(jsonString: String!) -> [WalletsModel] {
        return !jsonString.isEmpty ? Mapper<WalletsModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<WalletsModel>()
    }

    func getWalletsStringJson() -> Promise<String> {
        return self.service.getWallets(convertAssetIdParams: convertAssetIdParams)
    }

    func generateTestWalletsData() -> [WalletsModel] {
        let testWallets1 = WalletsModel()
        let testWallets2 = WalletsModel()

        testWallets1.assetId = "IATA USD"
        testWallets1.walletId = "IATA USD"
        testWallets1.baseAssetBalance = 100
        testWallets1.convertedBalance = 200

        testWallets2.assetId = "IATA EUR"
        testWallets2.walletId = "IATA EUR"
        testWallets2.baseAssetBalance = 300
        testWallets2.convertedBalance = 400

        wallets = [testWallets1, testWallets2]
        return wallets
    }

    func getTotalBalance(from wallets: [WalletsModel]) -> String {
        var totaBalance = 0.0
        for wallet in wallets {
            if let convertedBalance = wallet.convertedBalance {
                totaBalance += convertedBalance
            }
        }
        return String(totaBalance) + " $"
    }
}
