//
//  RadarScannerShape.swift
//  iBeaconManager
//
//  Created by Felipe on 6/23/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import UIKit

class RadarScannerShape{
    
    var speed: CGFloat = 1.0
    
    var shapeLayer : CAShapeLayer!
    var startAngle : CGFloat = 0.0
    var endAngle : CGFloat = 60.0
    
    
    func nextStartAngle() -> CGFloat{
        startAngle += speed
        startAngle = startAngle % 360.0
        return startAngle
    }
    
    func nextEndAngle() -> CGFloat{
        
        endAngle += speed
        endAngle = endAngle % 360.0
        return endAngle
    }
}