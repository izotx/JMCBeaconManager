//
//  JMCBeaconManager.swift
//  PerfecTour
//
//  Created by Janusz Chudzynski on 1/30/16.
//  Copyright © 2016 PerfecTour. All rights reserved.

import UIKit
import CoreLocation

/**iBeacon*/
class iBeacon : NSObject {
    let minor:UInt16?
    let major:UInt16?
    var id:String // internal name //it will be used by firebase
    var readeableId:String = ""
    let UUID: String //Beacons uuid
    /**Default proximity*/
    var proximity: CLProximity  = CLProximity.Unknown
    /**Default state*/
    var state:CLRegionState = CLRegionState.Unknown
    
    
    
    init(beacon:CLBeacon) {
        self.UUID = beacon.proximityUUID.UUIDString
        self.minor = beacon.minor.unsignedShortValue
        self.major = beacon.major.unsignedShortValue
        self.id = ""
        self.proximity = beacon.proximity
        super.init()
        self.id = generateId()
    }
    
    /**Initializer*/
    init(minor:UInt16?, major:UInt16?, proximityId:String){

        self.UUID = proximityId
        self.major = major
        self.minor = minor
        self.id = "" // silence the warning

        super.init()
        self.id = generateId()
    }
    
    /**Generate a unique id based on the ibecons paramaters*/
    func generateId()->String{
        return "\(self.UUID)m\(self.major)m\(self.minor)"
    }
    
    
    override var description:String{
        return debugDescription
    }
    
    override var debugDescription:String{
        
        return "\(self.UUID)--\(self.major)--\(self.minor)"
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let minor = self.minor{
            let minorBool = (minor  == (object as! iBeacon).minor)
            if !minorBool {
                return false
            }
        }
        if let major = self.major{
            let minorBool = (major  == (object as! iBeacon).major)
            if !minorBool {
                return false
            }
        }
        
        
        if self.UUID.lowercaseString == object?.UUID.lowercaseString{
            return true
        }
        return false
    }
    
}

/**Used to broadcast NSNotification*/
enum iBeaconNotifications:String{
    case BeaconProximity
    case BeaconState
    case Highlights
    case Location
    case PropertyFound
}


import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var callback:((Bool)->Void)!
    var enabled = false
    override init() {
        super.init()

       self.centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: [CBCentralManagerOptionShowPowerAlertKey:false])
     }
    
    convenience init(callback:(Bool)->Void)
    {
        self.init()
        self.callback = callback

    }
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn{
            enabled = true
            callback(true)
        }
        else{
            enabled = false
            callback(false)
        }
    }

}


