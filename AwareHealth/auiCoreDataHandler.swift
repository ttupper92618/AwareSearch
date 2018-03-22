//
//  auiCoreDataHandler.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/8/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import CoreData

class auiCoreDataHandler: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        // get the context object
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    
    }
    
    // --- baseURL ----
    class func saveBaseURL(baseURL: String) -> Bool {
        let existingURL = getBaseURL()
        if (existingURL!.count > 0) {
            deleteBaseURL()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIAppURL", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(baseURL, forKey: "auiBaseURL")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getBaseURL() -> [AUIAppURL]? {
        let context = getContext()
        var baseURL: [AUIAppURL]? = nil
        
        do {
            baseURL = try context.fetch(AUIAppURL.fetchRequest())
            return baseURL
        } catch {
            return baseURL
        
        }
    
    }
    
    class func deleteBaseURL() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIAppURL")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- apiURL ----
    class func saveAPIURL(apiURL: String) -> Bool {
        let existingURL = getAPIURL()
        if (existingURL!.count > 0) {
            deleteAPIURL()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIAPIURL", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(apiURL, forKey: "apiURL")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getAPIURL() -> [AUIAPIURL]? {
        let context = getContext()
        var apiURL: [AUIAPIURL]? = nil
        
        do {
            apiURL = try context.fetch(AUIAPIURL.fetchRequest())
            return apiURL
        } catch {
            return apiURL
            
        }
        
    }
    
    class func deleteAPIURL() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIAPIURL")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- user ----
    class func saveUser(userName: String, password: String, remember: Bool) -> Bool {
        let existingUser = getUser()
        if (existingUser!.count > 0) {
            deleteUser()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIUser", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(userName, forKey: "auiUserName")
        managedObject.setValue(password, forKey: "auiUserPassword")
        managedObject.setValue(remember, forKey: "auiRememberUser")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getUser() -> [AUIUser]? {
        let context = getContext()
        var user: [AUIUser]? = nil
        
        do {
            user = try context.fetch(AUIUser.fetchRequest())
            return user
            
        } catch {
            return user
            
        }
        
    }
    
    class func deleteUser() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIUser")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- appIdentity ----
    class func saveAppIdentity(appName: String, appKey: String, appAuthorized: Bool) -> Bool {
        let existingAppIdentity = getAppIdentity()
        if (existingAppIdentity!.count > 0) {
            deleteAppIdentity()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIAppIdentity", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(appName, forKey: "auiAppName")
        managedObject.setValue(appKey, forKey: "auiAppKey")
        managedObject.setValue(appAuthorized, forKey: "auiAppAuthorized")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getAppIdentity() -> [AUIAppIdentity]? {
        let context = getContext()
        var appIdentity: [AUIAppIdentity]? = nil
        
        do {
            appIdentity = try context.fetch(AUIAppIdentity.fetchRequest())
            return appIdentity
            
        } catch {
            return appIdentity
            
        }
        
    }
    
    class func deleteAppIdentity() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIAppIdentity")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- appEndpointData ----
    class func saveAppEndpointData(apiURL: String, oAuthURL: String, oAuthID: String, oAuthSecret: String, oAuthAPIKey: String, oAuthGrantType: String) -> Bool {
        let existingAppEndpointData = getAppEndpointData()
        if (existingAppEndpointData!.count > 0) {
            deleteAppEndpointData()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIEndpointData", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(apiURL, forKey: "apiURL")
        managedObject.setValue(oAuthURL, forKey: "oAuthURL")
        managedObject.setValue(oAuthID, forKey: "oAuthID")
        managedObject.setValue(oAuthSecret, forKey: "oAuthSecret")
        managedObject.setValue(oAuthAPIKey, forKey: "oAuthAPIKey")
        managedObject.setValue(oAuthGrantType, forKey: "oAuthGrantType")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getAppEndpointData() -> [AUIEndpointData]? {
        let context = getContext()
        var appEndpointData: [AUIEndpointData]? = nil
        
        do {
            appEndpointData = try context.fetch(AUIEndpointData.fetchRequest())
            return appEndpointData
            
        } catch {
            return appEndpointData
            
        }
        
    }
    
    class func deleteAppEndpointData() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIEndpointData")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- synchData ----
    class func saveSynchData(floorData: String, roomData: String, areaData: String, beaconData: String, algorithmData: String, synchSuccess: Bool) -> Bool {
        let existingSynchData = getSynchData()
        if (existingSynchData!.count > 0) {
            deleteSynchData()
            
        }
        
        let date = Date()
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUISynchData", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(floorData, forKey: "auiFloorConfig")
        managedObject.setValue(roomData, forKey: "auiRoomConfig")
        managedObject.setValue(areaData, forKey: "auiAreaConfig")
        managedObject.setValue(beaconData, forKey: "auiBeaconConfig")
        managedObject.setValue(algorithmData, forKey: "auiAlgorithmConfig")
        managedObject.setValue(synchSuccess, forKey: "auiSynchSuccessful")
        managedObject.setValue(date, forKey: "auiLastCheckDate")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getSynchData() -> [AUISynchData]? {
        let context = getContext()
        var appSynchtData: [AUISynchData]? = nil
        
        do {
            appSynchtData = try context.fetch(AUISynchData.fetchRequest())
            return appSynchtData
            
        } catch {
            return appSynchtData
            
        }
        
    }
    
    class func deleteSynchData() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUISynchData")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- oAuth data ----
    class func saveOAuthData(accessToken: String, refreshToken: String, tokenType: String, environment: String, expirationPeriod: Int, oAuthSuccess: Bool) -> Bool {
        let existingOAuthData = getOAuthData()
        if (existingOAuthData!.count > 0) {
            deleteOAuthData()
            
        }
        
        let date = Date()
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIOAuthData", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(accessToken, forKey: "token")
        managedObject.setValue(refreshToken, forKey: "refreshToken")
        managedObject.setValue(tokenType, forKey: "type")
        managedObject.setValue(environment, forKey: "environment")
        managedObject.setValue(oAuthSuccess, forKey: "oAuthSuccessful")
        managedObject.setValue(expirationPeriod, forKey: "duration")
        managedObject.setValue(date, forKey: "lastOAuthDate")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getOAuthData() -> [AUIOAuthData]? {
        let context = getContext()
        var appOAuthData: [AUIOAuthData]? = nil
        
        do {
            appOAuthData = try context.fetch(AUIOAuthData.fetchRequest())
            return appOAuthData
            
        } catch {
            return appOAuthData
            
        }
        
    }
    
    class func deleteOAuthData() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIOAuthData")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- keyserver oAuth data ----
    class func saveKeyserverOAuthData(accessToken: String, refreshToken: String, tokenType: String, expirationPeriod: Int, oAuthSuccess: Bool) -> Bool {
        let existingOAuthData = getKeyserverOAuthData()
        if (existingOAuthData!.count > 0) {
            deleteKeyserverOAuthData()
            
        }
        
        let date = Date()
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIKeyServerOAuthData", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(accessToken, forKey: "token")
        managedObject.setValue(refreshToken, forKey: "refreshToken")
        managedObject.setValue(tokenType, forKey: "type")
        managedObject.setValue(oAuthSuccess, forKey: "oAuthSuccessful")
        managedObject.setValue(expirationPeriod, forKey: "duration")
        managedObject.setValue(date, forKey: "lastOAuthDate")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getKeyserverOAuthData() -> [AUIKeyServerOAuthData]? {
        let context = getContext()
        var appKeyserverOAuthData: [AUIKeyServerOAuthData]? = nil
        
        do {
            appKeyserverOAuthData = try context.fetch(AUIKeyServerOAuthData.fetchRequest())
            return appKeyserverOAuthData
            
        } catch {
            return appKeyserverOAuthData
            
        }
        
    }
    
    class func deleteKeyserverOAuthData() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIKeyServerOAuthData")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- auth mode ----
    class func saveAuthModeData(authModeDefined: Bool, authPin: [Int], authModeString: String, authModeIndex: Int) -> Bool {
        let existingAuthModeData = getAuthModeData()
        if (existingAuthModeData!.count > 0) {
            deleteAuthModeData()
            
        }
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIAuthMode", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(authModeDefined, forKey: "auiAuthModeDefined")
        managedObject.setValue(authPin, forKey: "auiAuthPin")
        managedObject.setValue(authModeString, forKey: "auiSelectedAuthMode")
        managedObject.setValue(authModeIndex, forKey: "auiSelectedAuthModeIndex")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func getAuthModeData() -> [AUIAuthMode]? {
        let context = getContext()
        var appAuthModeData: [AUIAuthMode]? = nil
        
        do {
            appAuthModeData = try context.fetch(AUIAuthMode.fetchRequest())
            return appAuthModeData
            
        } catch {
            return appAuthModeData
            
        }
        
    }
    
    class func deleteAuthModeData() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIAuthMode")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // do nothing
            
        }
        
    }
    
    // --- favorites ----
    class func saveAssetFavorite(keywords: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIAssetFavorites", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(keywords, forKey: "auiAssetFavorite")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func saveStaffFavorite(keywords: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIStaffFavorites", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(keywords, forKey: "auiStaffFavorite")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    class func savePatientFavorite(keywords: String) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "AUIPatientFavorites", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        managedObject.setValue(keywords, forKey: "auiPatientFavorite")
        
        do {
            try context.save()
            return true
            
        } catch {
            return false
            
        }
        
    }
    
    // --- utility ----
    class func auiBaseURLExists(id: Int) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AUIAppURL")
        let predicate = NSPredicate(format: "auiPrimaryURL == %@", request)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let context = getContext()
            let count = try context.count(for: request)
            if (count == 0) {
                return false
                
            } else {
                return true
                
            }
            
        } catch {
            return false
            
        }
        
    }

}
