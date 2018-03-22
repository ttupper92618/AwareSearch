//
//  ViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 12/22/17.
//  Copyright © 2017 Awarepoint Inc. All rights reserved.
//

import UIKit
import WebKit
import CoreBluetooth
import CoreMotion
import CoreLocation
import AwpLocationEngine
import MessageUI
import SVProgressHUD
import Alamofire
import SwiftyJSON
import LocalAuthentication
import SCLAlertView
import SwiftKeychainWrapper
import EasyTipView
import WKWebViewJavascriptBridge

// MLE related
var totalBeacons: Int = 0
var totalFloors: Int = 0
var totalRooms: Int = 0
var totalRegions: Int = 0
var totalAlgorithm: Int = 0
var floorConfigList = [FloorConfig]()
var beaconConfigList = [BeaconConfig]()
var regionConfigList = [RegionConfig]()
var roomConfigList = [RoomConfig]()
var algorithmConfigList = [AlgorithmConfig]()
var configManager : ConfigManager? = nil
var mobileInputCore : MobileInputCore? = nil
var syncConfigData: SyncConfigData? = nil
var centralManager: CBCentralManager? = nil
let locationChangeListener = LocationChangeListener()
let bluetoothQueue = DispatchQueue(label: "ble_devices_queue", attributes: [])
var readyToScan: Bool = false
var MLEInitialized: Bool = false

// URL's, auth state, and config
var primaryURL: String = ""
var primaryAPIURL: String = ""
var appName: String = ""
var appKeyString: String = ""
var appIsAuthorized: Bool = true
var appIsConfigured: Bool = false
var oAuthURL: String = ""
var oAuthID: String = ""
var oAuthSecret: String = ""
var oAuthAPIKey: String = ""
var oAuthGrantType: String = ""
var didGetAppIdentity: Bool = false
var auiLoadErrorState: Int = 0
var auiOAuthOK: Bool = true
var auiOAuthAccessToken: String = ""
var auiOAuthTokenType: String = ""
var auiOAuthExpiresInSeconds: Int = 0
var auiOAuthRefreshToken: String = ""
var auiOAuthEnvironment: String = ""
var auiSynchSuccessful: Bool = false
var auiSynchInProgress: Bool = true
var auiRawFloorData: JSON = ""
var auiRawAreaData: JSON = ""
var auiRawRoomData: JSON = ""
var auiRawBeaconData: JSON = ""
var auiRawAlgorithmData: JSON = ""
var auiAuthenticationMode: BiometricType = .none
var auiAuthenticationModesCount: Int = 3
var auiSelectedAuthenticationMode: String = "none"
var auiSelectedAuthenticationModeIndex: Int = 2
var auiAuthModeConfigured: Bool = false
var auiAuthPin: [Int] = []
var auiAllowForceTouch: Bool = false
var currentSessionAuthenticated: Bool = false
var primaryAuthenticationFailed: Bool = false
var auiTipView: EasyTipView? = nil
var JSBridge: WKWebViewJavascriptBridge? = nil
let auiKeyserverOAuthURL: String = "https://system-oauth.dev.awarepoint.com/oauth/token"
let auiKeyserverOAuthClientID: String = "AWPSystemAdmin"
let auiKeyserverOAuthClientSecret: String = "UUKs7MC8v6JSrpg9s8aC"
let auiKeyserverOAuthAPIKey: String = "apikey%3DK3e0vdae938120da3Edl8zqEWQS83cqi301dsc0kj9321dfqDv91FAOi0c34GrezQ9C3"
let auiKeyserverOAuthGrantType: String = "client_credentials"
let auiKeyserverURL: String = "https://api.dev.awarepoint.com/api/applicationkey?getbyapplicationkey="
var auiKeyserverOAuthOK: Bool = true
var auiKeyserverOAuthAccessToken: String = ""
var auiKeyserverOAuthTokenType: String = ""
var auiKeyserverOAuthExpiresInSeconds: Int = 0
var auiKeyserverOAuthRefreshToken: String = ""
var auiUID: String = ""
var auiPass: String = ""
var auiRememberUser: Bool = false
var auiSessionCount: Int = 0
var auiPrevMovementState: Bool = false
var auiInMotion: Bool = false
let auiAuthenticationContext = LAContext()

