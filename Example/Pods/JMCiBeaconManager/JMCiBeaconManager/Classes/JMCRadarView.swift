//
//  SquareView.swift
//  Animation
//
//  Created by Felipe on 6/20/16.
//  Copyright © 2016 Academic Technology Center. All rights reserved.
//

import UIKit
import CoreLocation

public enum JMCRadarNotifications : String{
    case BeaconTapped
}

public class JMCRadarView: UIView, UIGestureRecognizerDelegate, PWDisplayLinkerDelegate{
    
    var displayLinker: PWDisplayLinker!
    var tap : UITapGestureRecognizer!
    
    /// Stores a dictionary with the possible ranges (near, far, immediate....)
    var ranges : [CLProximity : DistanceRange] = [:]
    
    /// Stores the radar's scanner shape
    var radarScannerShape: RadarScannerShape!
    
    /// iBeacon Shape Spinning speed
    var speed = 0.005
    
    /// Current selecter beacon
    var selectedBeacon: BeaconShape?
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.displayLinker = PWDisplayLinker(delegate: self)
        
        //Tap gesture
        tap = UITapGestureRecognizer(target: self, action: #selector(JMCRadarView.handleTap(_:)))
        tap.delegate = self
        
        backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        print("tapped")
        if sender != nil{
            
            let point = sender!.locationInView(self)
            for range in ranges.values{
                
                for beacon in range.beacons{
                    
                    // Calculates a margin of error since the beacons are moving
                    if beacon.point.x <= point.x + 30 && beacon.point.x >= point.x - 30{
                        if beacon.point.y <= point.y + 30 && beacon.point.y >= point.y - 30{
                            self.selectedBeacon = beacon
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(JMCRadarNotifications.BeaconTapped.rawValue, object: beacon)
                        }
                    }
                }
            }
        }
    }
    
    
    public override func drawRect(rect: CGRect) {
        
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        // Draws the gradient effect
        drawGradient(center, distance: .Unknown)
        
        // Draws the ranges for Unknown, Far, Near, Immediate
        drawRange(center, distance: .Unknown)
        drawRange(center, distance: .Far)
        drawRange(center, distance: .Near)
        drawRange(center, distance: .Immediate)
        
        
        // Draws the radar's scanner
        drawRadarScanner(center)
        
        // Draws the radar's lines
        drawLines(center, radius: self.bounds.width/2)
        
        // Rotates the radar's scanner every 0.01 seconds
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(JMCRadarView.rotateRadar), userInfo: nil, repeats: true)
    }
    
    func drawRadarScanner(center: CGPoint){
        
        self.radarScannerShape = RadarScannerShape()
        
        // Calculates the angles
        let startAngle = degreesToRad(radarScannerShape.nextStartAngle())
        let endAngle = degreesToRad(radarScannerShape.nextEndAngle())
        
        //Draws the path
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: center.x, y: center.y), radius: self.frame.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: center.x, y: center.y))
        ovalPath.closePath()
        
        // Created the shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.CGPath
        shapeLayer.fillColor = UIColor(red:0.44, green:0.71, blue:0.44, alpha:1.0).CGColor//UIColor.redColor().CGColor
        shapeLayer.strokeColor = UIColor(red:0.44, green:0.71, blue:0.44, alpha:1.0).CGColor//UIColor.redColor().CGColor
        shapeLayer.lineWidth = 3.0
        
        self.radarScannerShape.shapeLayer = shapeLayer
        self.layer.addSublayer(shapeLayer)
    }
    
    func rotateRadar(){
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        self.radarScannerShape.shapeLayer.removeFromSuperlayer()
        
        let startAngle = degreesToRad(radarScannerShape.nextStartAngle())
        let endAngle = degreesToRad(radarScannerShape.nextEndAngle())
        
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: center.x, y: center.y), radius: self.frame.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: center.x, y: center.y))
        ovalPath.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.CGPath
        shapeLayer.fillColor = UIColor(red: 0.291, green: 0.958, blue: 0.024, alpha: 0.265).CGColor
        shapeLayer.strokeColor = UIColor(red: 0.291, green: 0.958, blue: 0.024, alpha: 0.265).CGColor
        shapeLayer.lineWidth = 3.0
        
        
        self.radarScannerShape.shapeLayer = shapeLayer
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func degreesToRad(degrees: CGFloat) -> CGFloat{
        return degrees * CGFloat(M_PI / 180)
    }
    
    func drawLines(center: CGPoint, radius: CGFloat){
        
        let lines = 12
    
        // Color Declarations
        let strokeColor = UIColor(red: 0.094, green: 0.717, blue: 0.013, alpha: 1.000)
        let fillColor = UIColor(red: 0.135, green: 1.000, blue: 0.025, alpha: 1.000)
        
        
        // For each line
        for index in Range(0...lines){
            
            // calculates the line's degree ( 0 to 360)
            let degrees = ( 360.0 / CGFloat(lines) ) * CGFloat(index)
            
            let t = degreesToRad(degrees)
            
            let border = calculateBorderPoint(radius, center: center, t: t)
            
            let path1 = UIBezierPath()
            path1.moveToPoint(center)
            path1.addLineToPoint(border)
            path1.miterLimit = 4;
            
            fillColor.setFill()
            path1.fill()
            strokeColor.setStroke()
            path1.lineWidth = 0.5
            path1.stroke()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path1.CGPath
            
            
            shapeLayer.fillColor = fillColor.CGColor
            shapeLayer.strokeColor = strokeColor.CGColor
            shapeLayer.lineWidth = 1.5
            
            self.layer.addSublayer(shapeLayer)
        }
    }
    
    func drawGradient(center: CGPoint, distance: CLProximity){
        
        var radius = CGFloat(self.bounds.width/2)
        let color = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
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
        
        gradient.colors = [gradientColor4.CGColor, gradientColor3.CGColor, gradientColor4.CGColor]
        gradient.frame = self.bounds
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
        
        // Calculates the range for each proximity
        if distance == .Far {
            radius -= radius * 0.25
        }else if distance == .Near {
            radius -= radius * 0.50
        }else if distance == .Immediate {
            radius -= radius * 0.75
        }
        
        let area = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        area.closePath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = area.CGPath
        
     
        shapeLayer.fillColor = UIColor.clearColor().CGColor//color.CGColor
        shapeLayer.strokeColor = UIColor(red: 0.123, green: 0.939, blue: 0.021, alpha: 0.758).CGColor
        shapeLayer.lineWidth = 3.0
        
        /// Builds the DistanceRange Object and saves to the ranges dictionary
        let range = DistanceRange()
        range.shapeLayer = shapeLayer
        range.type = distance
        range.radius = radius
        
        self.ranges[distance] = range
        
        self.layer.addSublayer(shapeLayer)
    }
    
    public func removeBeacon(beacon: iBeacon){
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

    
    public func addBeacon(beacon: iBeacon){
        
        
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
             //    shapeLayer.contentsScale = UIScreen.mainScreen().scale
            //    print(UIScreen.mainScreen().scale)

                shapeLayer.path = shape.CGPath
                
                if selectedBeacon != nil && (selectedBeacon?.beacon.isEqual(beaconShape.beacon))!{
                    shapeLayer.fillColor = UIColor(red: 0.5, green: 1.000, blue: 0.10, alpha: 1.000).CGColor
                    shapeLayer.strokeColor = UIColor(red: 0.392, green: 1.000, blue: 0.050, alpha: 1.000).CGColor
                }else{
                    shapeLayer.fillColor = beaconShape.color.CGColor
                    shapeLayer.strokeColor = beaconShape.color.CGColor
                }
                shapeLayer.lineWidth = 1.0
                
                beaconShape.shapeLayer = shapeLayer
                beaconShape.point = position
                
                
                // re adds the shape to screen
                self.layer.addSublayer(shapeLayer)

            }
        }
    }
    
    func displayWillUpdateWithDeltaTime(deltaTime: CFTimeInterval) {
        moveBeacons() // Moves the beacons
    }
}

class DistanceRange{
    var type : CLProximity!
    var beacons : [BeaconShape] = []
    var shapeLayer : CAShapeLayer!
    var radius: CGFloat!
}

