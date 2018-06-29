import Foundation

extension ExhangeViewController {
    
    func loadExchangeInfo() {
        self.setEnabledExchange(isEnabled: false)
        self.state.loadExchangeData(sourceAmount: self.sumTextField.text)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.initAsset(model: result)
                strongSelf.initEnabled()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleErrorExchangeInfo(error: error)
            })
    }
    
    func makeExchange(value: String) {
        self.state.makeExchange(sourceAmount: value)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.exchangeSuccess()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }
    
    func exchangeSuccess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.loadDataInfo(isNeedToCleanUp: true)
        })
    }
    
    func loadDataInfo(isNeedToCleanUp: Bool) {
        self.beginRefresh()
        if isNeedToCleanUp {
            self.sumTextField.text = "0"
        }
        
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
