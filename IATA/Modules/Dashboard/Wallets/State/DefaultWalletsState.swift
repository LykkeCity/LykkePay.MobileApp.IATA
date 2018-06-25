import Foundation
import PromiseKit
import ObjectMapper


class DefaultWalletsState: DefaultBaseState<WalletsViewModel> {

    public lazy var service: PaymentService = DefaultPaymentService()

    private var convertAssetIdParams = "convertAssetIdParams"

    func getWalletsStringJson() -> Promise<String> {
        if let id = UserPreference.shared.getCurrentCurrency()?.id {
            convertAssetIdParams = id
        }
        return self.service.getWallets(convertAssetIdParams: convertAssetIdParams)
    }

    func mapping(jsonString: String!) {
        let walletsModels = !jsonString.isEmpty ? Mapper<WalletsModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<WalletsModel>()
        let walletsViewModels = prepareWalletsViewModels(from: walletsModels)
        self.items = walletsViewModels
    }

    func prepareWalletsViewModels(from walletsModels: [WalletsModel]) -> [WalletsViewModel] {
        var walletsForPresent: [WalletsViewModel] = []
        var walletsForTest = walletsModels
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
        
        if let symbol = UserPreference.shared.getCurrentCurrency()?.symbol {
            return String(totaBalance) + symbol
        } else {
            return String(totaBalance)
        }
    }
    
}
