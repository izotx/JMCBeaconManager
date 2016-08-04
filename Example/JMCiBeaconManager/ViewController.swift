//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Janusz Chudzynski on 6/21/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import JMCiBeaconManager
import UIKit
import CoreLocation


class ViewController: UIViewController{
    
    /// label to show the seleced beacon's id
    @IBOutlet var beaconIDLabel: UILabel!

    
    /// RadarView
    @IBOutlet var radarView: JMCRadarView!


    
    
    var beaconsDate: [String:NSDate] = [:]
    var beacons : [String:iBeacon] = [:]
    
    //New instance
    let beaconManager = JMCBeaconManager()
    override func viewDidLoad() {
        
        beaconIDLabel.textColor = UIColor.whiteColor()
        
        self.view.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(beaconsRanged(_:)), name: iBeaconNotifications.BeaconProximity.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(beaconTaped(_:)), name: JMCRadarNotifications.BeaconTapped.rawValue, object: nil)

        startMonitoring()
        
        
//        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.addBeacon), userInfo: nil, repeats: false)
//        
//        NSTimer.scheduledTimerWithTimeInterval(5.5, target: self, selector: #selector(ViewController.addBeacon2), userInfo: nil, repeats: false)
    }
    
    func addBeacon(){
        
        let testBeacon = iBeacon(minor: 255, major: 255, proximityId: "Test1")
        testBeacon.proximity = CLProximity.Far
        testBeacon.id = "test1"
        radarView.addBeacon(testBeacon)
    }
    
    func addBeacon2(){
        
        let testBeacon2 = iBeacon(minor: 255, major: 255, proximityId: "Test2")
        testBeacon2.proximity = .Near
        testBeacon2.id = "test2"
        radarView.addBeacon(testBeacon2)
    }

    
    //MARK: notifications
    func beaconsEnabled(notification:NSNotification){
        ///Wait for notificatio
        
        // Removes old beacons
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ViewController.removeOldBeacons), userInfo: nil, repeats: true)

    }
    
    func beaconTaped(notification: NSNotification) {
        print("Notification Received \(notification.object)")
        if let beacon = notification.object as? iBeacon{
            beaconIDLabel.text = beacon.id
        }
    }

    func beaconsDisabled(notification:NSNotification){
        
    }

    
    /**Called when the beacons are ranged*/
    func beaconsRanged(notification:NSNotification){
        if let visibleIbeacons = notification.object as? [iBeacon]
        {
            for beacon in visibleIbeacons{
                self.radarView.addBeacon(beacon)
                beaconsDate[beacon.id] = NSDate()
                beacons[beacon.id] = beacon
                print(NSDate().description)
            }
        }
    }
    
   
    
    func startMonitoring(){
        //check if enabled
        // beaconManager.registerBeacon("f7826da6-4fa2-4e98-8024-bc5b71e0893e")
       
        let kontaktIOBeacon = iBeacon(minor: nil, major: nil, proximityId: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let estimoteBeacon = iBeacon(minor: nil, major: nil, proximityId: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        
      
        //major 2505 minor 36274
        beaconManager.registerBeacons([kontaktIOBeacon, estimoteBeacon])
        
        beaconManager.startMonitoring({ 
            
            }) { (messages) in
                    print("Error Messages \(messages)")
        }
        
        
        /**updates user's visited places information*/
        func stateCallback(beacon:iBeacon)->Void{
            //FIXME - unused
        }
        
        /**updates user's visited places information*/
        func rangeCallback (beacon:iBeacon)->Void{
            //FIXME - unused
        }
        
        beaconManager.stateCallback = stateCallback
        beaconManager.rangeCallback = rangeCallback
        
        beaconManager.logging = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeOldBeacons(){
        
        for id in beaconsDate.keys{
            
            let now = NSDate()
            let beaconDate = beaconsDate[id]
            let date = beaconDate?.addSeconds(4)
            
            if date!.isLessThanDate(now) {
                radarView.removeBeacon(beacons[id]!)
                beacons.removeValueForKey(id)
                beaconsDate.removeValueForKey(id)
            }
        }
    }
}

extension NSDate {
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        return dateWithHoursAdded
    }
    
    func addSeconds(secondsToAdd: Int) -> NSDate {
        let seconds: NSTimeInterval = Double(secondsToAdd)
        let dateWithSecondsAdded: NSDate = self.dateByAddingTimeInterval(seconds)
        
        return dateWithSecondsAdded
    }
}

