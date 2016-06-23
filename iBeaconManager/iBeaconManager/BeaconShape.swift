//
//  BeaconShape.swift
//  iBeaconManager
//
//  Created by Felipe on 6/23/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconShape {
    
    var shapeLayer : CAShapeLayer!
    var id = ""
    var beacon:iBeacon!
    var speed = 0.0
    
    /// t is a parametric variable in the range 0 to 2π, interpreted geometrically as the angle that the ray from (a, b) to (x, y) makes with the positive x-axis.
    var t : CGFloat = 0
    
    var blink = false
    
    var distance: CLProximity!
    
    var point: CGPoint!
    var radius: CGFloat = 15
    
    var color = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000)
    
    
    /// Increments the t value according to the speed
    func nextT() -> CGFloat{
        
        var s = speed
        
        if distance == CLProximity.Unknown{
            s  += speed * 0.35
        }
        
        if distance == CLProximity.Far{
            s  +=   speed * 0.25
        }
        if distance == CLProximity.Near{
            s  += speed * 0.12
        }
        
        t += CGFloat(s)
        
        if t > CGFloat(2 * M_PI){
            t = 0
        }
        
        return t
    }
}