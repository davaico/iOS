//
//  AppDelegate.h
//  davai
//
//  Created by Zhi Li on 2014-09-26.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();

@end

