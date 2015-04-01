//
//  JMCBeaconManager.m
//  iBeaconTest
//
//  Created by sadmin on 2/21/14.
//  Copyright (c) 2014 JanuszChudzynski. All rights reserved.
//
#import "JMCBeaconManager.h"


@import AudioToolbox;
@import CoreBluetooth;

@interface JMCBeaconManager()<CLLocationManagerDelegate, CBCentralManagerDelegate>
{
    CLProximity proximity;
    int counter;
    
}
@property(nonatomic,strong)CLLocationManager * locationManager;
@property(nonatomic,strong) CLBeacon * currentBeacon;
@property(nonatomic,strong) NSMutableArray * regions;
@property(nonatomic,strong) NSMutableDictionary * stateDictionary;
@property(nonatomic,strong) CBCentralManager * bluetoothManager;
@property BOOL bluetoothEnabled;
@end


@implementation JMCBeaconManager

/**Sometimes ios doesn't call did enter region in this case we will call it manually*/
-(void)updateState:(CLBeaconRegion *)region state:(CLRegionState)state{
    if([[_stateDictionary objectForKey:region.identifier]integerValue]!=state ){
        [_stateDictionary setObject:@(state) forKey:region.identifier];
    }
}

/***/
-(void)checkStateForRegion:(CLBeaconRegion *)region{
    if([[_stateDictionary objectForKey:region.identifier]integerValue]!=CLRegionStateInside){
       [self.locationManager requestStateForRegion:region];
    }
}


- (void)startBluetoothStatusMonitoring {

    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()
                             options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if ([central state] == CBCentralManagerStatePoweredOn) {
        self.bluetoothEnabled = YES;
    }
    else {
        self.bluetoothEnabled = NO;
        [self logMessage:@"You must enable bluetooth!"];
        
    }
}



-(void)logMessage:(NSString *)message{
    
    message =[NSString stringWithFormat:@"%@\r\n %@ \r\n %@", [NSDate new],message,self.logView.text];
    self.logView.text = message;

    NSLog(@"\n %@ \n ",message);
   // [self saveLog:message];
}


-(id)init{
    self = [super init];
    if(self){
        _locationManager = [[CLLocationManager alloc]init];
        
      //  [_locationManager requestWhenInUseAuthorization];
        _regions = [NSMutableArray new];
        _locationManager.delegate = self;
              counter =0;
        _stateDictionary = [NSMutableDictionary new];
        
    }
    return self;
}

/**
    Checks if iBeacon monitoring is supported
 */
-(BOOL)isSupported:(NSMutableString*)message{
    BOOL enabled = NO;
    [self startBluetoothStatusMonitoring];

    NSMutableString * msg = [NSMutableString new];
    [msg appendFormat:@""];
    if([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]){
        enabled = YES;
    }
    else{

        enabled = NO;
       [message appendFormat:@"%@ /n %@ ",message, @"Region Monitoring is not available on this device"];
    }
    

    
    if([CLLocationManager authorizationStatus ]== kCLAuthorizationStatusAuthorizedAlways ){
        enabled = YES && enabled;
    }
    else{
        enabled = NO;//&&enabled;
       [message appendFormat:@"%@ /n %@ ",message, @"Applications must be explicitly authorized to use location services by the user and location services must themselves currently be enabled for the system."];
    }


    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        enabled = YES && enabled;

    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
      [message appendFormat:@"%@ /n %@ ",message, @"The user explicitly disabled background behavior for this app or for the whole system."];
        
        enabled = NO;// && enabled;
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
      
        [message appendFormat:@"%@ /n %@ ",message, @"unavailable on this system due to device configuration; the user cannot enable the feature."];
        
        enabled = NO;//&&enabled;

    }
    
    if(enabled) {
        message = [@"iBeacon monitoring is supported" mutableCopy];
    }
    
    if(self.logging){
        [self logMessage:message];
    }
    

    
    return enabled;
}

-(BOOL)isEnabled{
    return [CLLocationManager isMonitoringAvailableForClass:[CLRegion class]] &&[CLLocationManager authorizationStatus ]== kCLAuthorizationStatusAuthorizedAlways;
}

