//
//  ATCBeaconNetworkUtilities.h
//  ATCTrainingStations
//
//  Created by Janusz Chudzynski on 6/19/14.
//  Copyright (c) 2014 Janusz Chudzynski. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

/**
 *  Class is used to gather networking methods used to get data about beacons, and to save information about events related to them in remote server. Probably it should be subclassed and/or extended to add additional functionality
 */
@interface ATCBeaconNetworkUtilities : NSObject


/**
Logs in to database
@param username
@param password
 */
-(void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password withCompletionHandler:(void (^)(NSError *error, NSUInteger userId, NSInteger sessionId, NSInteger warningState, NSString * errorMessage))completionBlock;

/**Logs out user*/
-(void)logoutUser:(NSString * )sessionid withCompletionHandler:(void (^)(NSError *error))completionBlock;


/**
*  Sends data about regions to the database
*
*  @param major       major
*  @param minor       minor
*  @param state       did user enter or left the regions?
*  @param user        user
*  @param completionBlock  block that will be reporting errors
 */
-(void)sendRegionNotification:(int)major minor:(int)minor proximityID:(NSString *)proximityId regionState:(CLRegionState)state user:(NSString*)user withErrorCompletionHandler:(void (^)(NSError *error))completionBlock;

/**
 *  Sends proximity data to server
 *
 *  @param major           major
 *  @param minor           minor
 *  @param proximityID     proximity
 *  @param proximity       proximity
 *  @param completionBlock completion block
 */
-(void)sendProximityDataForBeacon:(int)major minor:(int)minor proximityID:(NSString *)proximityID proximity:(CLProximity) proximity user:(NSString*)user withErrorCompletionHandler:(void (^)(NSError *error))completionBlock;


/**
 *  get data from remote server
 *
 *  @param completionBlock completion block handler
 */
-(void)getDataWithCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock;

/**
 *  Gettting information about beacon
 *
 *  @param major           major identifier
 *  @param minor           minor identifier
 *  @param proximityID     proximity identifier
 *  @param proximity       proximity to beacon
 *  @param completionBlock completion block handler
 */
-(void)getDataForBeaconMajor:(int)major minor:(int)minor proximityId:(NSString *)proximityID proximity:(CLProximity) proximity WithCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock;


@end
