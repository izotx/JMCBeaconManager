//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Janusz Chudzynski on 6/21/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PWDisplayLinkerDelegate{
    
    
    @IBOutlet var squareView: SquareView!
    var displayLinker: PWDisplayLinker!
    
    //New instance
    let beaconManager = JMCBeaconManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.displayLinker = PWDisplayLinker(delegate: self)
        
        beaconManager.checkStatus()
        ///Wait for notificatio
        startMonitoring()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(beaconsRanged(_:)), name: iBeaconNotifications.BeaconProximity.rawValue, object: nil)
    }

    /**Called when the beacons are ranged*/
    func beaconsRanged(notification:NSNotification){
        if let visibleIbeacons = notification.object as? [iBeacon]
        {
            for beacon in visibleIbeacons{
                self.squareView.addBeacon(beacon: beacon)
            }
            print(visibleIbeacons)
        }
    }
    
    func displayWillUpdateWithDeltaTime(deltaTime: CFTimeInterval) {
        self.squareView.moveBeacons() // Moves the beacons
    }
    
    func startMonitoring(){
        //check if enabled
        // beaconManager.registerBeacon("f7826da6-4fa2-4e98-8024-bc5b71e0893e")
       
        let kontaktIOBeacon = iBeacon(minor: nil, major: nil, proximityId: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let estimoteBeacon = iBeacon(minor: nil, major: nil, proximityId: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        
        //major 2505 minor 36274
        beaconManager.registerBeacons([kontaktIOBeacon, estimoteBeacon])
//        beaconManager.statusCheck()
//        beaconManager.startMonitoring()
        
        if beaconManager.statusCheck(){
            beaconManager.startMonitoring()
        }
        
        /**updates user's visited places information*/
        func stateCallback(beacon:iBeacon)->Void{
            // user.addLocation(beacon)
        }
        
        /**updates user's visited places information*/
        func rangeCallback (beacon:iBeacon)->Void{
            //FIXME - unused
            //  user.addLocation(beacon)
            
            
            
        }
        
        beaconManager.stateCallback = stateCallback
        beaconManager.rangeCallback = rangeCallback
        
        beaconManager.logging = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

