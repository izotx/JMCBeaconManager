//
//  JMCBeaconManager.h
//  iBeaconTest
//
/**
 *  Class that can be used to monitor nearby beacons. To use it you should follow the steps:
 1. Check if beacons are supported calling isSupported method
 2. Register regions to monitor
 3. Specify beaconFound block to monitor beacons.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;

@interface JMCBeaconManager : NSObject
@property BOOL logging;

/**Description: start monitoring services for all regions*/
-(void)startMonitoring;

/**Description: stop monitoring services for all regions*/
-(void)stopMonitoring;


/**
*  Description:  Registers beacon's region using major and minor identifier
*
*  @param pid        beacon identifier
*  @param identifier beacon identifier used internally
*  @param major      major identifier
*  @param minor      minor identifier
*/
-(void)registerRegionWithProximityId:(NSString*)pid andIdentifier:(NSString *)identifier major:(int)major andMinor:(int)minor;


-(void)registerBeaconWithProximityId:(NSString*)pid andIdentifier:(NSString *)identifier;

/**
 *  Checks if beacon is supported
 *
 *  @param message string that will contain message about problems with supporting the beacons
 *
 *  @return boolean that indicates if device supports beacons or not
 */
-(BOOL)isSupported:(NSMutableString*)message;

/**
 *  Appends message to the log file
 *
 *  @param message message to save
 */
-(void)saveLog:(NSString *)message;
/**
 *  Getting the log
 *
 *  @return log as string
 */
-(NSString *)getLog;

/**
 *  View used for loggin the events
 */
@property(nonatomic,strong)UITextView * logView;

/**
 *  Block used for monitoring and processing the beacons 
 */
@property(nonatomic, copy) void (^beaconFound)(NSString * uuid, int major, int minor, CLProximity proximity, CLLocationAccuracy accuracy, NSInteger rssi);
@property(nonatomic, copy) void (^nearbyBeacons)(NSArray * beacons);

/**
 *  Block used for monitoring region events
 */
@property(nonatomic, copy) void (^regionEvent)(NSString * uuid, int major, int minor, CLRegionState state);




@end
