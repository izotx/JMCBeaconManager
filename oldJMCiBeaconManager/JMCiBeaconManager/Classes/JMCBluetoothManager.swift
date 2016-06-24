//
//  JMCBluetoothManager.swift
//  iBeaconManager
//
//  Created by Janusz Chudzynski on 6/21/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//

import Foundation
import CoreBluetooth
/**Bluetooth manager - responsible for getting the status of Bluetooth.*/
class BluetoothManager: NSObject, CBCentralManagerDelegate {
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var callback:((Bool)->Void)!
    var enabled = false
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: [CBCentralManagerOptionShowPowerAlertKey:false])
    }
    
    convenience init(callback:(Bool)->Void)
    {
        self.init()
        self.callback = callback
        
    }
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn{
            enabled = true
            callback(true)
        }
        else{
            enabled = false
            callback(false)
        }
    }
    
}