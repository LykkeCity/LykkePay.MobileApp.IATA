import Foundation

extension ExhangeViewController {
    
    func loadExchangeInfo() {
        self.sumTextField.text = Formatter.formattedWithSeparator(valueDouble: 0.0)
        self.setEnabledExchange(isEnabled: false)
        self.state.loadExchangeData(sourceAmount: self.sumTextField.text)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.initAsset(model: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleErrorExchangeInfo(error: error)
            })
    }
    
    func makeExchange() {
        self.state.makeExchange(sourceAmount: self.sumTextField.text)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.loadDataInfo()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }
    
    func loadDataInfo() {
        self.beginRefresh()
        self.sumTextField.text = "0"
        self.state.loadStartData()?
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state.mapping(jsonString: jsonString)
        self.loadExchangeInfo()
    }
    
    private func handleErrorExchangeInfo(error: Error) {
        self.showErrorAlert(error: error)
        self.refresh.endRefreshing()
    }
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.loadExchangeInfo()
    }
}
