//
//  PWDisplayLinker.swift
//  Animation
//
//  Created by Felipe on 6/20/16.
//  Copyright © 2016 Academic Technology Center. All rights reserved.
//

import Foundation
import QuartzCore

class PWDisplayLinker: NSObject {
   
    var delegate: PWDisplayLinkerDelegate!

    var displayLink: CADisplayLink?
   
    var nextDeltaTimeZero: Bool!

    var previousTimestamp: CFTimeInterval!
    
    
    convenience  init(delegate: PWDisplayLinkerDelegate) {
        self.init()
        self.delegate = delegate
        self.displayLink = nil
        self.nextDeltaTimeZero = true
        self.previousTimestamp = 0.0
        self.ensureDisplayLinkIsOnRunLoop()
    }
    
    override init() {
        
    }
    
    deinit{
        self.ensureDisplayLinkIsRemovedFromRunLoop()
    }
    
    func displayLinkUpdated() {
        
        let currentTime: CFTimeInterval = displayLink!.timestamp
        
        // calculate delta time
        var deltaTime: CFTimeInterval
        deltaTime = currentTime - previousTimestamp
        // store the timestamp
        self.previousTimestamp = currentTime
        // inform the delegate
        delegate.displayWillUpdateWithDeltaTime(deltaTime)
    }
    
    
    func ensureDisplayLinkIsOnRunLoop() {
        if displayLink == nil {
            self.displayLink = CADisplayLink(target: self, selector: #selector(PWDisplayLinker.displayLinkUpdated))
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            self.nextDeltaTimeZero = true
        }
    }
    
    func ensureDisplayLinkIsRemovedFromRunLoop() {
        if displayLink != nil {
            displayLink!.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            self.displayLink = nil
            self.nextDeltaTimeZero = true
        }
    }   
}