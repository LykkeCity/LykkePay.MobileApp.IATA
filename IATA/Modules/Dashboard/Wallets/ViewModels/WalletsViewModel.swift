
import Foundation

class WalletsViewModel {

    internal var totalBalance: Double?

    internal var assetId: String?

    internal var wallets: [WalletsModel]?

    internal var totalWallets: WalletsModel?

    internal init() {}

    internal init(wallets: [WalletsModel]) {
         prepareWalletsForPresent(preparedWallets: wallets)
    }

    private func prepareWalletsForPresent(preparedWallets: [WalletsModel]) {
        self.totalWallets = WalletsModel()
        self.totalWallets?.baseAssetBalance = 10.0
        self.totalWallets?.convertedBalance = 20.0
        self.totalWallets?.assetId = preparedWallets.first?.assetId
    }



    internal func initTestData() {
//        let testWallets1 = WalletsModel()
//        let testWallets2 = WalletsModel()
//        let testWallets3 = WalletsModel()
//        let testWallets4 = WalletsModel()
//        let testWallets6 = WalletsModel()
//
//        testWallets1.assetId = "IATA USD"
//        testWallets1.walletId = "IATA USD"
//        testWallets1.baseAssetBalance = 100
//        testWallets1.convertedBalance = 200
//
//
//        testWallets2.assetId = "IATA EUR"
//        testWallets2.walletId = "IATA EUR"
//        testWallets2.baseAssetBalance = 300
//        testWallets2.convertedBalance = 400
//
//        testWallets6.assetId = "IATA EUR"
//        testWallets6.walletId = "IATA EUR"
//        testWallets6.baseAssetBalance = 300
//        testWallets6.convertedBalance = 400
//
//        testWallets3.assetId = "IATA USD"
//        testWallets3.walletId = "IATA USD"
//        testWallets3.baseAssetBalance = 500
//        testWallets3.convertedBalance = 600
//
//        testWallets4.assetId = "IATA USD"
//        testWallets4.walletId = "IATA USD"
//        testWallets4.baseAssetBalance = 700
//        testWallets4.convertedBalance = 800

        //self.wallets = prepareWalletsForPresent(walletsArray: [testWallets1, testWallets2, testWallets3, testWallets4, testWallets6] )
    }

//    private func prepareWalletsForPresent(preparedWallets: [[String: [WalletsModel]]]) -> [WalletsModel] {
//        var wallets: [WalletsModel] = []
//        var totalBalanceByWallet = 0.0
//        for (_, values) in preparedWallets {
//            for value in  values {
//                if let baseAssetBalance = value.baseAssetBalance {
//                    totalBalanceByWallet += baseAssetBalance
//                }
//            }
//            let wallet = values.first
//            wallet?.baseAssetBalance = totalBalanceByWallet
//            if let wallet = wallet {
//                wallets.append(wallet)
//            }
//            totalBalanceByWallet = 0.0
//        }
//        return wallets
//    }




   
}
