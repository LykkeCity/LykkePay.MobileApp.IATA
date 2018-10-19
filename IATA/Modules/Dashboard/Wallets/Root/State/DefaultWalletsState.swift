import Foundation
import PromiseKit
import ObjectMapper


class DefaultWalletsState: DefaultBaseState<WalletsViewModel> {

    public lazy var service: PaymentService = DefaultPaymentService()

    private var convertAssetIdParams = "convertAssetIdParams"

    func getWalletsStringJson(id: String) -> Promise<String> {
        self.convertAssetIdParams = id
        return self.service.getWallets(convertAssetIdParams: convertAssetIdParams)
    }

    func mapping(jsonString: String) {
        let walletsModels = !jsonString.isEmpty ? Mapper<WalletsModel>().mapArray(JSONObject: jsonString.toJSON()) : Array<WalletsModel>()
        if let walletModelsItems = walletsModels {
            let walletsViewModels = prepareWalletsViewModels(from: walletModelsItems)
            self.items = walletsViewModels
        } else {
            self.items = [WalletsViewModel]()
        }
    }

    func prepareWalletsViewModels(from walletsModels: [WalletsModel]) -> [WalletsViewModel] {
        var walletsForPresent: [WalletsViewModel] = []
        let walletsForTest = walletsModels
        let walletsDictionary = prepareWalletsDictionary(wallets: walletsForTest)
        
        for (key, _) in walletsDictionary {
            if let wallet = walletsDictionary[key] {
                let walletViewModel = WalletsViewModel(wallets: wallet)
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

    func getTotalBalance() -> String {
        var totaBalance = 0.0
        for wallet in items {
            if let convertedBalance = wallet.totalConvertedBalance {
                totaBalance += convertedBalance
            }
        }
        let totalBalanceString = Formatter.formattedWithSeparator(valueDouble: totaBalance)
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            return totalBalanceString + " " + symbol
        } else {
            return totalBalanceString
        }
    }
    
}
