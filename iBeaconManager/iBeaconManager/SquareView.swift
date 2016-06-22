//
//  SquareView.swift
//  Animation
//
//  Created by Felipe on 6/20/16.
//  Copyright © 2016 Academic Technology Center. All rights reserved.
//

import UIKit
import CoreLocation

class SquareView: UIView, UIGestureRecognizerDelegate{


    var ranges : [CLProximity : DistanceRange] = [:]
    var speed = 0.005
    
    
    override func drawRect(rect: CGRect) {

        drawCanvas()
    }
    
    func handleTap(point: CGPoint, completion: (beacon: iBeacon?) -> Void) {
        
        for range in ranges.values{
            
            for beacon in range.beacons{
            
                if beacon.point.x <= point.x + 20 && beacon.point.x >= point.x - 20{
                    if beacon.point.y <= point.y + 20 && beacon.point.y >= point.y - 20{
                        completion(beacon: beacon.beacon)
                    }
                }
            }
        }
        
        completion(beacon: nil)
    }
    
    func drawCanvas(){
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
    
        drawRange(center, distance: .Unknown)
        drawRange(center, distance: .Far)
        drawRange(center, distance: .Near)
        drawRange(center, distance: .Immediate)

    }
    
       
    func drawRange(center: CGPoint, distance: CLProximity){
        
        var radius = CGFloat(self.bounds.width/2)
        var color = UIColor.grayColor()
        
        if distance == .Far {
            radius -= 50
            color = UIColor.greenColor()
        }else if distance == .Near {
            radius -= 100
            color = UIColor.blueColor()
        }else if distance == .Immediate {
            radius -= 150
            color = UIColor.redColor()
        }
        
        let area = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = area.CGPath
        
     
        shapeLayer.fillColor = color.CGColor
       
        shapeLayer.strokeColor = color.CGColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        
        let range = DistanceRange()
        range.shapeLayer = shapeLayer
        range.type = distance
        range.radius = radius
        
        self.ranges[distance] = range
        
        self.layer.addSublayer(shapeLayer)
    }

    
    func addBeacon(beacon: iBeacon){
        
        for range in ranges.values{
            var index = 0
            for beaconShape in range.beacons{
            
                if beaconShape.beacon.id == beacon.id {
                    
                    if beaconShape.beacon.proximity == beacon.proximity{
                        return
                    }else {
                        range.beacons.removeAtIndex(index)
                    }
                    
                    
                }
                index += 1
            }
        }
        
        let beaconShape = BeaconShape()
        beaconShape.beacon = beacon
        beaconShape.speed = speed
        ranges[beacon.proximity]?.beacons.append(beaconShape)
        
        let count = ranges[beacon.proximity]?.beacons.count
        
        var t = CGFloat(0)
        
        if count != nil{
            t = CGFloat(2 * M_PI) / CGFloat(count!)
        }
        
        let rand = Float(2) * Float(Float(arc4random()) / Float(UInt32.max))
        
        /// Calculates equal distances beetween beacons
        var index = 0
        for beaconShape in (ranges[beacon.proximity]?.beacons)! {
            
            beaconShape.t = (t * CGFloat(index)) //+ CGFloat(rand)
            index += 1
            
            var max = 25
            
            if beacon.proximity == .Immediate {
                max = 4
            }else if beacon.proximity == .Near{
                max = 10
            }else if beacon.proximity == .Far {
                max = 18
            }
            
            if count > max {
                let circunference = CGFloat(2 * M_PI)  * ranges[beacon.proximity]!.radius
                 beaconShape.radius = (circunference) / CGFloat(3 * count!)
            }
        }
    }
    
    func calculateBorderPoint(radius: CGFloat, center: CGPoint, t: CGFloat) -> CGPoint{
        
        let x = center.x + radius * cos(t)
        let y = center.y + radius * sin(t)
    
        return CGPoint(x: x, y: y)
    }
    
    
    func moveBeacons(){
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        for range in ranges.values{
        
            for beaconShape in range.beacons{
                
                if beaconShape.shapeLayer != nil{
                    beaconShape.shapeLayer.removeFromSuperlayer()
                }
                
                beaconShape.speed = speed
                
                let position = calculateBorderPoint(range.radius, center: center, t: beaconShape.nextT())
                
                let shape = UIBezierPath(arcCenter: position, radius: beaconShape.radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = shape.CGPath
                
                
                shapeLayer.fillColor = UIColor.yellowColor().CGColor
                shapeLayer.strokeColor = UIColor.yellowColor().CGColor
                shapeLayer.lineWidth = 3.0
                
                beaconShape.shapeLayer = shapeLayer
                beaconShape.point = position
                
                self.layer.addSublayer(shapeLayer)

            }
        }
        
    }
}

class BeaconShape {
    
    var shapeLayer : CAShapeLayer!
    var id = ""
    var beacon:iBeacon!
    var speed = 0.0
    /// t is a parametric variable in the range 0 to 2π, interpreted geometrically as the angle that the ray from (a, b) to (x, y) makes with the positive x-axis.
    var t : CGFloat = 0
    var distance: CLProximity!
    
    var point: CGPoint!
    var radius: CGFloat = 20
    
    
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


class DistanceRange{
    var type : CLProximity!
    var beacons : [BeaconShape] = []
    var shapeLayer : CAShapeLayer!
    var radius: CGFloat!
}







