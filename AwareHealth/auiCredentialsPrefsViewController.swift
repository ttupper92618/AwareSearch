//
//  auiCredentialsPrefsViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/25/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import WebKit
import SwiftKeychainWrapper
import WVCheckMark

// user identity
var auiPassVerify: String = ""
var auiCredsValid: Bool = false

class auiCredentialsPrefsViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    let bgGradientLayer = CAGradientLayer()
    let rGradientLayer = CAGradientLayer()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @IBOutlet weak var auiTopRule: UIView!
    @IBOutlet weak var auiAuthTextBlock: UITextView!
    @IBOutlet weak var auiUserId: UITextField!
    @IBOutlet weak var auiPassword: UITextField!
    @IBOutlet weak var auiPasswordVerification: UITextField!
    @IBOutlet weak var auiModeStatusView: UIView!
    @IBOutlet weak var auiModeStatusCheckmark: WVCheckMark!
    @IBOutlet weak var auiModeStatusLabel: UILabel!
    @IBOutlet weak var auiChangeCredentialsButton: auiRoundedButton!
    
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
        
        // no scroll please
        auiAuthTextBlock.isScrollEnabled = false
        
        // give the textfields some delegates and types
        auiUserId.delegate = self
        auiPassword.delegate = self
        auiPasswordVerification.delegate = self
        auiUserId.textContentType = UITextContentType("")
        auiPassword.textContentType = UITextContentType("")
        auiPasswordVerification.textContentType = UITextContentType("")
        
        // fill the fields
        let mBaseURL = auiCoreDataHandler.getBaseURL()
        let mAppUser = auiCoreDataHandler.getUser()
        let mBSize = mBaseURL!.count
        let mAUSize = mAppUser!.count
        
        if (mBSize > 0) {
            auiPasswordVerification.text = auiPassword.text
            auiUID = auiUserId.text!
            auiPass = auiPassword.text!
            auiPassVerify = auiPass
            
        }
        
        if (mAUSize > 0) {
            auiUserId.text = mAppUser?.first?.auiUserName
            auiPassword.text = mAppUser?.first?.auiUserPassword
            auiRememberUser = (mAppUser?.first?.auiRememberUser)!
            
        }
        
        // use keychain for the user / password
        let userName: String? = KeychainWrapper.standard.string(forKey: "userName")
        let password: String? = KeychainWrapper.standard.string(forKey: "password")
        if userName != nil { print(userName!, password!) }
        
        if (userName != nil) {
            auiUserId.text = userName
            auiUID = auiUserId.text!
            
        }
    
        if (password != nil) {
            auiPassword.text = password
            auiPasswordVerification.text = auiPassword.text
            auiPass = auiPassword.text!
            auiPassVerify = auiPass
            
        }
        
        if (userName != nil && password != nil) { auiCredsValid = true }
        
        // add swipe recognizers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // if credentials have been provided, prepare to show the ok config screen
        if (auiCredsValid) {
            currentSessionAuthenticated = true
            self.hideCredentialControls()
            
        } else {
            self.showCredentialControls()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (auiCredsValid) {
            self.hideCredentialControls()
            self.showStatusView()
            
        } else {
            self.hideStatusView()
            self.showCredentialControls()
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func hideCredentialControls() {
        // hide the appKey entry controls
        auiUserId.isHidden = true
        auiPassword.isHidden = true
        auiPasswordVerification.isHidden = true
        
    }
    
    func showCredentialControls() {
        // show the appKey entry controls
        auiUserId.isHidden = false
        auiPassword.isHidden = false
        
    }
    
    func showStatusView() {
        // show the appKey status view
        auiModeStatusView.isHidden = false
        auiModeStatusCheckmark.setColor(color: UIColor.white.cgColor)
        auiModeStatusCheckmark.start()
        
    }
    
    func hideStatusView() {
        // hide the appKey status view
        auiModeStatusView.isHidden = true
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            
        } else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            
        }
        
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        let nextTag: Int = sender.tag + 1
        let nextResponder: UIResponder? = sender.superview?.superview?.viewWithTag(nextTag)
        if let next = nextResponder {
            // Found next responder, so set it.
            next.becomeFirstResponder()
            
        } else {
            // Not found, so remove keyboard.
            sender.resignFirstResponder()
            
        }
        
        return false
        
    }
    
    @IBAction func auiCancelPrefs(_ sender: UIButton) {
        didManuallyReleasePrefs = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func auiUserIdFieldEdit(_ sender: UITextField) {

    }
    
    @IBAction func auiUserIdFieldChanged(_ sender: UITextField) {
        impactGenerator.impactOccurred()
        
    }
    
    @IBAction func auiUserIdFieldEditDone(_ sender: UITextField) {
        if (sender.text != "") {
            auiUID = sender.text!
            
        }
        
    }
    
    @IBAction func auiPasswordFieldEdit(_ sender: UITextField) {
        
    }
    
    @IBAction func auiPasswordFieldChanged(_ sender: UITextField) {
        impactGenerator.impactOccurred()
        
    }
    
    @IBAction func auiPasswordFieldEditDone(_ sender: UITextField) {
        if (sender.text != "") {
            auiPass = sender.text!
            auiPasswordVerification.isHidden = false
            
        }
        
    }
    
    @IBAction func auiPasswordVerificationFieldEdit(_ sender: UITextField) {
        
    }
    
    
    @IBAction func auiPasswordVerificationFieldChanged(_ sender: UITextField) {
        impactGenerator.impactOccurred()
        
    }
    
    @IBAction func auiPasswordVerificationFieldEditDone(_ sender: UITextField) {
        if (sender.text != "") {
            auiPassVerify = sender.text!
            processUserIdentity(mPasswordVerification: sender.text!)
            
        }
        
    }
    
    @IBAction func auiPreviousView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func auiNextView(_ sender: UIButton) {
        processUserIdentity(mPasswordVerification: auiPassVerify)
        
    }
    
    
    @IBAction func auiChangeCredentials(_ sender: auiRoundedButton) {
        // change the defined credentials
        auiUID = ""
        auiPass = ""
        auiPassVerify = ""
        auiCredsValid = false
        auiUserId.text = ""
        auiPassword.text = ""
        auiPasswordVerification.text = ""
        self.hideStatusView()
        self.showCredentialControls()
        auiUserId.becomeFirstResponder()
        
    }
    
    func processUserIdentity(mPasswordVerification: String) {
        
        if (mPasswordVerification == auiPass && auiUID.count > 0) {
            // check if the combo is valid
            
            // TEMP: we store it and go to the next step
            _ = auiCoreDataHandler.saveUser(userName: auiUID, password: auiPass, remember: false)
            
            // we are going to poke the UID and pass into the keychain
            _ = KeychainWrapper.standard.set(auiUID, forKey: "userName")
            _ = KeychainWrapper.standard.set(auiPass, forKey: "password")
            
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auiAuthorizationPrefs") as! auiAuthMethodsViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        } else {
            // if passwords don't match
            if (mPasswordVerification != auiPass) {
                auiPassword.shake()
                auiPasswordVerification.shake()
                
            }
            
            if (auiUID.count == 0) {
                auiUserId.shake()
                
            }
            
            if (auiPass.count == 0) {
                auiPassword.shake()
                
            }
            
        }
        
    }
    
    func validCredentials() -> Bool {
        var isValid: Bool = true
        if (auiUID.count == 0) {
            isValid = false
            
        }
        
        if (auiPass.count == 0) {
            isValid = false
            
        }
        
        if (auiPassVerify.count == 0) {
            isValid = false
            
        }
        
        if (auiPassVerify != auiPass) {
            isValid = false
            
        }
        
        return isValid
        
    }
    
}