// View
var auiWebView: WKWebView? = nil

// Biometric mode
enum BiometricType: String {
    case none = "none"
    case TouchID = "TouchID"
    case FaceID = "FaceID"
    
}

class ViewController: UIViewController, CBCentralManagerDelegate, WKNavigationDelegate {

    @IBOutlet weak var auiWebView: WKWebView!
    @IBOutlet weak var auiLoadFailView: UIView!
    @IBOutlet weak var auiUnauthorizedView: UIView!
    @IBOutlet weak var auiNoNetworkView: UIView!
    @IBOutlet weak var auiSetupNeededView: UIView!
    @IBOutlet weak var auiBarActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var auiInfoView: UIView!
    @IBOutlet weak var auiPrimaryView: UIView!
    
    // beacon support
    //var configManager : ConfigManager? = nil
    //var mobileInputCore : MobileInputCore? = nil
    var motionManager : CMMotionManager? = nil
    //var syncConfigData: SyncConfigData? = nil
    var bleScanAvailable = false
    var centralManager: CBCentralManager?
    var restClient = RestClient()
    var token: String? = nil
    var environmentSelected: String? = nil
    var beaconsListening = [(String, Double)]()
    var outputListening = [String]()
    var beaconCount = 0
    var accelerometerX: Double = 0
    var accelerometerY: Double = 0
    var accelerometerZ: Double = 0
    var currentTime: Int64 = Int64( Date().timeIntervalSince1970 * 1000 )
    var awareHealthURL = ["http://api.dev.awarepoint.com/", "https://awarehealthapi.ahealth.awarepoint.com/"]
    let logger = LoggerLocationEngine()
    // let locationChangeListener = LocationChangeListener()
    let bluetoothQueue = DispatchQueue(label: "ble_devices_queue", attributes: [])
    
    // aui view
    var mURLSet: Bool = false
    var mURL: String = ""
    let config = URLSessionConfiguration.default
    var auiSynchStatusTimer = Timer()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    let keyServerOAuth = auiKeyServer()
    
    // reachability
    var reachabilityObj = MyReachability.networkReachabilityForInternetConnection()
    var isReachable: Bool = false
    
    // --- web view functionality ----
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
        if (auiOAuthOK) { hideNetworkLoadFailedView() }
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        SVProgressHUD.show()
        if (auiOAuthOK) { hideNetworkLoadFailedView() }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        SVProgressHUD.dismiss()
        showNetworkLoadFailedView()
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        SVProgressHUD.dismiss()
        showNetworkLoadFailedView()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
        if (auiOAuthOK) { hideNetworkLoadFailedView() }
        
        // attach the JS bridge
        auiJSBridge.setup()
        
