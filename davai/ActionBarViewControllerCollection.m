//
//  ActionBarViewControllerCollection.m
//  davai
//
//  Created by Zhi Li on 2014-10-31.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "ActionBarViewControllerCollection.h"

@implementation ActionBarViewControllerCollection


+ (id)sharedCollection{
    static ActionBarViewControllerCollection *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
