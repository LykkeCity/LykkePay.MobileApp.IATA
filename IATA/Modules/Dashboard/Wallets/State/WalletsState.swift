import Foundation
import PromiseKit

protocol WalletsState {

    func mapping(jsonString: String!) -> [WalletsModel]

    func getWalletsStringJson() -> Promise<String>

    func generateTestWalletsData() -> [WalletsViewModel]

    func getTotalBalance(from wallets: [WalletsViewModel]) -> String
    
}
