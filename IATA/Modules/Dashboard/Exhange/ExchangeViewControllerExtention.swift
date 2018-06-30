import Foundation

extension ExhangeViewController {
    
    func loadExchangeInfo(isNeedMakePayment: Bool) {
        self.setEnabledExchange(isEnabled: false)
        let valueString = isNeedMakePayment ? self.sumTextField.text : "0.1"
        self.state.loadExchangeData(sourceAmount: valueString)
            .then(execute: { [weak self] (result: ExchangeModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.initAsset(model: result)
                strongSelf.initEnabled()
                if isNeedMakePayment {
                    strongSelf.processPayment(value: result)
                }
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleErrorExchangeInfo(error: error)
            })
    }
    
    func processPayment(value: ExchangeModel) {
        let valueString = self.sumTextField.text
       self.sumTextField.text = "0"
        self.setEnabledExchange(isEnabled: false)
       // self.initAsset(model: nil)
        self.view.endEditing(true)
        let viewController = PinViewController()
        viewController.navController = self
        viewController.isValidationTransaction = true
        viewController.messageTouch = R.string.localizable.exchangeSourcePayConfirmation()
        viewController.completion = {
            if let valueStr = valueString {
                self.makeExchange(value: value, valueString: valueStr)
            }
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func makeExchange(value: ExchangeModel, valueString: String) {
        self.state.makeExchange(sourceAmount: value, valueString: valueString)
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
        self.loadExchangeInfo(isNeedMakePayment: false)
    }
    
    private func handleErrorExchangeInfo(error: Error) {
        self.showErrorAlert(error: error)
        self.refresh.endRefreshing()
    }
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.loadExchangeInfo(isNeedMakePayment: false)
    }
}
