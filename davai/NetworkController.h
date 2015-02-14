//
//  NetworkController.h
//  davai
//
//  Created by Zhi Li on 2014-11-25.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "DataController.h"
#import "S3.h"
#import "AWSCore.h"
#import "AppDelegate.h"


/** A controller dedicated for networking functions
 */
@interface NetworkController : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property(nonatomic, strong) Reachability *reachability;

@property(nonatomic, strong) NSMutableArray *uploads;
@property(nonatomic, strong) NSMutableArray *downloads;

@property(nonatomic) BOOL isDownloading;
@property(nonatomic) BOOL isUploading;

/** The shared instance of NetworkController
 * @return The shared instance of NetworkController
 */
+ (id)sharedController;

/** Check the Internet connectivity of the device
 *  @return YES if the device has Internet connection; otherwise, NO
 */
- (BOOL)hasConnectivity;

/** Connect to the server and login with the given user information
 *  @param userData A dictionary contains the information of the user
 *  @return A dictionary contains returned from the server if login successful; otherwise, nil
 */
+ (NSDictionary*)logInWithUserData:(NSDictionary*)userData;

/** Connect to the server and register with the given user information
 * @param userData A dictionary contains the information of the user
 * @return A dictionary contains returned from the server if register successful; otherwise, nil
 */
+ (NSDictionary*)registerWithUserData:(NSDictionary*)userData;

- (void)uploadVideoFile:(NSDictionary*)videoDict;
//- (void)postVideo:(NSDictionary*)videoDict;
- (void)fetchVideos:(NSString*)username;

- (void)postComment:(NSDictionary*)commentDict;
- (void)likeVideo:(NSDictionary*)videoDict;

@end