        // check for auth state
        self.checkLoginState()
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        SVProgressHUD.dismiss()
        if (auiOAuthOK) { hideNetworkLoadFailedView() }
        
    }
    
    // --- base functions ---
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show network indicaton
        SVProgressHUD.show()
        
        // attempt to get a keyserver oAuth token
        keyServerOAuth.obtainKeyServerData()
        
        // beacon support
        centralManager = CBCentralManager(delegate: self, queue: bluetoothQueue)
        locationChangeListener.notificationCenter.addObserver(self, selector: #selector(ViewController.notifyLocationOutputChange), name: Notification.Name(rawValue: locationChangeListener.notificationCenterName), object: nil)
        self.motionManager = CMMotionManager()
        self.motionManager!.startAccelerometerUpdates()
        
        // reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName), object: nil)
        _ = reachabilityObj?.startNotifier()
        
        // give the view a delegate
        auiWebView.navigationDelegate = self
        
        // setup the config error view
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        auiSetupNeededView.addGestureRecognizer(tap)
        auiSetupNeededView.isUserInteractionEnabled = true
        
        // see if we have force touch
        auiAllowForceTouch = self.traitCollection.forceTouchCapability == .available
        
        // start looking for synchronization state
        self.startSynchScanning()
        
        // bar actvity indicator setup
        auiBarActivityIndicator.hidesWhenStopped = true
        NotificationCenter.default.addObserver(self, selector: #selector(showBarActivityIndicator), name:NSNotification.Name(rawValue: "showBarActivityIndicator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBarActivityIndicator), name:NSNotification.Name(rawValue: "hideBarActivityIndicator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkLoginState), name:NSNotification.Name(rawValue: "checkLoginState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startSynchScanning), name:NSNotification.Name(rawValue: "startSynchScanning"), object: nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.showSynchPrompt))
        self.auiInfoView.addGestureRecognizer(gesture)
        
        // set up JS bridge
        self.configJSBridge()
        
        // start tracking motion
        // self.startMotionManager()

    }
    
    deinit{
        centralManager!.stopScan()
        
        // reachability
        NotificationCenter.default.removeObserver(self)
        reachabilityObj?.stopNotifier()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reachability
        checkReachability()
        checkAccess()
        checkAuthMode()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // motion manager
        
        // check for a load URL
        let mBaseURL = auiCoreDataHandler.getBaseURL()
        let mApiURL = auiCoreDataHandler.getAPIURL()
        let mAppIdentity = auiCoreDataHandler.getAppIdentity()
        let mAppEndpoints = auiCoreDataHandler.getAppEndpointData()
        let size = mBaseURL!.count
        
        if(size > 0) {
            // hide config warnings
            if (auiOAuthOK) { hideConfigurationRequiredView() }
            
            // push globals
            appIsConfigured = true
            primaryURL = mBaseURL!.first!.auiBaseURL!
            primaryAPIURL = mApiURL!.first!.apiURL!
            appName = mAppIdentity!.first!.auiAppName!
            appKeyString = mAppIdentity!.first!.auiAppKey!
            oAuthURL = mAppEndpoints!.first!.oAuthURL!
            oAuthID = mAppEndpoints!.first!.oAuthID!
            oAuthSecret = mAppEndpoints!.first!.oAuthSecret!
            oAuthAPIKey = mAppEndpoints!.first!.oAuthAPIKey!
            oAuthGrantType = mAppEndpoints!.first!.oAuthGrantType!
            appIsAuthorized = false
            
            if (mAppIdentity!.first!.auiAppAuthorized) {
                appIsAuthorized = mAppIdentity!.first!.auiAppAuthorized
                
            } else {
                appIsAuthorized = false
                
            }
            
            if (appIsAuthorized) {
                // make sure that all warning views are hidden
                if (auiOAuthOK) { hideWarningView() }
                
                // check login state
                // self.checkLoginState()
                
                // get the existing UID and password
                auiUID = KeychainWrapper.standard.string(forKey: "userName")!
                auiPass = KeychainWrapper.standard.string(forKey: "password")!
                
                // extend usergent
                let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")! + " auiMode/auiHybrid auiPlatform/IOS auiKey/" + appKeyString
                auiWebView.customUserAgent = userAgent
                
                // load the URL
                mURL = mBaseURL!.first!.auiBaseURL!
                
                print("desired system URL = \(mURL)")
                
                let url:URL = URL(string: mURL)!
                var urlRequest:URLRequest = URLRequest(url: url)
                urlRequest.timeoutInterval = 30.0
                auiWebView.load(urlRequest)
                
                // fetch token if needed
                auiDataChannel.getOAuthToken()
                
            } else {
                // show a no access view, or a config view, as needed
                if (appName == "") {
                    showConfigurationRequiredView()
                    
                } else {
                    showNoAccessView()
                    
                }
                
            }
            
            didGetAppIdentity = true
            
        } else {
            // The app is not configured, so set the main view and move to prefs
            
            // fisrt, lets make sure keystore is zeroed
            let _: Bool = KeychainWrapper.standard.removeObject(forKey: "userName")
            let _: Bool = KeychainWrapper.standard.removeObject(forKey: "password")
            
            showConfigurationRequiredView()
            if (!didManuallyReleasePrefs && isReachable) { performSegue(withIdentifier: "auiPrefs", sender: nil) }
            
        }
        
        if(readyToScan) {
            print("scanning: \(self.centralManager!.isScanning)")
            if (!self.centralManager!.isScanning) {
                print("start scanning")
                self.startScanning()
                
            }
            
        }
        
    }
    
    func configJSBridge() {
        // configure the JS bridgs'
        
        // hook bridge to the view
        JSBridge = WKWebViewJavascriptBridge(webView: auiWebView)
        
    }
    
    @objc func checkLoginState() {
        // check the current login state
        if (appIsConfigured && appIsAuthorized) {
            if (!currentSessionAuthenticated) {
                // no authenticted session in place, so show login view
                performSegue(withIdentifier: "auiShowLogin", sender: nil)
                
            }
            
        }
        
    }
    
    func checkAccess() {
        if(!appIsAuthorized) {
            showNoAccessView()
            
        }
        
    }
    
    func checkAuthMode() {
        // determine what auth mode is configured, if any
        let mAuthModeData = auiCoreDataHandler.getAuthModeData()
        // print(mAuthModeData!.first!.auiAuthModeDefined)
        
        let size = mAuthModeData!.count
        if (size > 0) {
            auiAuthModeConfigured = mAuthModeData!.first!.auiAuthModeDefined
            auiSelectedAuthenticationMode = mAuthModeData!.first!.auiSelectedAuthMode!
            auiSelectedAuthenticationModeIndex = Int(mAuthModeData!.first!.auiSelectedAuthModeIndex)
            auiAuthPin = mAuthModeData!.first!.auiAuthPin!
            self.setAuthBiometricType(aType: auiSelectedAuthenticationMode)
            
        }
        
    }
    
    func setAuthBiometricType(aType: String) {
        // set the biometric type based on the saved type
        if(aType == "FaceID" || aType == "TouchID") {
            switch aType {
                case "FaceID":
                    auiAuthenticationMode = .FaceID
                
                case "TouchID":
                    auiAuthenticationMode = .TouchID
                
                default:
                    return
                
            }
            
        }

    }
    
    @objc func checkSynchStatus() {
        // check synch status.  If synched, notify and begun scanning
        if (readyToScan) {
            auiSynchStatusTimer.invalidate()
            self.startScanning()
     
        } else {
            // print("check synch status")
            
        }
        
    }
    
    @objc func startSynchScanning() {
        // start a synchronization timer
        if (!auiSynchSuccessful) {
            // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
            auiSynchStatusTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.checkSynchStatus), userInfo: nil, repeats: true)
            
        }
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "auiPrefs", sender: nil)
        
    }
    
    @objc func showSynchPrompt() {
        if (auiBarActivityIndicator.isAnimating) {
            // display a tip
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont(name: "Helvetica", size: 14)!
            preferences.drawing.foregroundColor = UIColor.white
            preferences.drawing.backgroundColor = UIColor(hue: 0.9972, saturation: 0, brightness: 0.24, alpha: 1.0)
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
            
            if (auiTipView != nil) {
                auiTipView?.dismiss()
                
            }
            
            // present some haptic feedback
            feedbackGenerator.notificationOccurred(.warning)
            
            // now present the view
            auiTipView = EasyTipView(text: "\(appName) is synching configuration data.  You can use the application during this process, but \(appName) will not be able to determine your location.", preferences: preferences)
            auiTipView?.show(forView: auiInfoView, withinSuperview: auiPrimaryView)
            
            // set a timer to dismiss the view
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0, execute: {
                self.removeSynchPrompt()
                
            })
            
        } else {
            if (auiTipView != nil) {
                auiTipView?.dismiss()
                
            }
        }
        
    }
    
    func removeSynchPrompt() {
        if (auiTipView != nil) {
            auiTipView?.dismiss()
            
        }
        
    }
    
    // --- prefs ----
    @IBAction func auiShowPrefs(_ sender: UIButton) {
        didManuallyReleasePrefs = false;
        performSegue(withIdentifier: "auiPrefs", sender: nil)
        
    }
    
    func auiGenericMessage (iTitle: String, iMessage: String) {
        let alertController = UIAlertController(title: iTitle, message: iMessage, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func obtainOAuthToken () {
        // get oauth data
        var getToken: Bool = false
        let eOAuthData = auiCoreDataHandler.getOAuthData()
        
        if (eOAuthData?.count != 0) {
            let lastOAuthSuccessful = eOAuthData!.first!.oAuthSuccessful
            let lastOAuthDate = eOAuthData!.first!.lastOAuthDate
            let allowedDuration = eOAuthData!.first!.duration
            let currentDate = Date()
            let elapsedSeconds = currentDate.timeIntervalSince(lastOAuthDate!)
            let fallOffSeconds = allowedDuration - 3600
            
            if (!lastOAuthSuccessful || elapsedSeconds > fallOffSeconds ) {
                getToken = true
                
            } else {
                // poke the oauth data where we need it to go
                auiOAuthAccessToken = eOAuthData!.first!.token!
                auiOAuthExpiresInSeconds = Int(eOAuthData!.first!.duration)
                auiOAuthRefreshToken = eOAuthData!.first!.refreshToken!
                auiOAuthTokenType = eOAuthData!.first!.type!
                auiOAuthEnvironment = eOAuthData!.first!.environment!
                
                // synch data if needed
                auiDataChannel.performSynchOperations()
                
            }
            
        } else {
            getToken = true
            
        }
        
        if(getToken) {
            let myClient = RestClient()
            let myJSON = myClient.postOAuthRequest()
            
            if (myJSON != nil) {
                auiOAuthAccessToken = (myJSON?.accessToken)!
                auiOAuthExpiresInSeconds = (myJSON?.expiresInSeconds)!
                auiOAuthRefreshToken = (myJSON?.refreshToken)!
                auiOAuthTokenType = (myJSON?.tokenType)!
                auiOAuthEnvironment = (myJSON?.environment)!
                
                // save the token data
                _ = auiCoreDataHandler.saveOAuthData(accessToken: auiOAuthAccessToken, refreshToken: auiOAuthRefreshToken, tokenType: auiOAuthTokenType, environment: auiOAuthEnvironment, expirationPeriod: auiOAuthExpiresInSeconds, oAuthSuccess: true)
                
                auiDataChannel.performSynchOperations()
            
            }
            
        }
        
    }
    
    // --- reachability ----
    func checkReachability() {
        guard let netConnect =  reachabilityObj else {
            return
        }
        
        if netConnect.isReachable {
            isReachable = true
            if (auiOAuthOK) { hideWarningView() }
            
            // check access also
            checkAccess()
            
        } else {
            // we want to show a network warning.
            isReachable = false
            showWarningView()
            
        }
        
    }
    
    func showWarningView() {
        auiWebView.isHidden = true
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = false
        
    }
    
    func hideWarningView() {
        auiWebView.isHidden = false
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    func showNetworkLoadFailedView() {
        auiWebView.isHidden = true
        
        auiLoadFailView.isHidden = false
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    func hideNetworkLoadFailedView() {
        auiWebView.isHidden = false
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    func showNoAccessView() {
        auiWebView.isHidden = true
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = false
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    func hideNoAccessView() {
        auiWebView.isHidden = false
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    func showConfigurationRequiredView() {
        auiWebView.isHidden = true
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = false
        auiNoNetworkView.isHidden = true
        
    }
    
    func hideConfigurationRequiredView() {
        auiWebView.isHidden = false
        
        auiLoadFailView.isHidden = true
        auiUnauthorizedView.isHidden = true
        auiSetupNeededView.isHidden = true
        auiNoNetworkView.isHidden = true
        
    }
    
    @objc func reachabilityDidChange(_ notification: Notification) {
        checkReachability()
        
    }
    
    // --- motion suport ----
    
    
    // --- beacon support ----
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BLE is off")
            bleScanAvailable = false
            
        case .poweredOn:
            print("BLE is on")
            bleScanAvailable = true
            
        default:
            print(central.state)
            
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // FIX ME - Temp Solution After a few seconds scan slow down and takes more time to detect devices, restarting the process fix the issue.
        let thisTime: Int64 = Int64( Date().timeIntervalSince1970 * 1000 )
        
        if ( thisTime - currentTime ) > Int64(10000){
            restartScanning()
            currentTime = thisTime
        }
        
        if mobileInputCore != nil{
            let beaconPid = decryptPid(advertisementData as [String : AnyObject])
            let timestamp = Int64( Date().timeIntervalSince1970 * 1000 )
            
            if beaconPid != 0 && Double(truncating: RSSI) < 0 {
                accelerometerX = 0
                accelerometerY = 0
                accelerometerZ = 0
                
                if let accelerometerData = motionManager!.accelerometerData{
                    accelerometerX = accelerometerData.acceleration.x
                    accelerometerY = accelerometerData.acceleration.y
                    accelerometerZ = accelerometerData.acceleration.z
                }
                
                let beaconString = String(beaconPid, radix: 16).uppercased()
                
                if configManager != nil {
                    
                    if configManager!.beaconsConfig[beaconPid] != nil{
                        
                        mobileInputCore!.publish(0, beaconPid: beaconPid, rssi: Double(truncating: RSSI), timestamp: timestamp, inMotion: true, accelerometerX: accelerometerX, accelerometerY: accelerometerY, accelerometerZ: accelerometerZ)
                        
                        DispatchQueue.main.async(execute: {
                            self.beaconsListening.append((beaconString, Double(truncating: RSSI)) )
                            
                            if self.beaconsListening.count > 20{
                                self.beaconsListening.removeAll()
                                
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func decryptPid(_ advertisementData: [String : AnyObject])-> Int{
        var beaconPid : Int = 0
        let manufacturerData = advertisementData["kCBAdvDataManufacturerData"]
        
        if (manufacturerData != nil) {
            let manufacturerDataNsData = manufacturerData as! Data
            
            if (manufacturerDataNsData.count == 10) { //awarepoint format always 10 bytes
                var tenbytes = [UInt8](repeating: 0, count: 10)
                (manufacturerDataNsData as NSData).getBytes(&tenbytes, length: manufacturerDataNsData.count)
                
                // awarepoint identifier is 0x3c02
                if (tenbytes[0] == 0x3c && tenbytes[1] == 0x02) {
                    // construct the pid, by adding prepending 0x9000 to 3 bytes from the part of the manufacturer field that encodes the beacon id
                    var bytes : [UInt8] = [0x90,0x00,0x00,0x00,0x00]
                    bytes[2...4] = tenbytes[6...8]
                    
                    for byte in bytes {
                        beaconPid = beaconPid<<8
                        beaconPid = beaconPid | Int(byte)
                        
                    }
                    
                }
                
            }
            
        }
        
        return beaconPid
        
    }
    
    @objc internal func notifyLocationOutputChange(_ notification: Notification) {
        if let userInfoNotification = notification.userInfo{
            
            if let locationOutputNotification = userInfoNotification["locationOutput"] as? [String:AnyObject]{
                let productId = locationOutputNotification["productId"] as! Int
                let fullLocationName = locationOutputNotification["fullLocationName"] as! String
                let campusId = locationOutputNotification["campusId"] as! Int
                let buildingId = locationOutputNotification["buildingId"] as! Int
                let floorId = locationOutputNotification["floorId"] as! Int
                let areaId = locationOutputNotification["areaId"] as! Int
                let roomId = locationOutputNotification["roomId"] as! Int
                let subroomId = locationOutputNotification["subroomId"] as! Int
                let x = locationOutputNotification["x"] as! Double
                let y = locationOutputNotification["y"] as! Double
                let latitude = locationOutputNotification["latitude"] as! Double
                let longitude = locationOutputNotification["longitude"] as! Double
                let inMotion = locationOutputNotification["inMotion"] as! Bool
                let msgReceiveTime = Int64(locationOutputNotification["msgReceiveTime"] as! Int)
                let locationOutputTime = Int64(locationOutputNotification["locationOutputTime"] as! Int)
                let locationOutput = LocationOutput(productId: productId, msgReceiveTime: msgReceiveTime, locationOutputTime: locationOutputTime, fullLocationName: fullLocationName, campusId: campusId, buildingId: buildingId, floorId: floorId, areaId: areaId, roomId: roomId, subroomId: subroomId, x: x, y: y, latitude: latitude, longitude: longitude, inMotion: inMotion)
                
                auiJSBridge.passLocationChangeEvent(mEvent: locationOutputNotification)
                
                if(inMotion == true) {
                    auiInMotion = true
                    
                } else {
                    if (auiInMotion != inMotion) {
                        auiJSBridge.passMovementStoppedEvent()
                        auiInMotion = false
                        
                    }
                    
                }
                
                DispatchQueue.main.async(execute: {
                    
                    if self.outputListening.count > 2{
                        self.outputListening.removeAll()
                        //self.txtOutput.text = ""
                    }
                    
                    _ = locationOutput.fullLocationName + " | x:" +  String(x) + " | y:" + String(y) + " | lat:" + String(latitude) + " | long:" + String(longitude)
                    
                    //self.txtOutput.text = output + "\r\n ***************\r\n" + self.txtOutput.text
                    self.outputListening.append(fullLocationName)
                    
                })
                
            }
            
        }
        
    }
    
    internal func startScanning(){
        self.bluetoothQueue.async(execute: { self.centralManager!.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true]) })
        
    }
    
    internal func stopScanning(){
        self.bluetoothQueue.async(execute: { self.centralManager!.stopScan() })

    }
    
    internal func restartScanning(){
        if self.centralManager!.isScanning{
            stopScanning()
        }
        
        startScanning()
        
    }
    
    func showAlertDialog(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func showBarActivityIndicator() {
        auiInfoView.isHidden = false
        auiBarActivityIndicator.startAnimating()
        
    }
    
    @objc func hideBarActivityIndicator() {
        auiBarActivityIndicator.stopAnimating()
        auiInfoView.isHidden = true
        
        // if there is a synch tip, dismiss it
        if (auiTipView != nil) {
            auiTipView?.dismiss()
            
        }
        
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) {
        self.showSynchPrompt()
        
    }
    
}

// --- protocols ---

// --- utilities ----
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


// --- beacon extension ----
extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                    
                })
                
            }
            
        }
        
    }
    
}

// --- other extensions ----
extension UITextContentType {
    public static let unspecified = UITextContentType("unspecified")
}

public extension UIView {
    func shake(count : Float = 3,for duration : TimeInterval = 0.3,withTranslation translation : Float = -5) {
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation
        layer.add(animation, forKey: "shake")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
    }
    
}
