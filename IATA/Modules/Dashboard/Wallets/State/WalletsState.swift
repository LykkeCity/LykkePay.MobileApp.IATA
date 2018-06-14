import Foundation
import PromiseKit

protocol WalletsState {

    func mapping(jsonString: String!) -> [WalletsModel]

    func getWalletsStringJson() -> Promise<String>

    func generateTestWalletsData() -> [WalletsModel]

    func getTotalBalance(from wallets: [WalletsModel]) -> String
    
}
