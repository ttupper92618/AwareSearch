//
//  auiAuthMethodsViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/30/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import LocalAuthentication
import WVCheckMark

class auiAuthMethodsViewController: UIViewController, UITextFieldDelegate {
    let bgGradientLayer = CAGradientLayer()
    let rGradientLayer = CAGradientLayer()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @IBOutlet weak var auiTopRule: UIView!
    @IBOutlet weak var auiAuthenticationModeControl: UISegmentedControl!
    @IBOutlet weak var auiTextField: UITextView!
    @IBOutlet weak var auiModeStatusView: UIView!
    @IBOutlet weak var auiModeStatusCheckmark: WVCheckMark!
    @IBOutlet weak var auiModeStatusLabel: UILabel!
    @IBOutlet weak var auiChangePinButton: auiRoundedButton!
    
    func biometricType() -> BiometricType {
        if #available(iOS 11, *) {
            let _ = auiAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(auiAuthenticationContext.biometryType) {
                case .none:
                    auiAuthenticationModesCount = 2
                    return .none
                
                case .touchID:
                    return .TouchID
                
                case .faceID:
                    return .FaceID
                
            }
            
        } else {
            return auiAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .TouchID : .none
            
        }
        
    }
    
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
        
        // add swipe recognizers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // determine if we have any biometric support, and what kind if so
        auiAuthenticationMode = biometricType()
        
        // configure authMode control
        self.setModeControl()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // set the status display
        switch auiSelectedAuthenticationMode {
        case "Pin":
            auiChangePinButton.isHidden = false
            showStatusView(pin: "Pin", isOk: true, label: "A pin has been configured")
            
        case "FaceID":
            showStatusView(pin: "FaceID", isOk: true, label: "FaceID is enabled")
            
        case "TouchID":
            showStatusView(pin: "TouchID", isOk: true, label: "TouchID is enabled")
            
        case "None":
            self.resetAuthMode()
            auiModeStatusView.isHidden = true
            
        default:
            auiChangePinButton.isHidden = true
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func resetAuthMode() {
        auiAuthPin = []
        auiAuthModeConfigured = false
        _ = auiCoreDataHandler.saveAuthModeData(authModeDefined: false, authPin: [], authModeString: "", authModeIndex: auiAuthenticationModesCount - 1)
        
    }
    
    func setModeControl() {
        // configure authMode control
        let font: [AnyHashable : Any] = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)]
        auiAuthenticationModeControl.setTitleTextAttributes(font, for: .normal)
    
        if (String(describing: auiAuthenticationMode) == "none") { auiAuthenticationModeControl.removeSegment(at: 0, animated: false) }
        
        if (!auiAuthModeConfigured) { auiAuthenticationModeControl.selectedSegmentIndex = auiAuthenticationModesCount - 1 }
        
        auiAuthenticationModeControl.setTitle(String(describing: auiAuthenticationMode), forSegmentAt: 0)
        
        // set the authentication mode to whatever is configured
        if (auiAuthModeConfigured) {
            auiAuthenticationModeControl.selectedSegmentIndex = auiSelectedAuthenticationModeIndex
            
        }
        
    }
    
    func auiConfigureAuthPin() {
        // set up to configure an auth pin
        // auiTextField.isHidden = true
        performSegue(withIdentifier: "auiPinViewSegue", sender: nil)
        
    }
    
    func showStatusView(pin: String, isOk: Bool, label: String) {
        // show a given status view, with a given status
        auiModeStatusView.isHidden = false
        auiModeStatusLabel.text = label
        auiModeStatusCheckmark.setColor(color: UIColor.white.cgColor)
        if (isOk) {
            auiModeStatusCheckmark.start()
            
        } else {
            auiModeStatusCheckmark.startX()
            
        }
        
        // perform actions that are mode specific
        switch auiSelectedAuthenticationMode {
        case "Pin":
            auiChangePinButton.isHidden = false
            
        case "None":
            auiChangePinButton.isHidden = true
            
        default:
            auiChangePinButton.isHidden = true
            
        }
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            
        } else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            
        }
        
    }
    
    @IBAction func auiCancelPrefs(_ sender: UIButton) {
        didManuallyReleasePrefs = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func auiPreviousView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func auiAuthModeSelected(_ sender: UISegmentedControl) {
        auiSelectedAuthenticationMode = auiAuthenticationModeControl.titleForSegment(at: auiAuthenticationModeControl.selectedSegmentIndex)!
        auiSelectedAuthenticationModeIndex = auiAuthenticationModeControl.selectedSegmentIndex
        switch(auiSelectedAuthenticationMode) {
            case "None":
                auiAuthModeConfigured = false
                auiModeStatusView.isHidden = true
            
            case "FaceID":
                auiAuthModeConfigured = true
                showStatusView(pin: "FaceID", isOk: true, label: "FaceID is enabled")
                _ = auiCoreDataHandler.saveAuthModeData(authModeDefined: true, authPin: [], authModeString: "FaceID", authModeIndex: auiSelectedAuthenticationModeIndex)
                return
            
            case "TouchID":
                auiAuthModeConfigured = true
                showStatusView(pin: "TouchID", isOk: true, label: "TouchID is enabled")
                _ = auiCoreDataHandler.saveAuthModeData(authModeDefined: true, authPin: [], authModeString: "TouchID", authModeIndex: auiSelectedAuthenticationModeIndex)
                return
            
            case "Pin":
                auiConfigureAuthPin()
                return
            
            default:
                return
            
            }
        
    }
    
    @IBAction func auiChangePin(_ sender: auiRoundedButton) {
        auiConfigureAuthPin()
        
    }
    
    @IBAction func unwindToThisViewController(segue:UIStoryboardSegue) {
        if(auiSelectedAuthenticationMode == "Pin") {
            if (auiAuthPin.count == 0) {
                auiAuthenticationModeControl.selectedSegmentIndex = auiAuthenticationModesCount - 1
                auiSelectedAuthenticationMode = "None"
                auiSelectedAuthenticationModeIndex = auiAuthenticationModesCount - 1
                auiAuthModeConfigured = false
                
            } else {
                // pin set successfully
                self.showStatusView(pin: "pin", isOk: true, label: "Pin set successfully")
                
            }
            
        }
        
        print(auiSelectedAuthenticationMode, auiSelectedAuthenticationModeIndex)
        
    }
    
}
