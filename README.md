# JMCiBeaconManager

[![Version](https://img.shields.io/cocoapods/v/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)
[![License](https://img.shields.io/cocoapods/l/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)
[![Platform](https://img.shields.io/cocoapods/p/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![alt tag](https://github.com/appzzman/JMCBeaconManager/blob/pr/1/iPadGif.gif)
![alt tag](https://raw.githubusercontent.com/appzzman/JMCBeaconManager/pr/1/iPhoneGif.gif)

## Requirements

## Installation

JMCiBeaconManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JMCiBeaconManager"
```

## Authors

Janusz Chudzynski, <jchudzynski@uwf.edu>

Felipe N. Brito, <felipenevesbrito@gmail.com>

## License

JMCiBeaconManager is available under the MIT license. See the LICENSE file for more info.


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