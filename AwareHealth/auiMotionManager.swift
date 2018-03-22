//
//  auiMotionManager.swift
//  AwareHealth
//
//  Created by Tom Tupper on 3/19/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import CoreMotion
let motionManager: CMMotionManager = CMMotionManager()
var initialAttitude : CMAttitude!

class auiMotionManager: NSObject {
    //start motion manager
    func StartMotionManager () {
        if !motionManager.deviceMotionActive {
            motionManager.deviceMotionUpdateInterval = 1
            motionManager.startDeviceMotionUpdates()
        }
    }
    //stop motion manager
    func stopMotionManager ()
    {
        if motionManager.deviceMotionActive
        {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    //update motion manager
    func updateMotionManager (var x : UIViewController)
    {
        
        if motionManager.deviceMotionAvailable {
            //sleep(2)
            initialAttitude  = motionManager.deviceMotion.attitude
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                [weak x] (data: CMDeviceMotion!, error: NSError!) in
                
                data.attitude.multiplyByInverseOfAttitude(initialAttitude)
                
                // calculate magnitude of the change from our initial attitude
                let magnitude = magnitudeFromAttitude(data.attitude) ?? 0
                let initMagnitude = magnitudeFromAttitude(initialAttitude) ?? 0
                
                if magnitude > 0.1 // threshold
                {
                    // Device has moved !
                    // put the code which should fire upon device moving write here
                    
                    initialAttitude  = motionManager.deviceMotion.attitude
                }
            })
            
            println(motionManager.deviceMotionActive) // print false
        }
        
    }
    

    // get magnitude of vector via Pythagorean theorem
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
    
}
