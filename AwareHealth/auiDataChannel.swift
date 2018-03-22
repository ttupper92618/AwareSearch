//
//  DataChannel.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/8/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreMotion
import AwpLocationEngine
import MessageUI
import Alamofire
import SwiftyJSON
import SVProgressHUD

var rawRooms: String = ""
var rawAreas: String = ""
var rawFloors: String = ""
var rawBeacons: String = ""
var rawAlgorithms: String = ""

class auiDataChannel: NSObject {
    let vc1 = ViewController()
    var alamoFireManager : SessionManager?
    
    class func performSynchOperations() {
        // Start the process to perform all synch operations.
        auiSynchInProgress = true
        auiSynchSuccessful = true
        
        let eSynchData = auiCoreDataHandler.getSynchData()
        if (eSynchData?.count != 0) {
            let lastSynchSuccessful = eSynchData!.first!.auiSynchSuccessful
            let lastSynchDate = eSynchData!.first!.auiLastCheckDate
            let currentDate = Date()
            let elapsedSeconds = currentDate.timeIntervalSince(lastSynchDate!)
            
            // if it has been more than a week, or the last synch failed, re-synch
            if (!lastSynchSuccessful || elapsedSeconds > 604800) {
                self.getFloorConfig()
                
            } else {
                auiRawAlgorithmData = JSON(eSynchData!.first!.auiAlgorithmConfig?.data(using: .utf8, allowLossyConversion: false) as Any)
                auiRawAreaData = JSON(eSynchData!.first!.auiAreaConfig?.data(using: .utf8, allowLossyConversion: false) as Any)
                auiRawRoomData = JSON(eSynchData!.first!.auiRoomConfig?.data(using: .utf8, allowLossyConversion: false) as Any)
                auiRawFloorData = JSON(eSynchData!.first!.auiFloorConfig?.data(using: .utf8, allowLossyConversion: false) as Any)
                auiRawBeaconData = JSON(eSynchData!.first!.auiBeaconConfig?.data(using: .utf8, allowLossyConversion: false) as Any)
                
                self.processConfiguration()
                
            }
            
        } else {
            self.getFloorConfig()
            
        }
        
    }
    
    class func getFloorConfig() {
        // get the floor configuration
        print("GET: floor config")
        let configURL = primaryAPIURL + "api/ble/floors"
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        // show network indicator
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBarActivityIndicator"), object: nil)
        
