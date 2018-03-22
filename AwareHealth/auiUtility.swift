//
//  auiUtility.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/18/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class auiUtility: UIViewController {
    class func auiPrefsGoNext() {
        //let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auiCredentialsPrefs")
        //let auiCredentialsPrefsController = auiPrefsControllers[1]
        //self.setViewControllers([auiCredentialsPrefsController], direction: .forward, animated: true, completion: nil)
        
        let mInstance = auiURLPrefsViewController()
        mInstance.performSegue(withIdentifier: "auiCredentialSegue", sender: nil)
        
    }
    
}
