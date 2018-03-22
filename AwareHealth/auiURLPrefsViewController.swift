//
//  auiURLPrefsViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/17/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import SCLAlertView
import WVCheckMark

var didManuallyReleasePrefs: Bool = false
var appCode: String = ""

class auiURLPrefsViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    let bgGradientLayer = CAGradientLayer()
    let rGradientLayer = CAGradientLayer()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var pin1: String = ""
    var pin2: String = ""
    var pin3: String = ""
    var pin4: String = ""
    var pin5: String = ""
    
    @IBOutlet weak var auiTopRule: UIView!
    @IBOutlet weak var auiDigitOne: UITextField!
    @IBOutlet weak var auiDigitTwo: UITextField!
    @IBOutlet weak var auiDigitThree: UITextField!
    @IBOutlet weak var auiDigitFour: UITextField!
    @IBOutlet weak var auiDigitFive: UITextField!
    @IBOutlet weak var auiKeyTextBlock: UITextView!
    @IBOutlet weak var auiNoKeyButton: UIButton!
    @IBOutlet weak var auiModeStatusView: UIView!
    @IBOutlet weak var auiModeStatusCheckmark: WVCheckMark!
    @IBOutlet weak var auiModeStatusLabel: UILabel!
    @IBOutlet weak var auiChangeAppKeyButton: auiRoundedButton!
    
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
        
        // delegates
        self.auiDigitOne.delegate = self
        self.auiDigitTwo.delegate = self
        self.auiDigitThree.delegate = self
        self.auiDigitFour.delegate = self
        self.auiDigitFive.delegate = self
        
        // no scroll please
        auiKeyTextBlock.isScrollEnabled = false
        
        // fill digits
        if (appKeyString.count == 5) {
            let mChars = Array(appKeyString)
            auiDigitOne.text = String(mChars[0])
            auiDigitTwo.text = String(mChars[1])
            auiDigitThree.text = String(mChars[2])
            auiDigitFour.text = String(mChars[3])
            auiDigitFive.text = String(mChars[4])
            appCode = appKeyString
            
        }
        
        // add swipe recognizers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // if app is authorized, prepare to show the ok config screen
        if (appKeyString != "") { self.hideAppKeyControls() }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (appKeyString != "") {
            self.hideAppKeyControls()
            self.showStatusView()
            
        } else {
            self.hideStatusView()
            self.showAppKeyControls()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    class func didCancelManually() -> Bool {
        return didManuallyReleasePrefs
        
    }
    
    func hideAppKeyControls() {
        // hide the appKey entry controls
        auiDigitOne.isHidden = true
        auiDigitTwo.isHidden = true
        auiDigitThree.isHidden = true
        auiDigitFour.isHidden = true
        auiDigitFive.isHidden = true
        auiNoKeyButton.isHidden = true
        
    }
    
    func showAppKeyControls() {
        // show the appKey entry controls
        auiDigitOne.isHidden = false
        auiDigitTwo.isHidden = false
        auiDigitThree.isHidden = false
        auiDigitFour.isHidden = false
        auiDigitFive.isHidden = false
        auiNoKeyButton.isHidden = false
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 1
        
    }
    
    @IBAction func auiCancelPrefs(_ sender: UIButton) {
        didManuallyReleasePrefs = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func auiDigitOne(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitOneStartEdit(_ sender: UITextField) {
   
    }
    
    @IBAction func auiDigitOneEditChanged(_ sender: UITextField) {
        let sCount = sender.text!.count
        if (sCount < 1) {
            
        } else {
            impactGenerator.impactOccurred()
            auiDigitTwo.becomeFirstResponder()
            
        }
        
        pin1 = sender.text!
        
    }
    
    @IBAction func auiDigitTwo(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitTwoStartEdit(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitTwoEditChanged(_ sender: UITextField) {
        let sCount = sender.text!.count
        if (sCount < 1) {
            if (pin2 == "") {
                auiDigitOne.becomeFirstResponder()
                
            }
            
        } else {
            impactGenerator.impactOccurred()
            auiDigitThree.becomeFirstResponder()
            
        }
        
        pin2 = sender.text!
        
    }
    
    @IBAction func auiDigitThree(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitThreeStartEdit(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitThreeEditChanged(_ sender: UITextField) {
        let sCount = sender.text!.count
        if (sCount < 1) {
            if (pin3 == "") {
                auiDigitTwo.becomeFirstResponder()
                
            }
            
        } else {
            impactGenerator.impactOccurred()
            auiDigitFour.becomeFirstResponder()
            
        }
        
        pin3 = sender.text!
        
    }
    
    @IBAction func auiDigitFour(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitFourStartEdit(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitFourEditChanged(_ sender: UITextField) {
        let sCount = sender.text!.count
        if (sCount < 1) {
            if (pin4 == "") {
                auiDigitFour.becomeFirstResponder()
                
            }
            
        } else {
            impactGenerator.impactOccurred()
            auiDigitFive.becomeFirstResponder()
            
        }
        
        pin4 = sender.text!
        
    }
    
    @IBAction func auiDigitFive(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitFiveStartEdit(_ sender: UITextField) {
        
    }
    
    @IBAction func auiDigitFiveEditChanged(_ sender: UITextField) {
        let sCount = sender.text!.count
        if (sCount < 1) {
            if (pin5 == "") {
                auiDigitFour.becomeFirstResponder()
                
            }
            
        } else {
            impactGenerator.impactOccurred()
            auiDigitFive.resignFirstResponder()
            triggerPrimaryURLGet()
        }
        
        pin5 = sender.text!
        
    }
    
    @IBAction func auiNextView(_ sender: UIButton) {
        if (appCode.count >= 5 && didGetAppIdentity) {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auiCredentialsPrefs") as! auiCredentialsPrefsViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        } else {
            if appCode.count >= 5 {
                triggerPrimaryURLGet()
                
            } else {
                auiDigitOne.shake()
                auiDigitTwo.shake()
                auiDigitThree.shake()
                auiDigitFour.shake()
                auiDigitFive.shake()
                
            }
            
        }
        
    }
    
    @objc func triggerPrimaryURLGet() {
        let oController = self
        let oCode = "\(auiDigitOne.text ?? "0")\(auiDigitTwo.text ?? "0")\(auiDigitThree.text ?? "0")\(auiDigitFour.text ?? "0")\(auiDigitFive.text ?? "0")"
        
        // if it is fully rendered get the code data, otherwise err
        if (oCode.count >= 5) {
            appCode = oCode
            oController.obtainPrimaryURL(mCode: oCode)
            
        } else {
            auiDigitOne.shake()
            auiDigitTwo.shake()
            auiDigitThree.shake()
            auiDigitFour.shake()
            auiDigitFive.shake()
            
        }
        
    }
    
    @IBAction func auiChangeAppKey(_ sender: auiRoundedButton) {
        // change the defined appkey
        pin1 = ""
        pin2 = ""
        pin3 = ""
        pin4 = ""
        pin5 = ""
        auiDigitOne.text = ""
        auiDigitTwo.text = ""
        auiDigitThree.text = ""
        auiDigitFour.text = ""
        auiDigitFive.text = ""
        self.hideStatusView()
        self.showAppKeyControls()
        auiDigitOne.becomeFirstResponder()
        
    }
    
    func obtainPrimaryURL(mCode: String) {
        let rString = "http://awarepoint.mytwiml.com/api/getSiteByKey.php?appkey=" + mCode
        Alamofire.request(rString).responseJSON { response in
            if let result = response.result.value {
                let json = JSON(result)
                if(json["message"] == "ok") {
                    didGetAppIdentity = true
                    let mURL: String = json["awhURL"].string!
                    let mAPI: String = json["apiURL"].string!
                    let mAppName: String = json["appName"].string!
                    let mAppAuthorized: String = json["isAuthorized"].string!
                    let moAuthURL: String = json["oAuthURL"].string!
                    let moAuthID: String = json["oAuthID"].string!
                    let moAuthSecret: String = json["oAuthSecret"].string!
                    let moAuthAPIKey: String = json["oAuthAPIKey"].string!
                    let moAuthGrantType: String = json["oAuthGrantType"].string!
                    var isAuthorized: Bool = false
                    if (mAppAuthorized == "1") {
                        isAuthorized = true
                        
                    }
                    
                    // save data
                    let baseState = auiCoreDataHandler.saveBaseURL(baseURL: mURL)
                    if (!baseState) {
                        _ = auiCoreDataHandler.saveBaseURL(baseURL: "")
                        
                    }
                    
                    let apiState = auiCoreDataHandler.saveAPIURL(apiURL: mAPI)
                    if (!apiState) {
                        _ = auiCoreDataHandler.saveAPIURL(apiURL: "")
                        
                    }
                    
                    let identityState = auiCoreDataHandler.saveAppIdentity(appName: mAppName, appKey: mCode, appAuthorized: isAuthorized)
                    if (!identityState) {
                        _ = auiCoreDataHandler.saveAppIdentity(appName: "", appKey: "", appAuthorized: false)
                        
                    }
                    
                    let endpointDataState = auiCoreDataHandler.saveAppEndpointData(apiURL: mAPI, oAuthURL: moAuthURL, oAuthID: moAuthID, oAuthSecret: moAuthSecret, oAuthAPIKey: moAuthAPIKey, oAuthGrantType: moAuthGrantType)
                    if (!endpointDataState) {
                        _ = auiCoreDataHandler.saveAppEndpointData(apiURL: "", oAuthURL: "", oAuthID: "", oAuthSecret: "", oAuthAPIKey: "", oAuthGrantType: "")
                        
                    }
                    
                    self.view.endEditing(true)
                    
                    if (isAuthorized) {
                        // display a nice success alert
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false
                        )
                        
                        let successView = SCLAlertView(appearance: appearance)
                        
                        successView.addButton("Next") {
                            self.auiPrefsGoNext()
                            
                        }
                        
                        successView.showSuccess("Success", subTitle: "You've successfully connected to \(mAppName).  Next, you will specify your user credentials.")
                        
                        // also provide haptic feedback
                        self.feedbackGenerator.notificationOccurred(.success)
                        
                    } else {
                        // failure
                        let failureView = SCLAlertView()
                        failureView.addButton("Get Help") {
                            self.presentAppKeyHelp()
                            
                        }
                        
                        failureView.showError("Unauthorized", subTitle: "Your organization does not have a current license for you to use \(mAppName).  Please contact your help desk or IT departement for further assistance, or 'Get Help'.", closeButtonTitle: "OK")
                        
                        // also provide haptic feedback
                        self.feedbackGenerator.notificationOccurred(.error)
                        
                    }
                    
                } else {
                    // handle a return error
                    didGetAppIdentity = false
                    self.auiDigitOne.shake()
                    self.auiDigitTwo.shake()
                    self.auiDigitThree.shake()
                    self.auiDigitFour.shake()
                    self.auiDigitFive.shake()
                    
                }
                
            }
            
        }
        
    }
    
    func auiPrefsGoNext() {
        // go to next view
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auiCredentialsPrefs") as! auiCredentialsPrefsViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    func presentAppKeyHelp() {
        // manually trigger segue for key help
        performSegue(withIdentifier: "auiKeyHelperSegue", sender: nil)
        
    }

}
