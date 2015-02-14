//
//  UserProfile.h
//  davai
//
//  Created by Zhi Li on 2014-10-12.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"
#import "User.h"

/** A class holds the information for the current user
 */
@interface UserProfile : NSObject

@property (nonatomic, strong) User *user;

/** The shared instance of UserProfile
 * @return The shared instance of UserProfile
 */
+ (id)sharedProfile;

/** Check if there is a user that has already logged in
 * @return YES if there is a user that has already logged in; otherwise, No 
 */
- (BOOL)userLoggedIn;

/** Log out current user
 */
- (void)logout;

/** Log in the given user
 * @param The user to be logged in
 */
- (void)loginWithUser:(User *)user;
@end
