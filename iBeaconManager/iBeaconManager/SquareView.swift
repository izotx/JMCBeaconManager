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

    /// Stores a dictionary with the possible ranges (near, far, immediate....)
    var ranges : [CLProximity : DistanceRange] = [:]
    
    var radarShape: RadarShape!
    
    /// iBeacon Shape Spinning speed
    var speed = 0.005
    
    
    var selectedBeacon: BeaconShape?
    
    override func drawRect(rect: CGRect) {
                
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        /// Draws the ranges for Unknown, Far, Near, Immediate
        drawGradient(center, distance: .Unknown)
        drawRange(center, distance: .Unknown)
        drawRange(center, distance: .Far)
        drawRange(center, distance: .Near)
        drawRange(center, distance: .Immediate)
        drawGradientRange(center, radius: self.bounds.width/2)
        
        drawRadar(center)
        
        drawLines(center, radius: self.bounds.width/2)

        
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("rotateRadar"), userInfo: nil, repeats: true)
            
        
    }
    
    func handleTap(point: CGPoint, completion: (beacon: iBeacon?) -> Void) {
        
        for range in ranges.values{
            
            for beacon in range.beacons{
            
                // Calculates a margin of error since the beacons are moving
                if beacon.point.x <= point.x + 30 && beacon.point.x >= point.x - 30{
                    if beacon.point.y <= point.y + 30 && beacon.point.y >= point.y - 30{
                        self.selectedBeacon = beacon
                        completion(beacon: beacon.beacon)
                    }
                }
            }
        }
        // nothing to do...
        completion(beacon: nil)
    }
    
    func drawRadar(center: CGPoint){
        var radius = CGFloat(self.bounds.width/2)
        var color = UIColor.greenColor()
        
        
        self.radarShape = RadarShape()
        
        var startAngle = degreesToRad(radarShape.nextStartAngle())
        var endAngle = degreesToRad(radarShape.nextEndAngle())
        
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: center.x, y: center.y), radius: self.frame.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: center.x, y: center.y))
        ovalPath.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.CGPath
        shapeLayer.fillColor = UIColor(red:0.44, green:0.71, blue:0.44, alpha:1.0).CGColor//UIColor.redColor().CGColor
        shapeLayer.strokeColor = UIColor(red:0.44, green:0.71, blue:0.44, alpha:1.0).CGColor//UIColor.redColor().CGColor
        shapeLayer.lineWidth = 3.0
        
        self.radarShape.shapeLayer = shapeLayer
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func rotateRadar(){
        
        _ = CGFloat(self.bounds.width/2)
        _ = UIColor.greenColor()
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        self.radarShape.shapeLayer.removeFromSuperlayer()
        
        let startAngle = degreesToRad(radarShape.nextStartAngle())
        let endAngle = degreesToRad(radarShape.nextEndAngle())
        
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: center.x, y: center.y), radius: self.frame.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: center.x, y: center.y))
        ovalPath.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.CGPath
        shapeLayer.fillColor = UIColor(red: 0.291, green: 0.958, blue: 0.024, alpha: 0.265).CGColor
        shapeLayer.strokeColor = UIColor(red: 0.291, green: 0.958, blue: 0.024, alpha: 0.265).CGColor
        shapeLayer.lineWidth = 3.0
        
        
        self.radarShape.shapeLayer = shapeLayer
        
        self.layer.addSublayer(shapeLayer)

    
    }
    
    func degreesToRad(degrees: CGFloat) -> CGFloat{
        return degrees * CGFloat(M_PI / 180)
    }
    
    func drawGradientRange(center: CGPoint, radius: CGFloat){
    
        
        //// Color Declarations
        let gradientColor3 = UIColor(red: 0.088, green: 0.671, blue: 0.012, alpha: 1.000)
        let gradientColor4 = UIColor(red: 0.037, green: 0.283, blue: 0.002, alpha: 0.498)
        let gradientColor5 = UIColor(red: 0.038, green: 0.286, blue: 0.002, alpha: 0.000)
        
        
        let ovalPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.CGPath
        shapeLayer.fillColor = UIColor.greenColor().CGColor
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        shapeLayer.lineWidth = 3.0
        

        
        let gradient = CAGradientLayer()
        
        gradient.colors = [gradientColor3.CGColor, gradientColor4.CGColor, gradientColor5.CGColor]
        gradient.locations = [0.01, 0.8, 0.5]
        gradient.mask = shapeLayer
        
//        
//        CGContextSaveGState(context)
//        ovalPath.addClip()
//        CGContextDrawRadialGradient(context, radialGradient3927,
//                                    CGPoint(x: 248.03, y: 251.82), 0,
//                                    CGPoint(x: 248.03, y: 251.82), 232.94,
//                                    [CGGradientDrawingOptions.DrawsBeforeStartLocation, CGGradientDrawingOptions.DrawsAfterEndLocation])
//        CGContextRestoreGState(context)
        
        self.layer.addSublayer(gradient)
    
    }
    
    func drawLines(center: CGPoint, radius: CGFloat){
        
        let lines = 12
    
        //// Color Declarations
        let strokeColor3 = UIColor(red: 0.094, green: 0.717, blue: 0.013, alpha: 1.000)
        let fillColor2 = UIColor(red: 0.135, green: 1.000, blue: 0.025, alpha: 1.000)
        
        //// layer1
        
        for index in Range(0...lines){
            
            let degrees = ( 360.0 / CGFloat(lines) ) * CGFloat(index)
            
            let t = degreesToRad(degrees)
            
            let border = calculateBorderPoint(radius, center: center, t: t)
            
            let path1 = UIBezierPath()
            path1.moveToPoint(center)
            path1.addLineToPoint(border)
            path1.miterLimit = 4;
            
            fillColor2.setFill()
            path1.fill()
            strokeColor3.setStroke()
            path1.lineWidth = 0.5
            path1.stroke()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path1.CGPath
            
            
            shapeLayer.fillColor = fillColor2.CGColor
            shapeLayer.strokeColor = strokeColor3.CGColor
            shapeLayer.lineWidth = 1.5
            
            self.layer.addSublayer(shapeLayer)
        
        
        }
    }
    
    func drawGradient(center: CGPoint, distance: CLProximity){
        
        var radius = CGFloat(self.bounds.width/2)
        var color = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        // Calculates the range for each proximity and selesct the color
        if distance == .Far {
            radius -= 50
            //color = UIColor.greenColor()
        }else if distance == .Near {
            radius -= 100
            //color = UIColor.blueColor()
        }else if distance == .Immediate {
            radius -= 150
            //color = UIColor.redColor()
        }
        
        let area = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        area.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = area.CGPath
        
        
        shapeLayer.fillColor = color.CGColor
        shapeLayer.strokeColor = UIColor(red: 0.123, green: 0.939, blue: 0.021, alpha: 0.758).CGColor
        shapeLayer.lineWidth = 3.0
        
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        let gradientColor3 = UIColor(red: 0.088, green: 0.671, blue: 0.012, alpha: 1.000)
        let gradientColor4 = UIColor(red: 0.037, green: 0.283, blue: 0.002, alpha: 0.498)
        let gradientColor5 = UIColor(red: 0.038, green: 0.286, blue: 0.002, alpha: 0.000)
        
        gradient.colors = [gradientColor4.CGColor, gradientColor3.CGColor, gradientColor4.CGColor]
        gradient.frame = self.bounds
        //        gradient.locations = [0.0 , 1.0]
        //        gradient.startPoint = center
        //        gradient.endPoint = center
        //        gradient.frame = CGRect(x: center.x, y: center.y, width: radius, height: radius)
        //
        gradient.mask = shapeLayer
        
        
        /// Builds the DistanceRange Object and saves to the ranges dictionary
        let range = DistanceRange()
        range.shapeLayer = shapeLayer
        range.type = distance
        range.radius = radius
        
        self.ranges[distance] = range
        
        self.layer.addSublayer(gradient)
    }
    
       
    func drawRange(center: CGPoint, distance: CLProximity){
        
        var radius = CGFloat(self.bounds.width/2)
        var color = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        // Calculates the range for each proximity and selesct the color
        if distance == .Far {
            radius -= 50
            //color = UIColor.greenColor()
        }else if distance == .Near {
            radius -= 100
            //color = UIColor.blueColor()
        }else if distance == .Immediate {
            radius -= 150
            //color = UIColor.redColor()
        }
        
        let area = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        area.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = area.CGPath
        
     
        shapeLayer.fillColor = UIColor.clearColor().CGColor//color.CGColor
        shapeLayer.strokeColor = UIColor(red: 0.123, green: 0.939, blue: 0.021, alpha: 0.758).CGColor
        shapeLayer.lineWidth = 3.0
        
        
        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        
//        let gradientColor3 = UIColor(red: 0.088, green: 0.671, blue: 0.012, alpha: 1.000)
//        let gradientColor4 = UIColor(red: 0.037, green: 0.283, blue: 0.002, alpha: 0.498)
//        let gradientColor5 = UIColor(red: 0.038, green: 0.286, blue: 0.002, alpha: 0.000)
//
//        gradient.colors = [gradientColor3.CGColor, gradientColor4.CGColor, gradientColor5.CGColor]
//        gradient.frame = self.bounds
////        gradient.locations = [0.0 , 1.0]
////        gradient.startPoint = center
////        gradient.endPoint = center
////        gradient.frame = CGRect(x: center.x, y: center.y, width: radius, height: radius)
////        
//        gradient.mask = shapeLayer
        
        
        /// Builds the DistanceRange Object and saves to the ranges dictionary
        let range = DistanceRange()
        range.shapeLayer = shapeLayer
        range.type = distance
        range.radius = radius
        
        self.ranges[distance] = range
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func removeBeacon(beacon: iBeacon){
        // Checks if the beacon already exists
        for range in ranges.values{
            var index = 0
            for beaconShape in range.beacons{
                
                if beaconShape.beacon.isEqual(beacon) {
                    
                    if range.beacons[index].shapeLayer != nil{
                        range.beacons[index].shapeLayer.removeFromSuperlayer()
                    }
                        
                    range.beacons.removeAtIndex(index)
                    break
                }
                index += 1
            }
        }
    }

    
    func addBeacon(beacon: iBeacon){
        
        
        // Checks if the beacon already exists
        for range in ranges.values{
            var index = 0
            for beaconShape in range.beacons{
            
                if beaconShape.beacon.isEqual(beacon) {
                    
                    if beaconShape.beacon.proximity == beacon.proximity{
                        return
                    }else {
                        
                        if range.beacons[index].shapeLayer != nil{
                           range.beacons[index].shapeLayer.removeFromSuperlayer()
                        }
                        
                        range.beacons.removeAtIndex(index)
                    }
                }
                index += 1
            }
        }
        
        /// Build BeaconShape object
        let beaconShape = BeaconShape()
        beaconShape.beacon = beacon
        beaconShape.speed = speed
        ranges[beacon.proximity]?.beacons.append(beaconShape)   // adds to the data structure
        
        let count = ranges[beacon.proximity]?.beacons.count
        
        
        /// Calculates equal distances beetween beacons
        var t = CGFloat(0)

        if count != nil{
            t = CGFloat(2 * M_PI) / CGFloat(count!)
        }
        //let rand = Float(2) * Float(Float(arc4random()) / Float(UInt32.max))
        var index = 0
        for beaconShape in (ranges[beacon.proximity]?.beacons)! {
            
            beaconShape.t = (t * CGFloat(index)) //+ CGFloat(rand)
            index += 1
            
            
            /// The max number of beacons before resizing
            var max = 25
            
            if beacon.proximity == .Immediate {
                max = 4
            }else if beacon.proximity == .Near{
                max = 10
            }else if beacon.proximity == .Far {
                max = 18
            }
            
            /// Resizes all beacon of the distance layer if there is more than max
            if count > max {
                let circunference = CGFloat(2 * M_PI)  * ranges[beacon.proximity]!.radius
                 beaconShape.radius = (circunference) / CGFloat(3 * count!)
            }
        }
    }
    
    /// Calculates a specific x and y that is on the range border
    func calculateBorderPoint(radius: CGFloat, center: CGPoint, t: CGFloat) -> CGPoint{
        
        let x = center.x + radius * cos(t)
        let y = center.y + radius * sin(t)
    
        return CGPoint(x: x, y: y)
    }
    
    
    func moveBeacons(){
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        /// For each proximity range
        for range in ranges.values{
        
            for beaconShape in range.beacons{
                
                ///Removes the beacon from screen
                if beaconShape.shapeLayer != nil{
                    beaconShape.shapeLayer.removeFromSuperlayer()
                }
                
                // Updates the beacon shape speed
                beaconShape.speed = speed
                
                // calculates a new position
                let position = calculateBorderPoint(range.radius, center: center, t: beaconShape.nextT())
                
                // builds a new shape
                let shape = UIBezierPath(arcCenter: position, radius: beaconShape.radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = shape.CGPath
                
                if selectedBeacon != nil && (selectedBeacon?.beacon.isEqual(beaconShape.beacon))!{
                    shapeLayer.fillColor = UIColor.blueColor().CGColor
                    shapeLayer.strokeColor = UIColor.blueColor().CGColor
                }else{
                    shapeLayer.fillColor = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000).CGColor
                    shapeLayer.strokeColor = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000).CGColor
                }
                
//                shapeLayer.fillColor = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000).CGColor
//                shapeLayer.strokeColor = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000).CGColor
                shapeLayer.lineWidth = 1.0
                
                beaconShape.shapeLayer = shapeLayer
                beaconShape.point = position
                
                // re adds the shape to screen
                self.layer.addSublayer(shapeLayer)

            }
        }
    }
}

class RadarShape{
    
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


class DistanceRange{
    var type : CLProximity!
    var beacons : [BeaconShape] = []
    var shapeLayer : CAShapeLayer!
    var radius: CGFloat!
}








