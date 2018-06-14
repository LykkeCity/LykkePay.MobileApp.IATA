import Foundation

class DefaultDisputeState: DefaultBaseState<DisputeModel> {
    
    internal required init?() {
        super.init()
        let model1 = DisputeModel()
        model1.invoice = InvoiceModel()
        model1.reason = "It doesn't look right"
        
        let model2 = DisputeModel()
        model2.invoice = InvoiceModel()
        model2.reason = "It is right. It is right It is right It is right It is right It is right It is right model model model model model model model model model model model model model model model model model model model model model model model model model"
        self.items = [model1, model2]
    }
}
