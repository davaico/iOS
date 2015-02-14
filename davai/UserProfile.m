//
//  UserProfile.m
//  davai
//
//  Created by Zhi Li on 2014-10-12.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

+ (id)sharedProfile {
    static UserProfile *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)userLoggedIn
{
    if (self.user)
        return YES;
    
    self.user = [[DataController sharedController]fetchLoggedInUser];
    
    if (self.user)
        return YES;
    else
        return NO;
}

- (void)logout
{
    [[DataController sharedController]logOutUser:self.user];
    self.user = nil;
}

- (void)loginWithUser:(User *)user
{
    [[DataController sharedController]logInUser:user];
    self.user = user;
}

@end
