
import UIKit
import LocalAuthentication

public protocol PasswordInputCompleteProtocol: class {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String)
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?)
}

open class PasswordContainerView: UIView {
    
    //MARK: IBOutlet
    @IBOutlet open var passwordInputViews: [PasswordInputView]!
    @IBOutlet open weak var passwordDotView: PasswordDotView!
    @IBOutlet open weak var deleteButton: UIButton!
    @IBOutlet open weak var touchAuthenticationButton: UIButton!
    
    //MARK: Property
   
    open weak var delegate: PasswordInputCompleteProtocol?
    fileprivate var touchIDContext = LAContext()
    
    fileprivate var inputString: String = "" {
        didSet {
            #if swift(>=3.2)
                self.passwordDotView.inputDotCount = self.inputString.count
            #else
                self.passwordDotView.inputDotCount = self.inputString.characters.count
            #endif
            
            checkInputComplete()
        }
    }
    
    open var isVibrancyEffect = false {
        didSet {
            configureVibrancyEffect()
        }
    }
    
    open override var tintColor: UIColor! {
        didSet {
            guard !isVibrancyEffect else { return }
            self.deleteButton.setTitleColor(tintColor, for: UIControlState())
            self.passwordDotView.strokeColor = tintColor
            self.touchAuthenticationButton.tintColor = tintColor
            self.passwordInputViews.forEach {
                $0.textColor = tintColor
                $0.borderColor = tintColor
            }
        }
    }
    
    open var highlightedColor: UIColor! {
        didSet {
            guard !isVibrancyEffect else { return }
            self.passwordDotView.fillColor = highlightedColor
            self.passwordInputViews.forEach {
                $0.highlightBackgroundColor = highlightedColor
            }
        }
    }
    
    open var isTouchAuthenticationAvailable: Bool {
        return self.touchIDContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    open var touchAuthenticationEnabled = false {
        didSet {
            let enable = (isTouchAuthenticationAvailable && touchAuthenticationEnabled)
            self.touchAuthenticationButton.alpha = enable ? 1.0 : 0.0
            self.touchAuthenticationButton.isUserInteractionEnabled = enable
        }
    }
    
    open var touchAuthenticationReason = "Touch to unlock"
    
    //MARK: AutoLayout
    open var width: CGFloat = 0 {
        didSet {
            self.widthConstraint.constant = width
        }
    }
    fileprivate let kDefaultWidth: CGFloat = 288
    fileprivate let kDefaultHeight: CGFloat = 410
    fileprivate var widthConstraint: NSLayoutConstraint!
    
    fileprivate func configureConstraints() {
        let ratioConstraint = widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: kDefaultWidth / kDefaultHeight)
        self.widthConstraint = widthAnchor.constraint(equalToConstant: kDefaultWidth)
        self.widthConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([ratioConstraint, widthConstraint])
    }
    
    //MARK: VisualEffect
    open func rearrangeForVisualEffectView(in vc: UIViewController) {
        self.isVibrancyEffect = true
        self.passwordInputViews.forEach { passwordInputView in
            let label = passwordInputView.label
            label.removeFromSuperview()
            vc.view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.addConstraints(fromView: label, toView: passwordInputView, constraintInsets: .zero)
        }
    }
    
