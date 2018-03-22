//
//  auiJSBridge.swift
//  AwareHealth
//
//  Created by Tom Tupper on 3/13/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import AwpLocationEngine

class auiJSBridge: NSObject {
    class func setup() {
        JSBridge?.register(handlerName: "testiOSCallback") { (paramters, callback) in
            print("testiOSCallback called: \(String(describing: paramters))")
            callback?("callback from IOS")
            
        }
        
        JSBridge?.register(handlerName: "auiSTSLoaded") { (paramters, callback) in
            print("STS loaded: \(String(describing: paramters))")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkLoginState"), object: nil)
            
        }
        
        JSBridge?.register(handlerName: "auiSTSLoginFailed") { (paramters, callback) in
            print("STS loaded failed: \(String(describing: paramters))")
            currentSessionAuthenticated = false
            primaryAuthenticationFailed = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkLoginState"), object: nil)
            
        }
        
        JSBridge?.register(handlerName: "auiResetSessionState") { (paramters, callback) in
            print("Logoff occurred: \(String(describing: paramters))")
            currentSessionAuthenticated = false
            auiSessionCount = 0
            
        }
        
        JSBridge?.register(handlerName: "auiRegisterDynamicQuickActions") { (paramters, callback) in
            print("Dynamic handlers linked: \(String(describing: paramters))")
            
            // temp: do something with the quick actions
            
        }
        
        JSBridge?.register(handlerName: "auiAWHLoaded") { (paramters, callback) in
            print("AWH loaded: \(String(describing: paramters))")
            auiDataChannel.performSynchOperations()
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startSynchScanning"), object: nil)
            
        }
    
        JSBridge?.call(handlerName: "testJavascriptHandler", data: ["greetingFromiOS": "Hi there, JS!"]) { (response) in
            print("testJavascriptHandler responded: \(String(describing: response))")
            
        }
        
    }
    
    class func passTrustedCredentials(userID: String, password: String) {
        JSBridge?.call(handlerName: "receiveTrustedUserCredentials", data: ["username": userID, "password": password]) { (response) in
            print("receiveTrustedUserCredentials responded: \(String(describing: response))")
            
        }
        
    }
    
    class func passMovementEvent() {
        JSBridge?.call(handlerName: "movementOccurred", data: []) { (response) in
            print("movementOccurred responded: \(String(describing: response))")
            
        }
        
    }
    
    class func passMovementStoppedEvent() {
        JSBridge?.call(handlerName: "movementStopped", data: []) { (response) in
            print("movementStopped responded: \(String(describing: response))")
            
        }
        
    }
    
    class func passLocationChangeEvent(mEvent: [String: AnyObject]) {
        JSBridge?.call(handlerName: "locationChangeEvent", data: mEvent) { (response) in
            print("locationChangeEvent responded: \(String(describing: response))")
            
        }
        
    }
    
    class func passLogoutEvent() {
        JSBridge?.call(handlerName: "triggerLogout", data: []) { (response) in
            print("triggerLogout responded: \(String(describing: response))")
            
        }
        
    }
    
}