-(BOOL)canDeviceSupportAppBackgroundRefresh
{
    // Override point for customization after application launch.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        NSString * message = @"Background updates are available for the app.";
        if(self.logging){
            [self logMessage:message];
        }
        
        
        return YES;
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {

        NSString * message = @"The user explicitly disabled background behavior for this app or for the whole system.";
        if(self.logging){
            [self logMessage:message];
        }
        
        return NO;
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSString * message = @"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.";
        if(self.logging){
            [self logMessage:message];
        }

        return NO;
    }
    return NO;
}
/**Start monitoring regions */
-(void)startMonitoring{
    for (CLBeaconRegion * beaconRegion in self.regions) {
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        [self.locationManager startUpdatingLocation];
        [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:beaconRegion afterDelay:1];
    }
}

//Stops Monitoring Services
-(void)stopMonitoring;{
    for (CLBeaconRegion * beaconRegion in self.regions) {
        [self.locationManager stopMonitoringForRegion:beaconRegion];
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
        [self.locationManager stopUpdatingLocation];
    }

}

/**
 Register beacons only using identifier and proximity uiid
 */
-(void)registerBeaconWithProximityId:(NSString*)pid andIdentifier:(NSString *)identifier{
    NSUUID *proximityUUID = [[NSUUID alloc]
                             initWithUUIDString:pid];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:proximityUUID identifier:identifier];
    
    beaconRegion.notifyOnEntry=YES;
    beaconRegion.notifyOnExit=YES;
    beaconRegion.notifyEntryStateOnDisplay=YES;

    [self.regions addObject:beaconRegion];
    
}

/**
 Estimote beacons use a fixed Proximity UUID of B9407F30-F5F8-466E-AFF9-25556B57FE6D.
 
 Each beacon has a unique ID formatted as follows: proximityUUID.major.minor. We reserved the proximityUUID for all our beacons. The major and minor values are randomized by default but can be customized.
 */

-(void)registerRegionWithProximityId:(NSString*)pid andIdentifier:(NSString *)identifier major:(int)major andMinor:(int)minor{
    NSUUID *proximityUUID = [[NSUUID alloc]
                             initWithUUIDString:pid];
    
    if(major==-1 && minor==-1){
        [self registerBeaconWithProximityId:pid andIdentifier:identifier];
        return;
    }
    
    CLBeaconRegion *beaconRegion;
    beaconRegion= [[CLBeaconRegion alloc]initWithProximityUUID:proximityUUID major:major minor:minor identifier:identifier];
    beaconRegion.notifyOnEntry=YES;
    beaconRegion.notifyOnExit=YES;
    beaconRegion.notifyEntryStateOnDisplay=YES;
    
    [self.regions addObject:beaconRegion];
}

/**Tells the delegate that the user enter  specified region.*/
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    if(self.logging){
        NSString * log = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];
        [self logMessage:log];
    }
    
    if([region isKindOfClass:[CLBeaconRegion class]]){
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *) region];
    }
    
    
    
}


/** Tells the delegate that the user left the specified region.*/
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
  
    if(self.logging){
        NSString * log = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];
        [self logMessage:log];
    }
    
    proximity = -1;
    
    if([region isKindOfClass:[CLBeaconRegion class]]){
       [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
       
    }
}

/** Tells the delegate about the state of the specified region. (required) */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSString * log = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];


    if([region isKindOfClass:[CLBeaconRegion class]]){   //check if the region is beacon region
        [self updateState:(CLBeaconRegion *)region state:state];
  
        if(self.logging){
            [self logMessage:log];
            [self logMessage:[NSString stringWithFormat:@"State for region: %@ is: %d %@ %@",region, (int)state, [(CLBeaconRegion *) region major], [(CLBeaconRegion *) region minor]]];
        }
        
    if(self.regionEvent){
        self.regionEvent( [[(CLBeaconRegion *) region  proximityUUID]UUIDString], [[(CLBeaconRegion *) region major]intValue],[[(CLBeaconRegion *) region minor]intValue],(NSUInteger)state );
    }
  
    if(state == CLRegionStateInside){
             //start ranging beacons
            [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *) region];
            [self locationManager:self.locationManager didEnterRegion:region];
        
        }
        if(state == CLRegionStateOutside){
            //start ranging beacons
            [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *) region];
            [self locationManager:self.locationManager didExitRegion:region];
            
        }
        
    }
}




- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Delegate of the location manager, when you have an error
    NSLog(@"didFailWithError: %@", error);
    
  //  UIAlertView *errorAlert = [[UIAlertView alloc]     initWithTitle:NSLocalizedString(@"application_name", nil) message:NSLocalizedString(@"location_error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
    
   // [errorAlert show];
    [self logMessage:error.debugDescription];
    
}

/**Tells the delegate that one or more beacons are in range. */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    if(self.nearbyBeacons){
        self.nearbyBeacons(beacons);
    }
    
    for(CLBeacon *beacon in beacons)
    {
            [self checkStateForRegion:region];
            proximity = beacon.proximity;
          //  [self logMessage:[NSString stringWithFormat:@"Beacon range: %@",beacon]];
        
            if(self.beaconFound){
                self.beaconFound(beacon.proximityUUID.UUIDString, beacon.major.intValue, beacon.minor.intValue, beacon.proximity, beacon.accuracy,beacon.rssi);
                if(self.logging){
                    NSString *message = [NSString stringWithFormat:@"Proximity: %ld",  beacon.proximity];
                    [self logMessage:message];
                    //[self log:message];
                
                }
            }
    }
    
    if(counter>30==1){
       
        //[self logMessage:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
       counter =0;
    }
    counter++;

}

/** this method can be used to display a content related to the closest beacon */
-(void)displayContentFor:(CLBeacon * )beacon andRegion:(CLRegion *)region{
    if(!_currentBeacon){
        _currentBeacon = beacon;
    }
    else{
        if([_currentBeacon.proximityUUID isEqual:_currentBeacon.proximityUUID]&&_currentBeacon.major ==_currentBeacon.major&&_currentBeacon.minor == _currentBeacon.minor)
        {
            
            if(_currentBeacon.proximity == beacon.proximity){
                //don't change it
                //get content for beacon
                
            } //same beacon but different proximity
            else{
                
            }
        }
    }
}

/** Tells the delegate that an error occurred while gathering ranging information for a set of beacons. */
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    NSString * log = [NSString stringWithFormat:@"Failed: %@ %s", error, __PRETTY_FUNCTION__];
    if(self.logging){
    [self logMessage:log];
    }
    
    
}

/** Tells the delegate that a new region is being monitored.*/
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.locationManager requestStateForRegion:region];
    NSString * log = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];
    if(self.logging){
        [self logMessage:log];
    }
        //NSLog(@"%@",log);
    // NSLog(@"%@",region);
    
}

/** Tells the delegate that the delivery of location updates has resumed.*/
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    NSString * log = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];
    if(self.logging){
        [self logMessage:log];
    NSLog(@"%@ %s",log, __PRETTY_FUNCTION__);
    }


    
}
/**
 *  Get content of a log file as a string
 *
 *  @return string with log information
 */

-(NSString *)getLog{
    NSString * log = @"";
    NSString * docs = [self applicationDocumentsDirectory];
    NSString * filePath = [docs stringByAppendingPathComponent:@"log.txt"];
    if([[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        NSError *e;
        NSString * existingFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&e];
        if(e){
            NSLog(@"%s %@",__PRETTY_FUNCTION__, e.debugDescription);
        }
        else{
            log = existingFile;
        }
    }
    return log;
}

/**
 *  Save's a log to txt log file
 *
 *  @param string Message to save
 */
-(void)saveLog:(NSString *)string{
    
    NSString * stringToSave= @"";
    NSString * docs = [self applicationDocumentsDirectory];
    NSString * filePath = [docs stringByAppendingPathComponent:@"log.txt"];
    if([[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        NSError *e;
      //  NSData * d= [NSData dataWithContentsOfFile:filePath];
        NSString * existingFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&e];
        if(e){
            NSLog(@"%s %@",__PRETTY_FUNCTION__, e.debugDescription);
        }
        else{
            stringToSave = [NSString stringWithFormat:@"/r/n %@ %@", existingFile, string];
            
        }
    }
    else{
        stringToSave = string;
    }
   NSData *d = [stringToSave dataUsingEncoding:NSUTF8StringEncoding];
    
    [d writeToFile:filePath atomically:YES];
    
}
/**
 *  Immortal documents path
 *
 *  @return document's path
 */
- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}



@end
