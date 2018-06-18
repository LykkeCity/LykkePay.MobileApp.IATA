import Foundation

class DefaultHistoryState: DefaultBaseState<HistoryModel> {
    
    internal required init?() {
        super.init()
        let model1 = HistoryModel()
        let model2 = HistoryModel()
        self.items = [model1, model2]
    }
}
