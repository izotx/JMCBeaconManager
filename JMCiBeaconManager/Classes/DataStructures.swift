//
//  DataStructures.swift
//  iBeaconManager
//
//  Created by Janusz Chudzynski on 6/21/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import Foundation
import CoreLocation

public extension CLProximity {
    var sortIndex : Int {
        switch self {
        case .Immediate:
            return 0
        case .Near:
            return 1
        case .Far:
            return 2
        case .Unknown:
            return 3
        }
    }
}

/**iBeacon*/
public class iBeacon : NSObject {
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
