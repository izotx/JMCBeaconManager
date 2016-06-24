//
//  JMCBeaconManager.swift
//  PerfecTour
//
//  Created by Janusz Chudzynski on 1/30/16.
//  Copyright © 2016 PerfecTour. All rights reserved.

import UIKit
import CoreLocation



/**Used to broadcast NSNotification*/
public enum iBeaconNotifications:String{
    case BeaconProximity
    case BeaconState
    case Location // new location discoverd
    case iBeaconEnabled
    case iBeaconDisabled

}

/**Interacting with the iBeacons*/
public class JMCBeaconManager: NSObject, CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
//    private var beacons = [iBeacon]() // Currently unused
    /**Storing reference to registered regions*/
    private var regions = [CLBeaconRegion]()
    
    var stateCallback:((beacon:iBeacon)->Void)?
    var rangeCallback:((beacon:iBeacon)->Void)?
    var bluetoothManager:BluetoothManager?
    
    var logging = true
    var broadcasting = true
   
    //Different cases
    var bluetoothDisabled = true
 
    /**Error Callback*/
    var errorCallback:((messages:[String])->Void)?
    
    /**Success Callback*/
    var successCallback:(()->Void)?
    
    
    override init(){
    
        super.init()
//        bluetoothManager.callback = bluetoothUpdate
        locationManager.delegate = self
        registerNotifications()
        //locationManager.startUpdatingLocation()
        //test if enabled
    }
    

   
    
    

    /**Starts Monitoring for beacons*/
    func startMonitoring(successCallback:(()->Void), errorCallback:(messages:[String])->Void){
        self.successCallback = successCallback
        self.errorCallback = errorCallback
         checkStatus()
    }
    
    /**Checks the status of the application*/
    func checkStatus(){
        //starts from Bluetooth
        if let _ = self.bluetoothManager{
        
        }
        else{
            bluetoothManager = BluetoothManager()
            bluetoothManager?.callback = bluetoothUpdate
        }
        
    }
    
    
   // var bluetoothManager
    
    /**Check Bluetooth*/
     private func bluetoothUpdate(status:Bool)->Void{
        if status == true{
             bluetoothDisabled = false
            //rund additional status check
            let tuple = statusCheck()
            if tuple.0{
               self.successCallback?()
               NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.iBeaconEnabled.rawValue, object: nil)
               startMonitoring()

            }
            else{
                self.errorCallback?(messages: tuple.messages)
                NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.iBeaconDisabled.rawValue, object: tuple.messages)
            }
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(iBeaconNotifications.iBeaconDisabled.rawValue, object:nil)
            self.errorCallback?(messages: ["Bluetooth not enabled."])
            bluetoothDisabled = true
        }
    }
    
    /**Checks if ibeacons are enabled. Should be called first*/
    private func statusCheck()->(Bool,messages:[String]){
        
        locationManager.requestAlwaysAuthorization()
        var check = true
        var messages = [String]()
        
        if bluetoothDisabled == true
        {
            messages.append("Bluetooth must be turned on.")
            check = false
        }
        
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            if logging {
                print("Error - authorization status not enabled!")
            }
            messages.append("Location Services Must be Authorized.")
            check = false
        }
        
        if !CLLocationManager.isMonitoringAvailableForClass(CLRegion){
            check = false
            messages.append("CLLocationManager monitoring is not enabled on this device.")

        }
    
        return (check, messages)
    }
    //
    
    /**Register Notifications*/
    func registerNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationBackgroundRefreshStatusDidChangeNotification, object: UIApplication.sharedApplication(), queue: nil) { (notification) -> Void in
            
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
        if status == CLAuthorizationStatus.AuthorizedAlways{
            if statusCheck().0 == true {
                startMonitoring()
            }
        }
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
