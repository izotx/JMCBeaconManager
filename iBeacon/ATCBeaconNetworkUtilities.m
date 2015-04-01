//
//  ATCBeaconNetworkUtilities.m
//  ATCTrainingStations
//
//  Created by Janusz Chudzynski on 6/19/14.
//  Copyright (c) 2014 Janusz Chudzynski. All rights reserved.
//
//URL used to call API

#import "ATCBeaconNetworkUtilities.h"
#define BEACON_URL @"http://atcwebapp.argo.uwf.edu/trainingstations/wp_trainingstations/?missions_json=1"
#define TIMEOUT 60

@implementation ATCBeaconNetworkUtilities


/**
 Logins user and returns information using block completion handler
 */

-(void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password withCompletionHandler:(void (^)(NSError *error, NSUInteger userId,NSInteger sessionId, NSInteger warningState, NSString * errorMessage))completionBlock;{

    NSString * urlstring =[NSString stringWithFormat:@"%@&action=login&user=%@&password=%@",BEACON_URL, username, password];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            NSLog(@" Error %@ ",connectionError);
            completionBlock(connectionError,0,0,0,connectionError.localizedFailureReason);
            return;
        }
        else{
            //get data
            if(!data){
                NSLog(@" Data not available ");
                completionBlock(nil, 0, 0,0, @"Unexpected error occured. Please try again later.");
            }
            
            NSError *error;
            id object = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:0
                         error:&error];
            
            
            
            if(!error){
                if([object isKindOfClass:[NSDictionary class]]){
                    if(object[@"error_message"]){
                        completionBlock(nil, 0, 0, 0, object[@"error_message"]);
                        return;
                    }
                    else if(object[@"userid"] && object[@"session"]&& object[@"warning_state"] ){
                        completionBlock(nil,[object[@"userid"]integerValue],[object[@"session"]integerValue],[object[@"warning_state"]integerValue], nil);
                                            return;
                    }
                    else{
                         completionBlock(nil,0,0, 0,@"Unknown problem occured.Please try again later");
                                           return;
                    }
                }
            }
            //else{
                completionBlock(nil,0,0,0, @"Unknown problem occured. Please try again later");

        }
    }];
}

/**Logs out user*/
-(void)logoutUser:(NSString * )sessionId withCompletionHandler:(void (^)(NSError *error))completionBlock;{
    NSString * urlstring =[NSString stringWithFormat:@"%@&action=logout&session=%@",BEACON_URL, sessionId];
    
    
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            NSLog(@" Error %@ ",connectionError);
            
            
            return;
        }}];
}




/**
 *  Sends data about regions to the database
 *
 *  @param major       major
 *  @param minor       minor
 *  @param state       did user enter or left the regions?
 *  @param user        user
 *  @param completionBlock  block that will be reporting errors
 */

-(void)sendRegionNotification:(int)major minor:(int)minor proximityID:(NSString *)proximityID regionState:(CLRegionState)state user:(NSString*)user withErrorCompletionHandler: (void (^)(NSError *error))completionBlock{
    //http://localhost/Badges/wp/?missions_json=1&action=saveRegion&beacon_uuid=223&beacon_minor=2&beacon_major=2&user=Maria&entered=1&event_date=0
    //http://atcwebapp.argo.uwf.edu/trainingstations/wp_trainingstations/?missions_json=1&action=saveRegion&beacon_uuid=B9407F30-F5F8-466E-AFF9-25556B57FE6D&beacon_minor=2&beacon_major=1&user=Janek&state=0&event_date=1407249310.826781
    
    NSDate * d = [NSDate new];
    NSTimeInterval timeInterval =[d timeIntervalSince1970];

    NSString * urlstring =[NSString stringWithFormat:@"%@&action=saveRegion&beacon_uuid=%@&beacon_minor=%d&beacon_major=%d&user=%@&state=%d&event_date=%f&foreground=%d",BEACON_URL,proximityID,minor,major,user, (int)state,timeInterval,(int)[[UIApplication sharedApplication]applicationState]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            NSLog(@" Error %@ ",connectionError);
            completionBlock(connectionError);
            return;
        }}];
}


/**
 *  Sends proximity data to server
 *
 *  @param major           <#major description#>
 *  @param minor           <#minor description#>
 *  @param proximityID     <#proximityID description#>
 *  @param proximity       <#proximity description#>
 *  @param completionBlock <#completionBlock description#>
 */

-(void)sendProximityDataForBeacon:(int)major minor:(int)minor proximityID:(NSString *)proximityID proximity:(CLProximity) proximity user:(NSString*)user withErrorCompletionHandler:(void (^)(NSError *error))completionBlock;{
    NSDate * d = [NSDate new];
    NSTimeInterval timeInterval =[d timeIntervalSince1970];
    
    NSString * urlstring =[NSString stringWithFormat:@"%@&action=saveProximity&beacon_uuid=%@&beacon_minor=%d&beacon_major=%d&user=%@&proximity=%d&event_date=%f&foreground=%d",BEACON_URL,proximityID,minor,major, user,(int) proximity,timeInterval,(int)[[UIApplication sharedApplication]applicationState]];
    
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            NSLog(@" Error %@ %s",connectionError,__PRETTY_FUNCTION__);
            return;
        }}];
  
}


/**
 *  get data from remote server
 *
 *  @param completionBlock completion block handler
 */
-(void)getDataWithCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock{
  
    NSString * urlstring =[NSString stringWithFormat:@"%@&action=getMissions",BEACON_URL];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
 
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             NSError * error;
        if(!data){
             NSLog(@" Data not available ");
            return;
        }
        
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(error) {
            NSLog(@"Error %@ %s",error,__PRETTY_FUNCTION__);
            completionBlock(nil, error);
            return;
        }
        if([object isKindOfClass:[NSDictionary class]]){
             NSDictionary *results = object;
             completionBlock(results, error);
            
            
             //NSLog(@"%@",results);
        }else
        {
            NSLog(@" Not a dictionary ");
        }
    }];
}


/**
 *  Gettting information about beacon
 *
 *  @param major           major identifier
 *  @param minor           minor identifier
 *  @param proximityID     proximity identifier
 *  @param proximity       proximity to beacon
 *  @param completionBlock completion block handler
 */

-(void)getDataForBeaconMajor:(int)major minor:(int)minor proximityId:(NSString *)proximityID proximity:(CLProximity) proximity  WithCompletionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock;{
    //form request
    assert(proximityID!=NULL);
    
    NSString * urlstring =[NSString stringWithFormat:@"%@&action=getData&beacon_major=%d&beacon_minor=%d&beacon_uuid=%@",BEACON_URL,major,minor,proximityID];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!data||connectionError){
            if(!connectionError){
                connectionError = [NSError new];
            }
            completionBlock(nil, connectionError);
            return;
        }
        
        NSError * error;
        id object = [NSJSONSerialization
                     JSONObjectWithData:data
                     options:0
                     error:&error];
        
        if(error) {
             NSLog(@"Error %@ %s",error,__PRETTY_FUNCTION__);
            completionBlock(nil, error);
            return;
        }
        if([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = object;
            completionBlock(results, error);

        }else
        {
            NSLog(@" Not a dictionary ");
        }
    }];
}






@end
