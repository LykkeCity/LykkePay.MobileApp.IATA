import Foundation
import PromiseKit
import ObjectMapper


class DefaultWalletsState: WalletsState {

    public lazy var service: PaymentService = DefaultPaymentService()

    private var wallets: [WalletsViewModel] = []

    private let convertAssetIdParams = "convertAssetIdParams"

    func mapping(jsonString: String!) -> [WalletsModel] {
        return !jsonString.isEmpty ? Mapper<WalletsModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<WalletsModel>()
    }

    func getWalletsStringJson() -> Promise<String> {
        return self.service.getWallets(convertAssetIdParams: convertAssetIdParams)
    }

    func generateTestWalletsData() -> [WalletsModel] {
        var rger = [WalletsModel]()
        var test = WalletsViewModel()
        let testWalletsModels: [WalletsModel] = []
        let testWallets = generateData()
        let walletsDictionary =  prepareWalletsDictionary(wallets: testWallets)

        for (key, values) in walletsDictionary {
             test = WalletsViewModel(wallets: walletsDictionary[key]!)
            if let asfw = test.totalWallets {
            rger.append(asfw)
            }
        }
        return rger
    }

    private func prepareWalletsDictionary(wallets: [WalletsModel]) -> [String: [WalletsModel]]  {
        var dictionaryOfWallets = [String: [WalletsModel]]()
        for walet in wallets {
            if let assetId = walet.assetId {
                dictionaryOfWallets[assetId] = wallets.filter { $0.assetId == assetId }
            }
        }
        return dictionaryOfWallets
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

    private func generateData() -> [WalletsModel] {
                let testWallets1 = WalletsModel()
                let testWallets2 = WalletsModel()
                let testWallets3 = WalletsModel()
                let testWallets4 = WalletsModel()
                let testWallets6 = WalletsModel()

                testWallets1.assetId = "IATA USD"
                testWallets1.walletId = "IATA USD"
                testWallets1.baseAssetBalance = 100
                testWallets1.convertedBalance = 200


                testWallets2.assetId = "IATA EUR"
                testWallets2.walletId = "IATA EUR"
                testWallets2.baseAssetBalance = 300
                testWallets2.convertedBalance = 400

                testWallets6.assetId = "IATA EUR"
                testWallets6.walletId = "IATA EUR"
                testWallets6.baseAssetBalance = 300
                testWallets6.convertedBalance = 400

                testWallets3.assetId = "IATA USD"
                testWallets3.walletId = "IATA USD"
                testWallets3.baseAssetBalance = 500
                testWallets3.convertedBalance = 600

                testWallets4.assetId = "IATA USD"
                testWallets4.walletId = "IATA USD"
                testWallets4.baseAssetBalance = 700
                testWallets4.convertedBalance = 800
        return [testWallets1, testWallets2, testWallets3,testWallets4, testWallets6]
    }
}