        if (auiRawFloorData.count == 0) {
            // call API
            Alamofire.request(configURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        if (json["_links"] != JSON.null) {
                            // save the result string
                            print("floor config synch succesful")
                            rawFloors = result
                            auiRawFloorData = json
                            
                        } else {
                            auiSynchSuccessful = false
                            
                        }
                        
                        // call the next in the chain
                        self.getRoomConfig()
                        
                    }
                case .failure:
                    auiSynchSuccessful = false
                    
                    // call the next in the chain, but set synchSuccessful false
                    auiSynchSuccessful = false
                    self.getRoomConfig()
                    
                }
                
            }
            
        } else {
            // call the next in the chain
            print("floor config read from storage")
            self.getRoomConfig()
            
        }
        
    }
    
    class func getRoomConfig() {
        // get the room config
        print("GET: room config")
        let configURL = primaryAPIURL + "api/ble/rooms"
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        if (auiRawRoomData.count == 0) {
            Alamofire.request(configURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        if (json["_links"] != JSON.null) {
                            // save the result string
                            print("room config synch succesful")
                            rawRooms = result
                            auiRawRoomData = json
                            
                        } else {
                            // save an empty value and set synch success false
                            auiSynchSuccessful = false
                            
                        }
                        
                        // call the next in the chain
                        self.getBeaconConfig()
                        
                    }
                case .failure:
                    auiSynchSuccessful = false
                    
                    // call the next in the chain, but set synchSuccessful false
                    auiSynchSuccessful = false
                    self.getBeaconConfig()
                    
                }
                
            }
            
        } else {
            // call the next in the chain
            print("room config read from storage")
            self.getBeaconConfig()
            
        }
        
    }
    
    class func getBeaconConfig() {
        // get the beacon config
        print("GET: beacon config")
        let configURL = primaryAPIURL + "api/ble/beacons"
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        if (auiRawBeaconData.count == 0) {
            Alamofire.request(configURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        if (json["_links"] != JSON.null) {
                            // save the result string
                            print("beacon config synch succesful")
                            rawBeacons = result
                            auiRawBeaconData = json
                            
                        } else {
                            auiSynchSuccessful = false
                            
                        }
                        
                        // call the next in the chain
                        self.getRegionConfig()
                        
                    }
                case .failure:
                    auiSynchSuccessful = false
                    
                    // call the next in the chain, but set synchSuccessful false
                    auiSynchSuccessful = false
                    self.getRegionConfig()
                    
                }
                
            }
            
        } else {
            // call the next in the chain
            print("beacon config read from storage")
            self.getRegionConfig()
            
        }
        
    }
    
    class func getRegionConfig() {
        // get the region config
        print("GET: area config...")
        let configURL = primaryAPIURL + "api/ble/areas"
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        if (auiRawAreaData.count == 0) {
            Alamofire.request(configURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        if (json["_links"] != JSON.null) {
                            // save the result string
                            print("area config synch succesful")
                            rawAreas = result
                            auiRawAreaData = json
                            
                        } else {
                            auiSynchSuccessful = false
                            
                        }
                        
                        // call the next in the chain
                        self.getAlgorithmConfig()
                        
                    }
                case .failure:
                    auiSynchSuccessful = false
                    
                    // call the next in the chain, but set synchSuccessful false
                    auiSynchSuccessful = false
                    self.getAlgorithmConfig()
                    
                }
                
            }
            
        } else {
            // call the next in the chain
            print("area config read from storage")
            self.getAlgorithmConfig()
            
        }
        
    }
    
    class func getAlgorithmConfig() {
        // get the algorithm config
        print("GET: algorithm config")
        let configURL = primaryAPIURL + "api/ble/algorithmConfig"
        let oHeaders: HTTPHeaders = [
            "Authorization": "Bearer " + auiOAuthAccessToken,
            "Accept": "application/hal+json"
        ]
        
        if (auiRawAlgorithmData.count == 0) {
            Alamofire.request(configURL, method: .get, parameters: [:], encoding: JSONEncoding.default, headers: oHeaders).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        if (json["_links"] != JSON.null) {
                            // save the result string
                            print("algorithm config synch succesful")
                            rawAlgorithms = result
                            auiRawAlgorithmData = json
                            
                        } else {
                            auiSynchSuccessful = false
                            
                        }
                        
                        // save the synch data and state
                        self.saveSynchData()
                        
                    }
                case .failure:
                    
                    // call the next in the chain, but set synchSuccessful false
                    auiSynchSuccessful = false
                    
                    // save the synch data and state
                    self.saveSynchData()
                    
                }
                
            }
            
        } else {
            // save the synch data and state
            print("algorithm config read from storage")
            self.saveSynchData()
            
        }
        
    }
    
    class func saveSynchData() {
        // save the synch data
        print("save synch data")
        print("synch state success: \(auiSynchSuccessful)")
        
        // hide network activity spinner
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideBarActivityIndicator"), object: nil)
        
        // save the data every time
        let _ = auiCoreDataHandler.saveSynchData(floorData: rawFloors, roomData: rawRooms, areaData: rawAreas, beaconData: rawBeacons, algorithmData: rawAlgorithms, synchSuccess: auiSynchSuccessful)
        
        if (auiSynchSuccessful) {
            // track the progress state
            auiSynchInProgress = false
            
            // process the configs we have
            self.processConfiguration()
            
        } else {
            // we didn't have a successful synch, so kick it off again
            self.performSynchOperations()
            
        }
        
    }
    
    class func processConfiguration() {
        // process all the config data
        self.processFloorConfig()
        self.processAreaConfig()
        self.processRoomConfig()
        self.processBeaconConfig()
        self.processAlgorithmConfig()
        
    }
    
    class func processFloorConfig() {
        // process the floor config
        let embedded = auiRawFloorData["_embedded"]
        let floors = embedded["floors"]
        
        for (_, floor) in floors {
            let id = floor["id"].int
            let scale = floor["scale"].double
            let latitude = floor["latitude"].double
            let longitude = floor["longitude"].double
            let x = floor["x"].double
            let y = floor["y"].double
            let rotationAngle = floor["angle"].double
            
            let floorConfig = FloorConfig(id : id!, scale: scale! , lat: latitude!, longitude: longitude!, latOffset: x!, longOffset: y!, rotAngle: rotationAngle!)
            
            floorConfigList.append(floorConfig)
            
        }
        
        if floorConfigList.count == 0{
            totalFloors = -2
            
        } else {
            totalFloors = floorConfigList.count
            
        }
        
    }
    
    class func processAreaConfig() {
        // process the area config
        let embedded = auiRawAreaData["_embedded"]
        let areas = embedded["bleAreas"]
        
        for (_, bleArea) in areas {
            let id = bleArea["id"].int
            let parentId = bleArea["parentId"].int
            let regionTypeName = bleArea["type"].string
            let regionName = bleArea["name"].string
            let regionType = RegionType(rawValue: regionTypeName!)
            var areaPointsList = [(Double,Double)]()
            let areaPointsJson = bleArea["areaPoints"]
            
            for (_, areaPointDic) in areaPointsJson {
                let x = areaPointDic["x"].double
                let y = areaPointDic["y"].double
                areaPointsList.append(( x!, y!))
                    
            }
            
            let regionConfig = RegionConfig(id: id!, regionType: regionType!, parentId: parentId!, regionName: regionName!, vertices: areaPointsList )
            
            regionConfigList.append(regionConfig)
            
        }
        
        if regionConfigList.count == 0 {
            totalRegions = -2
            
        } else {
            totalRegions = regionConfigList.count
            
        }
        
        // print(regionConfigList)
        
    }
    
    class func processRoomConfig() {
        // process the room config
        let embedded = auiRawRoomData["_embedded"]
        let rooms = embedded["rooms"]
        
        for (_, room) in rooms {
            let id = room["id"].int
            let categoryName = room["category"].string
            var hallwayId = room["hallway"].int
            let roomCategory = self.getRoomCategoryFromString(categoryName!)
            var firstOrderRooms = [Int]()
            let firstOrder = room["firstOrderRooms"].arrayObject
            
            for roomId in firstOrder!{
                firstOrderRooms.append(Int(String(describing: roomId))!)
                
            }
            
            if hallwayId == nil{
                hallwayId = 0
                
            }
            
            if roomCategory != nil{
                let roomConfig = RoomConfig(id: id!, category: roomCategory!, hallwayId: hallwayId!, firstOrderRooms: firstOrderRooms )
                roomConfigList.append(roomConfig)
                
            } else {
                print("Error RoomID: \(String(describing: id))")
                
            }
            
        }
        
        if roomConfigList.count == 0 {
            totalRooms = -2
            
        } else {
            totalRooms = roomConfigList.count
            
        }
        
    }
    
    class func processBeaconConfig() {
        // process the beacon config
        let embedded = auiRawBeaconData["_embedded"]
        let beacons = embedded["beacons"]
        
        for (_, subJson) in beacons {
            let pid = subJson["id"].string
            let regionId = subJson["areaId"].int
            let pairedPid = subJson["pairedPid"].double
            let longitude = subJson["longitude"].double
            let latitude = subJson["latitude"].double
            let floorId = subJson["floorId"].int
            let x = subJson["x"].double
            let y = subJson["y"].double
            var placed = subJson["placed"].int
            let interval = subJson["interval"].int
            let power = subJson["power"].int
            let typeId = subJson["type"].int
            let zoneId = subJson["zone"].int
            let beaconType = BeaconType(rawValue: typeId!)
            let beaconZone = BeaconZone(rawValue: zoneId!)
            
            if placed == nil{
                placed = 1
                
            }
            
            let beaconPlaced = self.convertIntToBool(placed!)
            
            let beaconConfig = BeaconConfig(id: Int(pid!)!, beaconType: beaconType! , beaconZone: beaconZone!, beaconPower: power!, beaconInterval: interval!, coordinateXY: (x!,y!), coordinateLatLong: (latitude!,longitude!) , regionId: regionId!, floorId: floorId!, pairedId: Int(pairedPid!), placed:  beaconPlaced)
            
            beaconConfigList.append(beaconConfig)
            
        }
        
        if beaconConfigList.count == 0 {
            totalBeacons = -2
            
        } else {
            totalBeacons = beaconConfigList.count
            
        }
        
    }
    
    class func processAlgorithmConfig() {
        // process the algorithm config
        let embedded = auiRawAlgorithmData["_embedded"]
        let algorithms = embedded["items"]
        
        for (_, singleAlgorithm) in algorithms {
            let configType = singleAlgorithm["configType"].string
            if (configType == "SITE_DEFAULT") {
                let platform = singleAlgorithm["platform"].dictionary
                
                if (platform!["name"] == "iOS") {
                    let configValues = singleAlgorithm["configValues"].array
                    
                    for configItem in configValues! {
                        let value = configItem["value"]
                        let keyJson = configItem["key"]
                        let keyName = keyJson["name"]
                        let keyValue = String(describing: value)
                        let algorithmConfig = AlgorithmConfig(keyName: String(describing: keyName), keyValue: keyValue )
                        algorithmConfigList.append(algorithmConfig)
                        
                    }
                    
                }
                
            }
            
        }
        
        if algorithmConfigList.count == 0 {
            totalAlgorithm = -2
            
        } else {
            totalAlgorithm = algorithmConfigList.count
            
        }
        
        // done - perform init tasks
        if (auiSynchSuccessful) {
            self.performInit()
            
        } else {
            // to do - we want to warn that there is no successful synch
            
        }
        
    }
    
    class func performInit() {
        // perform init functions
        if (!MLEInitialized && currentSessionAuthenticated) {
            // set up config
            configManager = ConfigManager (beaconConfigsInput: beaconConfigList, regionConfigsInput: regionConfigList, floorConfigsInput: floorConfigList, roomConfigsInput: roomConfigList, algorithmConfigsInput: algorithmConfigList)
        
            // init the MLE
            mobileInputCore = MobileInputCore(configManager: configManager!, locationChangeListener : locationChangeListener )
            
            // mark that we are inited
            MLEInitialized = true
            
            // mark that the engine is ready
            readyToScan = true
            
        } else {
            readyToScan = true
            
        }
        
    }
    
    class func convertIntToBool( _ input: Int) -> Bool{
        
        if input == 1{
            return true
        }else if input == 0{
            return false
        }
        
        
        return false
        
    }
    
    class func getRoomCategoryFromString(_ name: String)->RoomCategory?{
        var initial = 0
        
        while let roomCategory = RoomCategory(rawValue: initial){
            if String(describing: roomCategory) == name{
                return roomCategory
            }
            initial += 1
        }
        
        return nil
        
    }
    
    class func getOAuthToken() {
        // see if there is any oauth data
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
            let bodyString = "client_id="+oAuthID+"&client_secret="+oAuthSecret+"&scope=apikey%3D"+oAuthAPIKey+"&grant_type="+oAuthGrantType
            let authURL = oAuthURL + "oauth/token"
            // let dQueue = DispatchQueue(label: "com.awarepoint.response-queue", qos: .utility, attributes: [.concurrent])
            
            print(bodyString)
            print(authURL)
            
            Alamofire.request(authURL, method: .post, parameters: [:], encoding: JSONStringArrayEncoding.init(string: bodyString), headers: [:]).responseString { response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        let dataFromString = result.data(using: .utf8, allowLossyConversion: false)
                        let json = JSON(dataFromString!)
                        
                        auiOAuthAccessToken = json["access_token"].string!
                        auiOAuthExpiresInSeconds = json["expires_in"].int!
                        auiOAuthRefreshToken = json["refresh_token"].string!
                        auiOAuthTokenType = json["token_type"].string!
                        auiOAuthEnvironment = oAuthURL
                        
                        // save the token data
                        _ = auiCoreDataHandler.saveOAuthData(accessToken: auiOAuthAccessToken, refreshToken: auiOAuthRefreshToken, tokenType: auiOAuthTokenType, environment: auiOAuthEnvironment, expirationPeriod: auiOAuthExpiresInSeconds, oAuthSuccess: true)
                        
                        auiDataChannel.performSynchOperations()
                        
                    }
                case .failure(let error):
                    // hide network indicator
                    print(error)
                    _ = auiCoreDataHandler.saveOAuthData(accessToken: "", refreshToken: "", tokenType: "", environment: "", expirationPeriod: 0, oAuthSuccess: false)
                    
                }
                
            }
            
        }
        
    }
    
}
