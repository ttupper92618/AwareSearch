//
//  auiLoginViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 2/1/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import LocalAuthentication
import SwiftIconFont
import M13Checkbox
import SwiftVideoBackground

var pinAuthSuccessful: Bool = false

class auiLoginViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    let bgGradientLayer = CAGradientLayer()
    let rGradientLayer = CAGradientLayer()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    let localAuthOK = auiAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    var localAuth: auiBiometricAuthentication? = nil
    var localUser: String = ""
    
    @IBOutlet weak var auiTopRule: UIView!
    @IBOutlet weak var auiCredentialsView: UIView!
    @IBOutlet weak var auiUserIDField: UITextField!
    @IBOutlet weak var auiUserPasswordField: UITextField!
    @IBOutlet weak var auiUIDClear: UILabel!
    @IBOutlet weak var auiUPassClear: UILabel!
    @IBOutlet weak var auiFaceIdButton: UIButton!
    @IBOutlet weak var auiTouchIDButton: UIButton!
    @IBOutlet weak var auiUIDRule: UIView!
    @IBOutlet weak var auiPassRule: UIView!
    @IBOutlet weak var auiUIDRememberCheckbox: M13Checkbox!
    @IBOutlet weak var auiBiometryCheckbox: M13Checkbox!
    @IBOutlet weak var auiBiometryLabel: UILabel!
    @IBOutlet weak var auiLoginBlockView: UIView!
    @IBOutlet weak var auiSignInButton: auiRoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        bgGradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 0.00, green: 0.33, blue: 0.65, alpha: 0.88).cgColor as CGColor
        let color2 = UIColor(red: 0.35, green: 0.53, blue: 0.74, alpha: 0.88).cgColor as CGColor
        let color3 = UIColor(red: 0.26, green: 0.47, blue: 0.71, alpha: 0.88).cgColor as CGColor
        let color4 = UIColor(red: 0.35, green: 0.53, blue: 0.74, alpha: 0.88).cgColor as CGColor
        let color5 = UIColor(red: 0.00, green: 0.33, blue: 0.65, alpha: 0.88).cgColor as CGColor
        bgGradientLayer.colors = [color1, color2, color3, color4, color5]
        bgGradientLayer.locations = [0.0, 0.25, 0.50, 0.75, 1.0]
        self.view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        rGradientLayer.frame = auiTopRule.bounds
        let rColor1 = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00).cgColor as CGColor
        let rColor2 = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.88).cgColor as CGColor
        let rColor3 = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.88).cgColor as CGColor
        let rColor4 = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.88).cgColor as CGColor
        let rColor5 = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00).cgColor as CGColor
        rGradientLayer.colors = [rColor1, rColor2, rColor3, rColor4, rColor5]
        rGradientLayer.locations = [0.03, 0.21, 0.50, 0.79, 0.97]
        rGradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.5)
        rGradientLayer.endPoint = CGPoint.init(x: 1.0, y: 0.5)
        auiTopRule.layer.insertSublayer(rGradientLayer, at: 0)
        
        // add a tap recognizer
        self.hideKeyboardWhenTappedAround()
        
        // add a notification center observer
        NotificationCenter.default.addObserver(self, selector: #selector(auiLoginViewController.authenticationCompletionHandler(loginStatusNotification:)), name: .auiBiometricAuthenticationNotificationLoginStatus, object: nil)
        
        // get the stored user, if any
        let mAppUser = auiCoreDataHandler.getUser()
        let size = mAppUser!.count
        
        if(size > 0) {
            localUser = (mAppUser?.first?.auiUserName)!
            auiRememberUser = (mAppUser?.first?.auiRememberUser)!
        
        }
        
        // customize button
        auiUIDClear.font = UIFont.icon(from: .Ionicon, ofSize: 21.0)
        auiUIDClear.text = String.fontIonIcon("close-circled")
        auiUPassClear.font = UIFont.icon(from: .Ionicon, ofSize: 21.0)
        auiUPassClear.text = String.fontIonIcon("close-circled")
        
        // handle default biometry mode
        auiBiometryLabel.text = String(describing: auiAuthenticationMode)
        if (auiSelectedAuthenticationMode != "None" || auiSelectedAuthenticationMode != "Pin") {
            auiBiometryCheckbox.checkState = .checked
            if (auiSelectedAuthenticationMode == "FaceID") {
                auiFaceIdButton.isHidden = false
                
            } else {
                auiTouchIDButton.isHidden = false
                
            }
            
        } else {
            auiBiometryCheckbox.checkState = .unchecked
            
        }
        
        // handle remember me
        if(auiRememberUser) {
            auiUIDRememberCheckbox.checkState = .checked
            auiUserIDField.text = localUser
            
        }
        
        // Video BG
        // let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: "BGTest1", ofType: "mp4")!)
        try? VideoBackground.shared.play(view: view, videoName: "auiBackgroundLoop", videoType: "mov", darkness: 0.39)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // after the view has appeared, perform automated auth if available
        if (auiAuthModeConfigured && !primaryAuthenticationFailed && auiSessionCount == 0) {
            switch auiSelectedAuthenticationMode {
                case "Pin":
                    self.performPinAuthentication()
                
                case "FaceID":
                    auiBiometryCheckbox.checkState = .checked
                    self.performLocalAuthorization()
                
                case "TouchID":
                    auiBiometryCheckbox.checkState = .checked
                    self.performLocalAuthorization()
                
                default:
                    break
                
            }
            
        }
        
        // if there was a previous auth failure, note this
        if (primaryAuthenticationFailed) {
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        localAuth = nil
        
    }
    
    func performPinAuthentication() {
        // start up pin authorization
        performSegue(withIdentifier: "auiPinAuthSegue", sender: nil)
        
    }
    
    func performLocalAuthorization() {
        // perform local authorization
        if (localAuthOK) {
            localAuth = nil
            localAuth = auiBiometricAuthentication()
            localAuth?.reasonString = "Required in order to log in"
            localAuth?.authenticationWithBiometricID()
            
        }
        
    }
    
    @objc func authenticationCompletionHandler(loginStatusNotification: Notification) {
        if let _ = loginStatusNotification.object as? auiBiometricAuthentication, let userInfo = loginStatusNotification.userInfo {
            if let authStatus = userInfo[auiBiometricAuthentication.status] as? auiBiometricAuthenticationStatus {
                if authStatus.success {
                    print("Login Success")
                    currentSessionAuthenticated = true
                    DispatchQueue.main.async {
                        self.localAuthSuccess()
                        
                    }
                    
                } else {
                    if let errorCode = authStatus.errorCode {
                        print("Login Fail with code \(String(describing: errorCode)) reason \(authStatus.errorMessage)")
                        currentSessionAuthenticated = false
                        DispatchQueue.main.async {
                            self.biometricAuthFailure()
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        localAuth = nil
        
    }
    
    func localAuthSuccess() {
        // Authentication with local auth was successful, so trigger login
        
        // TODO: Hand off creds to AWH
        auiJSBridge.passTrustedCredentials(userID: auiUID, password: auiPass)
        
        // dispose the view
        currentSessionAuthenticated = true
        localAuth = nil
        
        // self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToMain", sender: self)
        
    }
    
    func biometricAuthFailure() {
        // handle a local auth failure
        localAuth = nil
        
    }
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) {
        if (pinAuthSuccessful) {
            self.localAuthSuccess()
            
        }
        
    }
    
    @IBAction func auiUIDEditingDidBegin(_ sender: UITextField) {
        
    }
    
    @IBAction func auiUIDEditingDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction func auiPassEditingDidBegin(_ sender: UITextField) {
        
    }
    
    @IBAction func auiPassEditingDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction func auiTriggerBiometricID(_ sender: Any) {
        self.performLocalAuthorization()
        
    }
    
    @IBAction func auiSubmitButton(_ sender: auiRoundedButton) {
        let lUID = auiUserIDField.text
        let lPass = auiUserPasswordField.text
        if (lUID == "" || lPass == "") {
            if (lUID == "" ) {
                auiUserIDField.shake()
                
            }
            
            if (lPass == "") {
                auiUserPasswordField.shake()
                
            }
            
        } else {
            let rStatus = auiUIDRememberCheckbox.checkState
            if (rStatus == .checked) {
                _ = auiCoreDataHandler.saveUser(userName: lUID!, password: "", remember: true)
                
            }
            
            auiSessionCount += 1
            auiUID = lUID!
            auiPass = lPass!
            self.localAuthSuccess()
            
        }
        
    }
    
}

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSAttributedStringKey.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else { return UIColor.clear }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSAttributedStringKey.foregroundColor : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }
}
