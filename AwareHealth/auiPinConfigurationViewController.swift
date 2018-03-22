//
//  auiPinConfigurationViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 2/26/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class auiPinConfigurationViewController: UIViewController {
    let rGradientLayer = CAGradientLayer()
    var maxBulletsOrdinal = 3
    var currentBullet: Int = 0
    var auiTempPin: [Int] = []
    var auiTempPinVerification: [Int] = []
    var inValidation: Bool = false
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    @IBOutlet var auiPrimaryPinView: UIView!
    @IBOutlet weak var auiPinPanelView: UIView!
    @IBOutlet weak var auiPinEntryDone: UIButton!
    @IBOutlet weak var auiCancelPinEntry: UIButton!
    @IBOutlet weak var auiTopRule: UIView!
    @IBOutlet weak var auiPinBulletOne: auiPinPadBullet!
    @IBOutlet weak var auiPinPadBulletTwo: auiPinPadBullet!
    @IBOutlet weak var auiPinPadBulletThree: auiPinPadBullet!
    @IBOutlet weak var auiPinPadBulletFour: auiPinPadBullet!
    @IBOutlet weak var auiPinBulletView: UIView!
    @IBOutlet weak var auiPinEntryLabel: UILabel!
    @IBOutlet weak var auiBackspaceButton: UIButton!
    @IBOutlet weak var auiResetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // provide a blur
        view.backgroundColor = .clear
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            auiPrimaryPinView.insertSubview(blurEffectView, belowSubview: auiPinPanelView)
            
        }
        
        // set up the top rule
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
        
        // set the authPin to nothing
        auiAuthPin = []
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    
    func auiMarkPinBulletSelected(tBullet: Int) {
        // mark a pin as selected
        switch tBullet {
            case 0:
                auiPinBulletOne.setSelected()
            
            case 1:
                auiPinPadBulletTwo.setSelected()
            
            case 2:
                auiPinPadBulletThree.setSelected()
            
            case 3:
                auiPinPadBulletFour.setSelected()
            
            default:
                return
            
        }
        
    }
    
    func auiMarkPinBulletUnselected(tBullet: Int) {
        // mark a pin as unselected
        switch tBullet {
            case 0:
                auiPinBulletOne.setUnselected()
            
            case 1:
                auiPinPadBulletTwo.setUnselected()
            
            case 2:
                auiPinPadBulletThree.setUnselected()
            
            case 3:
                auiPinPadBulletFour.setUnselected()
            
            default:
                return
            
        }
        
    }
    
    func auiMarkAllPinBulletsUnselected() {
        // mark a pin as unselected
        for index in 0...maxBulletsOrdinal {
            auiMarkPinBulletUnselected(tBullet: index)
            currentBullet = 0
            
        }
        
    }
    
    func auiPrepForValidation() {
        // perform steps required for validation.
        auiPinEntryLabel.text = "Re-enter pin for validation..."
        auiMarkAllPinBulletsUnselected()
        
    }
    
    func auiPerformValidation() {
        // check the pins and make sure they match
        if (auiTempPin == auiTempPinVerification) {
            // success, pins match - save the pin to the global value
            auiAuthPin = auiTempPin
            
            // change the indicator and text
            auiCancelPinEntry.isHidden = true
            auiPinEntryLabel.text = "Success - pins match."
            
            // show an alert with a continuation action
            /* let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            
            let successView = SCLAlertView(appearance: appearance)
            
            successView.addButton("Done") {
                auiAuthModeConfigured = true
                self.pinSuccessReturn()
                
            }
            
            successView.showSuccess("Success", subTitle: "You've successfully provided a pin for authentication.") */
            
            auiAuthModeConfigured = true
            self.pinSuccessReturn()
            
        } else {
            // failure - try again
            auiPinEntryLabel.text = "Pins don't match - try again..."
            auiMarkAllPinBulletsUnselected()
            auiPinBulletView.shake()
            auiTempPin = []
            auiTempPinVerification = []
            inValidation = false
            
        }
        
    }
    
    func pinSuccessReturn() {
        _ = auiCoreDataHandler.saveAuthModeData(authModeDefined: true, authPin: auiAuthPin, authModeString: "Pin", authModeIndex: auiSelectedAuthenticationModeIndex)
        feedbackGenerator.notificationOccurred(.success)
        performSegue(withIdentifier: "unwindToParent", sender: self)
        
    }
    
    @IBAction func auiResetPinEntry(_ sender: UIButton) {
        if (auiTempPin.count > 0) {
            impactGenerator.impactOccurred()
            if (!inValidation) {
                auiMarkAllPinBulletsUnselected()
                auiTempPin = []
                
            } else {
                auiMarkAllPinBulletsUnselected()
                auiTempPinVerification = []
                
            }
            
        } else {
            auiBackspaceButton.alpha = 0.39
            auiResetButton.alpha = 0.39
            
        }
        
    }
    
    @IBAction func auiUndoEntry(_ sender: UIButton) {
        if (auiTempPin.count > 0) {
            impactGenerator.impactOccurred()
            if (!inValidation) {
                if ((currentBullet - 1) >= 0)  {
                    auiTempPin.remove(at: currentBullet - 1)
                    auiMarkPinBulletUnselected(tBullet: currentBullet - 1)
                    
                }
                
                if (currentBullet > 0) { currentBullet = currentBullet - 1 }
                
            } else {
                if ((currentBullet - 1) >= 0)  {
                    auiTempPinVerification.remove(at: currentBullet - 1)
                    auiMarkPinBulletUnselected(tBullet: currentBullet - 1)
                    
                }
                
                if (currentBullet > 0) { currentBullet = currentBullet - 1 }
                
            }
            
            
            
        } else {
            auiBackspaceButton.alpha = 0.39
            auiResetButton.alpha = 0.39
            
        }
        
        if (currentBullet <= 0)  {
            auiBackspaceButton.alpha = 0.39
            auiResetButton.alpha = 0.39
            
        }
        
    }
    
    @IBAction func cancelPinEntry(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToParent", sender: self)
        
    }
    
    @IBAction func pinEntryComplete(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToParent", sender: self)
        
    }
    
    @IBAction func auiHandlePinPadButtonClick(_ sender: auiPinPadButton) {
        if (!inValidation) {
            if(currentBullet <= 3) {
                auiTempPin.insert(sender.tag, at: currentBullet)
                auiMarkPinBulletSelected(tBullet: currentBullet)
                currentBullet = currentBullet + 1
                
            }
            
            if (currentBullet >= 4) {
                currentBullet = 0
                inValidation = true
                auiPrepForValidation()
                
            }
            
        } else {
            if (currentBullet <= 3) {
                auiTempPinVerification.insert(sender.tag, at: currentBullet)
                auiMarkPinBulletSelected(tBullet: currentBullet)
                currentBullet = currentBullet + 1
                
            }
            
            if (currentBullet >= 4) {
                auiPerformValidation()
                
            }
            
        }
        
        if (auiTempPin.count > 0) {
            auiBackspaceButton.alpha = 1.0
            auiResetButton.alpha = 1.0
            
        } else {
            auiBackspaceButton.alpha = 0.39
            auiResetButton.alpha = 0.39
            
        }
        
    }
    
}
