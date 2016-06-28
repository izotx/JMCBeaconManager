# JMCiBeaconManager
> An iBeacon Manager class that is responsible for detecting beacons nearby. 🔶

[![Version](https://img.shields.io/cocoapods/v/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)
[![License](https://img.shields.io/cocoapods/l/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)
[![Platform](https://img.shields.io/cocoapods/p/JMCiBeaconManager.svg?style=flat)](http://cocoapods.org/pods/JMCiBeaconManager)

![alt tag](https://github.com/appzzman/JMCBeaconManager/blob/pr/1/iPadGif.gif)
![alt tag](https://raw.githubusercontent.com/appzzman/JMCBeaconManager/pr/1/iPhoneGif.gif)


## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

#### CocoaPods
JMCiBeaconManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JMCiBeaconManager"
```

#### Manually
1. Download and drop ```/JMCiBeaconManager```folder in your project.  
2. Congratulations! 


## Usage

```Swift 
import JMCiBeaconManager

let beaconManager = JMCBeaconManager()

let kontaktIOBeacon = iBeacon(minor: nil, major: nil, proximityId: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
let estimoteBeacon = iBeacon(minor: nil, major: nil, proximityId: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")

beaconManager.registerBeacons([kontaktIOBeacon, estimoteBeacon])

NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(beaconsRanged(_:)), name: iBeaconNotifications.BeaconProximity.rawValue, object: nil)

beaconManager.startMonitoring({ 
            
    }) { (messages) in
        print("Error Messages \(messages)")
}

/**Called when the beacons are ranged*/
func beaconsRanged(notification:NSNotification){
    if let visibleIbeacons = notification.object as? [iBeacon]{
        for beacon in visibleIbeacons{
            /// Do something with the iBeacon
        }
    }
}  


```

## Authors

Janusz Chudzynski, <janusz@izotx.com>

Felipe N. Brito, <felipenevesbrito@gmail.com>

## Contribute

We would love for you to contribute to **JMCiBeaconManager**, check the ``LICENSE`` file for more info.

## Requirements

- iOS 8.0+
- Xcode 7.3

## License

JMCiBeaconManager is available under the ```BSD``` license. See the ```LICENSE``` file for more info.

