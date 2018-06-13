
import UIKit

class PinViewController: UIViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var labelTitle: UILabel!
    
    private var state: PinViewState = DefaultPinViewState() as PinViewState
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var isValidation = true
    var countOfTry = 0
    var pinCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBar()
        
        //create PasswordContainerView
        self.passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        self.passwordContainerView.delegate = self as PasswordInputCompleteProtocol
        self.passwordContainerView.touchAuthenticationEnabled = isValidation
        
        self.labelTitle.text = self.isValidation ? "Pin.Validation.Title".localize() : "Pin.Setup.Title".localize()
    }
    
    private func initNavBar() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        
        self.initBackButton()
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: "Common.NavBar.Cancel".localize(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func cancel(_ sender: Any) {
        self.openSignIn()
    }
    
    func openSignIn() {
        CredentialManager.shared.clearSavedData()
        self.navigationController?.present(SignInViewController(), animated: true, completion: nil)
    }
}

extension PinViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        self.isValidation ? validation(input) : savePin(input)
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            self.passwordContainerView.clearInput()
        }
    }
}

private extension PinViewController {
    
    func savePin(_ input: String) -> Void {
        if (pinCode.isEmpty) {
            self.pinCode = input
            self.reset()
        } else if (pinCode.elementsEqual(input)) {
            self.state.savePin(pin: input)
                .withSpinner(in: view)
                .then(execute: { [weak self] (result: Void) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    UserPreference.shared.saveForceUpdatePin(false)
                    strongSelf.validationSuccess()
                }).catch(execute: { [weak self] error -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.validationFail()
                })
        }
    }
    
    func validation(_ input: String) -> Void {
        self.state.validatePin(pin: input)
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: PinValidationResponse) -> Void in
                guard let strongSelf = self else {
                    return
                }
                if (result.passed)! {
                    strongSelf.validationSuccess()
                } else {
                    strongSelf.validationFail()
                }
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.validationFail()
            })
    }
    
    func validationSuccess() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.present(TabBarController(), animated: true, completion: nil)
        self.navigationController?.navigationBar.barTintColor = Theme.init().navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func validationFail() {
        self.countOfTry += 1
        self.passwordContainerView.wrongPassword()
        if (countOfTry > 2) {
            self.openSignIn()
        }
    }
    
    func reset() {
        self.passwordContainerView.clearInput()
        self.labelTitle.text = "Pin.Resubmit.Title".localize()
    }
}

