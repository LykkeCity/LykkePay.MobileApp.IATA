
import Foundation

class WalletsViewModel {

    internal var totalBalance: Double?

    internal var totalConvertedBalance: Double?

    internal var assetId: String?

    internal var wallets: [WalletsModel]?

    internal init() {}

    internal init(wallets: [WalletsModel]) {
         prepareWalletsForPresent(preparedWallets: wallets)
    }

    private func prepareWalletsForPresent(preparedWallets: [WalletsModel]) {
        var summaryBalance = 0.0
        var summaryConvertedBalance = 0.0
        for preparedWallet in preparedWallets {
            if let baseAssetBalance = preparedWallet.baseAssetBalance,
               let convertedBalance = preparedWallet.convertedBalance {
                summaryBalance += baseAssetBalance
                summaryConvertedBalance += convertedBalance
            }
        }
        if let assetId = preparedWallets.first?.assetId {
        fillViewModel(from: preparedWallets,
                      totalBalance: summaryBalance,
                      totalConvertedBalance: summaryConvertedBalance,
                      assetId: assetId )
        }
    }

    private func fillViewModel(from preparedWallets:[WalletsModel], totalBalance: Double, totalConvertedBalance: Double, assetId: String) {
        self.wallets = preparedWallets
        self.totalBalance = totalBalance
        self.totalConvertedBalance = totalConvertedBalance
        self.assetId = preparedWallets.first?.assetId
    }
}
