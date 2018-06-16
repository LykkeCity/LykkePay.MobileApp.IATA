import Foundation

protocol BaseViewState {
    func getHashPass(value: String) -> String    
    func getError(_ name:String, values: [String]) -> String
}

