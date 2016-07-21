//  Copyright (c) 2016, Janusz Chudzynski - Felipe Neves Brito
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of  nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

//
//  DataStructures.swift
//  iBeaconManager
//
//  Created by Janusz Chudzynski on 6/21/16.


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
    
    /// iBeacon Minor
    public let minor:UInt16?
    
    /// iBeacon Major
    public let major:UInt16?
    
    /// Internal name - it will be used by firebase
    private(set) public var id:String
    
    /// Human readable id
    private(set) public var readeableId:String = ""
    
    /// iBeacon UUID
    public let UUID: String
    
    
    /// Default proximity
    internal(set) public var proximity: CLProximity  = CLProximity.Unknown
    
    
    /// Default state
    internal(set) public var state:CLRegionState = CLRegionState.Unknown
    
    
    
    public init(beacon:CLBeacon) {
        self.UUID = beacon.proximityUUID.UUIDString
        self.minor = beacon.minor.unsignedShortValue
        self.major = beacon.major.unsignedShortValue
        self.id = ""
        self.proximity = beacon.proximity
        super.init()
        self.id = generateId()
    }
    
    /**Initializer*/
    public init(minor:UInt16?, major:UInt16?, proximityId:String){
        
        self.UUID = proximityId
        self.major = major
        self.minor = minor
        self.id = "" // silence the warning
        
        super.init()
        self.id = generateId()
    }
    
    
    /**Initializer*/
    public init(minor:UInt16?, major:UInt16?, proximityId:String, id:String){
        
        self.UUID = proximityId
        self.major = major
        self.minor = minor
        self.id = id
        super.init()
    }
    
    /**
     
     Generate a unique id based on the iBecon's paramaters
     
     - Returns: A Unique ID
     */
    func generateId() -> String {
        return "\(self.UUID)m\(self.major)m\(self.minor)"
    }
    
    override public var description:String {
        return debugDescription
    }
    
    override public var debugDescription:String{
        
        return "\(self.UUID)--\(self.major)--\(self.minor)"
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        
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
