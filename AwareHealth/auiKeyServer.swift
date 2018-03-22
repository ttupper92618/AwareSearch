//
//  auiKeyServer.swift
//  AwareHealth
//
//  Created by Tom Tupper on 3/11/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

struct JSONStringArrayEncoding: ParameterEncoding {
    private let myString: String
    
    init(string: String) {
        self.myString = string
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        
        let data = myString.data(using: .utf8)!
        
        if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest?.httpBody = data
        
        return urlRequest!
    }
    
}

class auiKeyServer: NSObject {
    func obtainKeyServerData() {
        // get data from the keyserver oAuth instance
        var fetchToken = false
        let mData = auiCoreDataHandler.getKeyserverOAuthData()
        let size = mData!.count
        
        if (size == 0) {
            fetchToken = true
            
        }
        
        if(fetchToken) {
            let bodyString = "client_id=\(auiKeyserverOAuthClientID)&client_secret=\(auiKeyserverOAuthClientSecret)&scope=\(auiKeyserverOAuthAPIKey)&grant_type=\(auiKeyserverOAuthGrantType)"
            // let dQueue = DispatchQueue(label: "com.awarepoint.response-queue", qos: .utility, attributes: [.concurrent])
            
            Alamofire.request(auiKeyserverOAuthURL, method: .post, parameters: [:], encoding: JSONStringArrayEncoding.init(string: bodyString), headers: [:]).responseString { response in
                switch response.result {
                case .success:
                    // hide network indicator
                    if (!appIsConfigured) {
                        SVProgressHUD.dismiss()
                    }
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        auiKeyserverOAuthAccessToken = json["access_token"].string!
                        auiKeyserverOAuthTokenType = json["token_type"].string!
                        auiKeyserverOAuthExpiresInSeconds = json["expires_in"].int!
                        auiKeyserverOAuthRefreshToken = json["refresh_token"].string!
                        auiKeyserverOAuthOK = true
                        
                        // save the data
                        _ = auiCoreDataHandler.saveKeyserverOAuthData(accessToken: auiKeyserverOAuthAccessToken, refreshToken: auiKeyserverOAuthRefreshToken, tokenType: auiKeyserverOAuthTokenType, expirationPeriod: auiKeyserverOAuthExpiresInSeconds, oAuthSuccess: auiKeyserverOAuthOK)
                        
                        // continue get key data
                        self.obtainKeyData()
                        
                    }
                case .failure(let error):
                    // hide network indicator
                    if (!appIsConfigured) {
                        SVProgressHUD.dismiss()
                    }
                    auiKeyserverOAuthOK = false
                    
                }
                
            }
            
        } else {
            // hide network indicator
            if (!appIsConfigured) {
                SVProgressHUD.dismiss()
            }
            
            // parse mData and then continue
            auiKeyserverOAuthAccessToken = mData!.first!.token!
            auiKeyserverOAuthTokenType = mData!.first!.type!
            auiKeyserverOAuthExpiresInSeconds = Int(mData!.first!.duration)
            auiKeyserverOAuthRefreshToken = mData!.first!.refreshToken!
            auiKeyserverOAuthOK = true
            
            // continue get key data
            self.obtainKeyData()
            
        }
        
    }
    
    func obtainKeyData() {
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiKeyserverOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        // let oURL = "\(auiKeyserverURL)\(appKeyString)"
        let oURL = "\(auiKeyserverURL)99999"
        // let dQueue = DispatchQueue(label: "com.awarepoint.response-queue", qos: .utility, attributes: [.concurrent])
        
        // call API
        Alamofire.request(oURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    didGetAppIdentity = true
                    let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                    let json = JSON(dataFromString!)
                    
                    print(json)
                    
                    let mURL: String = json["awareHealthUIUrl"].string!
                    let mAPI: String = json["awarehealthAPIUrl"].string!
                    let mAppName: String = json["applicationName"].string!
                    let mAppAuthorized: Bool = json["isAuthenticated"].bool!
                    let moAuthURL: String = json["oauthUrl"].string!
                    let moAuthID: String = json["oauthClientId"].string!
                    let moAuthSecret: String = json["oauthClientSecret"].string!
                    let moAuthAPIKey: String = json["apiKey"].string!
                    let moAuthGrantType: String = json["oauthGrantType"].string!
                    var isAuthorized: Bool = false
                    isAuthorized = mAppAuthorized
                    
                    print(mURL)
                    print(mAPI)
                    print(mAppName)
                    print(mAppAuthorized)
                    print(moAuthURL)
                    print(moAuthID)
                    print(moAuthSecret)
                    print(moAuthAPIKey)
                    print(moAuthGrantType)
                    print(isAuthorized)
                    
                    // save data
                    /*
                    let baseState = auiCoreDataHandler.saveBaseURL(baseURL: mURL)
                    if (!baseState) {
                        _ = auiCoreDataHandler.saveBaseURL(baseURL: "")
                        
                    }
                    
                    let apiState = auiCoreDataHandler.saveAPIURL(apiURL: mAPI)
                    if (!apiState) {
                        _ = auiCoreDataHandler.saveAPIURL(apiURL: "")
                        
                    }
                    
                    let identityState = auiCoreDataHandler.saveAppIdentity(appName: mAppName, appKey: appCode, appAuthorized: isAuthorized)
                    if (!identityState) {
                        _ = auiCoreDataHandler.saveAppIdentity(appName: "", appKey: "", appAuthorized: false)
                        
                    }
                    
                    let endpointDataState = auiCoreDataHandler.saveAppEndpointData(apiURL: mAPI, oAuthURL: moAuthURL, oAuthID: moAuthID, oAuthSecret: moAuthSecret, oAuthAPIKey: moAuthAPIKey, oAuthGrantType: moAuthGrantType)
                    if (!endpointDataState) {
                        _ = auiCoreDataHandler.saveAppEndpointData(apiURL: "", oAuthURL: "", oAuthID: "", oAuthSecret: "", oAuthAPIKey: "", oAuthGrantType: "")
                        
                    }
 
                    */
                    
                }
            case .failure(let error):
                print(error)
                appIsAuthorized = false
                
            }
            
        }
        
    }

}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
