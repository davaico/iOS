//
//  WelcomeViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-14.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeContentViewController.h"

@interface WelcomeViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *welcomePageViewController;
@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic) BOOL viewed;


@end
