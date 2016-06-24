# iBeacon
An iBeacon Manager class is responsible for detecting and simulating beacons nearby. 

## Usage

```Swift 
  let beaconManager = JMCBeaconManager()
  
  let kontaktIOBeacon = iBeacon(minor: nil, major: nil, proximityId: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
  let estimoteBeacon = iBeacon(minor: nil, major: nil, proximityId: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
  
  beaconManager.registerBeacons([kontaktIOBeacon, estimoteBeacon])
  
  NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(beaconsRanged(_:)), name: iBeaconNotifications.BeaconProximity.rawValue, object: nil)

  beaconManager.startMonitoring()

  /**Called when the beacons are ranged*/
  func beaconsRanged(notification:NSNotification){
    if let visibleIbeacons = notification.object as? [iBeacon]{
      for beacon in visibleIbeacons{
        /// Do something with the iBeacon
      }
    }
  }  


```