/**Interacting with the iBeacons*/
class JMCBeaconManager: NSObject, CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
//    private var beacons = [iBeacon]() // Currently unused
    /**Storing reference to registered regions*/
    private var regions = [CLBeaconRegion]()
    
    var stateCallback:((beacon:iBeacon)->Void)?
    var rangeCallback:((beacon:iBeacon)->Void)?
    var bluetoothManager:BluetoothManager = BluetoothManager()
    
    var logging = true
    var broadcasting = true
    var bluetoothLabel = UILabel(frame: CGRectZero)
    
    
    override init(){
    
        super.init()
        bluetoothManager.callback = bluetoothUpdate
        locationManager.delegate = self
        registerNotifications()
        //locationManager.startUpdatingLocation()
        //test if enabled
    }
    
    
    /**Check Bluetooth*/
    func bluetoothUpdate(status:Bool)->Void{

        if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window {

            if status == true{
                bluetoothLabel.removeFromSuperview()
            }
            else{
                bluetoothLabel.frame = CGRectMake(0, 0, 500, 40)
                bluetoothLabel.center = window.center
            //    bluetoothLabel.text = "PLEASE ENABLE BLUETOOTH"
                bluetoothLabel.font = UIFont.boldSystemFontOfSize(30)
                bluetoothLabel.textColor = UIColor.redColor()

                window.addSubview(bluetoothLabel)
            }
        }
    }
    
    /**Checks if ibeacons are enabled. Should be called first*/
    func statusCheck()->Bool{
        
        locationManager.requestAlwaysAuthorization()
        var check = true
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            if logging {
                print("Error - authorization status not enabled!")
            }
                check = false
            return false
        }
        
        if !CLLocationManager.isMonitoringAvailableForClass(CLRegion){
            check = false
            return false
        }
        return check
    }
    
    
    /**Register Notifications*/
    func registerNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationBackgroundRefreshStatusDidChangeNotification, object: UIApplication.sharedApplication(), queue: nil) { (notification) -> Void in
            if self.statusCheck(){
                self.startMonitoring()
            }
        }
    }
    
    /**Register iBeacons*/
    func registerBeacons(beacons:[iBeacon])
    {
        
        for beacon in beacons{
            
           var beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString:beacon.UUID)!, identifier: beacon.id)
            
            /**Only major infoermation provided*/
            if let major = beacon.major{
                beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString:beacon.UUID)!, major: major, identifier: beacon.id)
            }
            
            /**All the information provided*/
            if let major = beacon.major, minor = beacon.minor{
                beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString:beacon.UUID)!, major: major, minor: minor, identifier: beacon.id)
            }
  
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true

            regions.append( beaconRegion)
         }
    }

    
    /**Register iBeacons*/
    func registerBeacon(beaconId:String)
    {
        
        let bid = CLBeaconRegion(proximityUUID:  NSUUID(UUIDString:beaconId)!, identifier: "Testing Beacon")
        regions.append(bid)
    }

    
    
    /**Starts monitoring beacons*/
    func startMonitoring(){
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter  = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        for beaconRegion in regions{
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startRangingBeaconsInRegion(beaconRegion)
            //FIXME: check if needed [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:beaconRegion afterDelay:1];
            //FIXME: added more validation for the ibeacons permission matrix
        }
    
    }

    /**Starts monitoring beacons*/
    func stopMonitoring(){
        for beaconRegion in regions{
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)          
        }
          locationManager.stopUpdatingLocation()
    }

    
    // MARK: Core Location Delegate
    /*
    *  locationManager:didDetermineState:forRegion:
    *
    *  Discussion:
    *    Invoked when there's a state transition for a monitored region or in response to a request for state via a
    *    a call to requestStateForRegion:.
    */
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion)
    {
        
        //we found a beacon. Now
        if let region = region as? CLBeaconRegion
        {
            if logging {
                print("State determined\(region) \(state.rawValue)")
            }
        }
        
        //we found a beacon. Now
        if let region = region as? CLBeaconRegion, minor = region.minor, major  = region.major{
            
            let beacon = iBeacon(minor: minor.unsignedShortValue, major: major.unsignedShortValue, proximityId: region.proximityUUID.UUIDString)
            beacon.state = state
            
            if logging {
                print("State determined\(region) \(state.rawValue)")
            }
    
            if broadcasting{
                //broadcast notification
                //get beacon from clregion
 
                NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.BeaconState.rawValue, object: beacon)
            }
            
            if let callback = self.stateCallback{
                callback(beacon: beacon)
            }
        }
        //if we are outside stop ranging
        if state == .Outside{
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        }
        if state == .Inside{
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        }
        
        
    }
    /*
    *  locationManager:didRangeBeacons:inRegion:
    *
    *  Discussion:
    *    Invoked when a new set of beacons are available in the specified region.
    *    beacons is an array of CLBeacon objects.
    *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
    *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
    *    by the device.
    */
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        //Notify the delegates and etc that we know how far are we from the iBeacon
        if logging {
            print("Did Range Beacons \(beacons)")
        }
        
        if broadcasting{
        //broadcast notification
        //convert CLBeacon to iBeacon 
        var myBeacons = [iBeacon]()
            //convert it to our iBeacons
            for beacon in beacons{
                if beacon.proximity != .Unknown{
                    let myBeacon = iBeacon(beacon: beacon)
                    myBeacons.append(myBeacon)
                }
            }

        myBeacons.sortInPlace({$0.proximity.sortIndex < $1.proximity.sortIndex})
            
            NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.BeaconProximity.rawValue, object: myBeacons)
        }

        
        for beacon in beacons{
            if logging {
                print("Did Range Beacon \(beacon)")
            }
            if let callback = self.rangeCallback{
                //convert it to the internal type of the beacon
               let ibeacon =  iBeacon(minor: beacon.minor.unsignedShortValue, major: beacon.major.unsignedShortValue, proximityId: beacon.proximityUUID.UUIDString)
                ibeacon.proximity = beacon.proximity
                callback(beacon: ibeacon)
            }
        }
    }
    
    
    /**Update Location*/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            print("Update Location to \(location)")
            NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.Location.rawValue,  object: location)
        }
    }
    
    /*
    *  locationManager:rangingBeaconsDidFailForRegion:withError:
    *
    *  Discussion:
    *    Invoked when an error has occurred ranging beacons in a region. Error types are defined in "CLError.h".
    */

    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    {
        if logging {
            print("Ranging Fail\(region) \(error.debugDescription)")
        }
    }

    
    /*
    *  locationManager:didEnterRegion:
    *
    *  Discussion:
    *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
    *    CLLocationManager instance with a non-nil delegate that implements this method.
    */
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        if region is CLBeaconRegion{
            if logging {
                print("Region Entered! \(region) ")
                manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            }
        }
    }
    /*
    *  locationManager:didExitRegion:
    *
    *  Discussion:
    *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
    *    CLLocationManager instance with a non-nil delegate that implements this method.
    */

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        if region is CLBeaconRegion{
            if logging {
                print("Exit Region! \(region) ")
                manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
            }
        }
    }
    /*
    *  locationManager:didFailWithError:
    *
    *  Discussion:
    *    Invoked when an error has occurred. Error types are defined in "CLError.h".
    */
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
       
            if logging {
                print("Manager Failed with error \(error)")
            }

    }
    /*
    *  locationManager:monitoringDidFailForRegion:withError:
    *
    *  Discussion:
    *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
    */

    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        if logging {
            print("Monitoring Failed with error \(error)")
        }

    }
    /*
    *  locationManager:didChangeAuthorizationStatus:
    *
    *  Discussion:
    *    Invoked when the authorization status changes for this application.
    */

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        
    }
    /*
    *  locationManager:didStartMonitoringForRegion:
    *
    *  Discussion:
    *    Invoked when a monitoring for a region started successfully.
    */
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    {
    
    }
    /*
    *  Discussion:
    *    Invoked when location updates are automatically paused.
    */

    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager)
    {
    
    }
    /*
    *  Discussion:
    *    Invoked when location updates are automatically resumed.
    *
    *    In the event that your application is terminated while suspended, you will
    *	  not receive this notification.
    */
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager)
    {
    
    } 
}