    //MARK: Init
    open class func create(withDigit digit: Int) -> PasswordContainerView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "PasswordContainerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! PasswordContainerView
        view.passwordDotView.totalDotCount = digit
        return view
    }
    
    open class func create(in stackView: UIStackView, digit: Int) -> PasswordContainerView {
        let passwordContainerView = create(withDigit: digit)
        stackView.addArrangedSubview(passwordContainerView)
        return passwordContainerView
    }
    
    //MARK: Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        configureConstraints()
        backgroundColor = .clear
        self.passwordInputViews.forEach {
            $0.delegate = self
        }
        self.deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.deleteButton.titleLabel?.minimumScaleFactor = 0.5
        
        
        touchAuthenticationEnabled = true
      
        if #available(iOS 11, *) {
            self.touchAuthenticationButton.isHidden = self.touchIDContext.biometryType == .faceID
        } else {
            self.touchAuthenticationButton.isHidden = !touchIDContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil)
        }
       
    }
    
    //MARK: Input Wrong
    open func wrongPassword() {
        self.passwordDotView.shakeAnimationWithCompletion {
            self.clearInput()
        }
    }
    
    open func clearInput() {
        self.inputString = ""
    }
    
    //MARK: IBAction
    @IBAction func deleteInputString(_ sender: AnyObject) {
        #if swift(>=3.2)
            guard self.inputString.count > 0 && !self.passwordDotView.isFull else {
                return
            }
            self.inputString = String(inputString.dropLast())
        #else
            guard self.inputString.characters.count > 0 && !self.passwordDotView.isFull else {
            return
            }
            self.inputString = String(inputString.characters.dropLast())
        #endif
    }
    
    @IBAction func touchAuthenticationAction(_ sender: UIButton) {
        guard isTouchAuthenticationAvailable else { return }
        
        var policy = LAPolicy.deviceOwnerAuthentication
        if #available(iOS 11.0, *) {
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
        self.touchIDContext.evaluatePolicy(policy, localizedReason: touchAuthenticationReason) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.passwordDotView.inputDotCount = self.passwordDotView.totalDotCount
                    // instantiate LAContext again for avoiding the situation that PasswordContainerView stay in memory when authenticate successfully
                    self.touchIDContext = LAContext()
                }
                self.delegate?.touchAuthenticationComplete(self, success: success, error: error)
            }
        }
    }
}

private extension PasswordContainerView {
    func checkInputComplete() {
        #if swift(>=3.2)
            if self.inputString.count == self.passwordDotView.totalDotCount {
                self.delegate?.passwordInputComplete(self, input: self.inputString)
            }
        #else
            if self.inputString.characters.count == self.passwordDotView.totalDotCount {
            self.delegate?.passwordInputComplete(self, input: self.inputString)
            }
        #endif
    }
    
    func configureVibrancyEffect() {
        let whiteColor = UIColor.white
        let clearColor = UIColor.clear
        //delete button title color
        var titleColor: UIColor!
        //dot view stroke color
        var strokeColor: UIColor!
        //dot view fill color
        var fillColor: UIColor!
        //input view background color
        var circleBackgroundColor: UIColor!
        var highlightBackgroundColor: UIColor!
        var borderColor: UIColor!
        //input view text color
        var textColor: UIColor!
        var highlightTextColor: UIColor!
        
        if isVibrancyEffect {
            //delete button
            titleColor = whiteColor
            //dot view
            strokeColor = whiteColor
            fillColor = whiteColor
            //input view
            circleBackgroundColor = clearColor
            highlightBackgroundColor = whiteColor
            borderColor = clearColor
            textColor = whiteColor
            highlightTextColor = whiteColor
        } else {
            //delete button
            titleColor = tintColor
            //dot view
            strokeColor = tintColor
            fillColor = highlightedColor
            //input view
            circleBackgroundColor = whiteColor
            highlightBackgroundColor = highlightedColor
            borderColor = tintColor
            textColor = tintColor
            highlightTextColor = highlightedColor
        }
        
        self.deleteButton.setTitleColor(titleColor, for: .normal)
        self.passwordDotView.strokeColor = strokeColor
        self.passwordDotView.fillColor = fillColor
        touchAuthenticationButton.tintColor = strokeColor
        self.passwordInputViews.forEach { passwordInputView in
            passwordInputView.circleBackgroundColor = circleBackgroundColor
            passwordInputView.borderColor = borderColor
            passwordInputView.textColor = textColor
            passwordInputView.highlightTextColor = highlightTextColor
            passwordInputView.highlightBackgroundColor = highlightBackgroundColor
            passwordInputView.circleView.layer.borderColor = UIColor.white.cgColor
            //borderWidth as a flag, will recalculate in PasswordInputView.updateUI()
            passwordInputView.isVibrancyEffect = isVibrancyEffect
        }
    }
}

extension PasswordContainerView: PasswordInputViewTappedProtocol {
    public func passwordInputView(_ passwordInputView: PasswordInputView, tappedString: String) {
        #if swift(>=3.2)
            guard self.inputString.count < self.passwordDotView.totalDotCount else {
                return
            }
        #else
            guard self.inputString.characters.count < self.passwordDotView.totalDotCount else {
            return
            }
        #endif

        self.inputString += tappedString
    }
}
