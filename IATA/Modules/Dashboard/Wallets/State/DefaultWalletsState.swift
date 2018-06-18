import Foundation
import PromiseKit
import ObjectMapper


class DefaultWalletsState: DefaultBaseState<WalletsModel> {

    public lazy var service: PaymentService = DefaultPaymentService()

    private var wallets: [WalletsViewModel] = []

    private let convertAssetIdParams = "convertAssetIdParams"

    func mapping(jsonString: String!) -> [WalletsModel] {
        return !jsonString.isEmpty ? Mapper<WalletsModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<WalletsModel>()
    }

    func getWalletsStringJson() -> Promise<String> {
        return self.service.getWallets(convertAssetIdParams: convertAssetIdParams)
    }

    func generateTestWalletsData() -> [WalletsViewModel] {
        var walletsForPresent: [WalletsViewModel] = []
        var walletViewModel = WalletsViewModel()
        let testWallets = generateData()
        let walletsDictionary = prepareWalletsDictionary(wallets:testWallets)
        for (key, _) in walletsDictionary {
            if let wallet = walletsDictionary[key] {
                walletViewModel = WalletsViewModel(wallets: wallet)
                walletsForPresent.append(walletViewModel)
            }
        }
        return walletsForPresent
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

    func getTotalBalance(from wallets: [WalletsViewModel]) -> String {
        var totaBalance = 0.0
        for wallet in wallets {
            if let convertedBalance = wallet.totalConvertedBalance {
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
        testWallets1.baseAssetBalance = 200
        testWallets1.convertedBalance = 300


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
