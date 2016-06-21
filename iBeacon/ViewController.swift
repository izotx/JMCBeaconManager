//
//  ViewController.swift
//  iBeacon
//
//  Created by Janusz Chudzynski on 3/23/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.

/*
TODO:
Edit this file to create your own implementation of the iBeacon application.
Essential part of the app are two managers: 
1.Beacon manager
2.Network Utilities

Beacon manager
Steps:
1. Create an instance
2. Register beacons to monitor
3. Listen for delegate methods callbacks

beaconsFound(udid:String?, major:Int32, minor:Int32,  proximity:CLProximity, accuracy: CLLocationAccuracy, rssi:Int) - called when iOS estimates distance to nearby beacon

and:

regionEvent(udid:String?, major:Int32, minor:Int32,  state:UInt){

*/


import UIKit

class ViewController: UIViewController {
    var jmcBeaconManager = JMCBeaconManager()
    var networkingManager = ATCBeaconNetworkUtilities()
    var immediateController:UIViewController?
    var nearController:UIViewController?
    var farController:UIViewController?
    
    var currentChildController:UIViewController?
    
    @IBOutlet weak var containerView: UIView!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Disable Logging
        jmcBeaconManager.logging = true;
        
        self.immediateController = self.storyboard!.instantiateViewControllerWithIdentifier("immediateController") as? UIViewController
        self.nearController = self.storyboard!.instantiateViewControllerWithIdentifier("nearController") as? UIViewController
        self.farController = self.storyboard!.instantiateViewControllerWithIdentifier("farController") as? UIViewController
        

        var message:NSMutableString = ""
        
        if jmcBeaconManager.isSupported(message)
        {
            
            //TODO: Register beacon that you would like to monitor:
            //jmcBeaconManager.registerRegionWithProximityId("f7826da6-4fa2-4e98-8024-bc5b71e0893e", andIdentifier: "f7826da6-4fa2-4e98-8024-bc5b71e0893e", major: Int32(45074), andMinor: Int32(36073))
            jmcBeaconManager.registerBeaconWithProximityId("f7826da6-4fa2-4e98-8024-bc5b71e0893e", andIdentifier: "pid")
            
            
            jmcBeaconManager.beaconFound = self.beaconsFound
            jmcBeaconManager.regionEvent = self.regionEvent
            jmcBeaconManager.startMonitoring()
         }
    }
    
    /*
        Called when a beacon is found and iOS determined distance to it.
        Proximity has several different values declared in CLProximity enum:
        enum CLProximity : Int {
        case Unknown 0
        case Immediate 1
        case Near 2
        case Far 3
        }
    */
    func beaconsFound(udid:String?, major:Int32, minor:Int32,  proximity:CLProximity, accuracy: CLLocationAccuracy, rssi:Int){
        //design your interaction/s based on the particular iBeacon and distance to it
    //Logging proximity using poximity manager
    self.networkingManager.sendProximityDataForBeacon(major, minor: minor, proximityID: udid, proximity: proximity, user:
        "to test") { (error) -> Void in
                //error
            
        }
  
        switch(proximity){
        case .Unknown:
        return
        case .Immediate:
            self.displayController(immediateController!)
            return
        case .Near:
             self.displayController(nearController!)
        return
        case .Far:
        return
        
        default:// should never be called
        return
            
        }
    
    }
    
    /*Called when user entered or left region*/
    func regionEvent(udid:String?, major:Int32, minor:Int32,  state:CLRegionState){
        /*
        Check if you are inside or outside region (look into implementation details)
        */
       self.networkingManager.sendRegionNotification(major, minor: minor, proximityID: udid!, regionState: state, user: "") { (error) -> Void in
        
        }
        
    }
    
    
    
   /*Methods for adding/removing controllers based on the nearby beacon */
    func displayController(controller:UIViewController){
        //check if the current child controller is not the same as the one we want to add
        if self.currentChildController == controller {return}
        self.addChildViewController(controller)
        //remove current controller
        self.removeController()
        //asign a new one
        self.currentChildController = controller

        controller.view.frame = containerView.frame
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        
        
    }
    
    func removeController(){
        
        if let controller = self.currentChildController {
            controller.willMoveToParentViewController(nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*TESTING*/
    @IBAction func functestAddController(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("immediateController") as! UIViewController
        displayController(vc)
    }

    @IBAction func testRemovingVC(sender: AnyObject) {
        removeController()
    }
    

}

