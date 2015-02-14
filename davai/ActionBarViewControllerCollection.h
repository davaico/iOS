//
//  ActionBarViewControllerCollection.h
//  davai
//
//  Created by Zhi Li on 2014-10-31.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionViewController.h"

/** A class storing the instances of ExploreViewController, SettingViewController, and CameraViewController
 */
@interface ActionBarViewControllerCollection : NSObject

@property (nonatomic, strong) ActionViewController *exploreViewController;
@property (nonatomic, strong) ActionViewController *settingViewController;
@property (nonatomic, strong) ActionViewController *cameraViewController;

/** The shared instance of ActionBarViewControllerCollection
 * @return The shared instance of ActionBarViewControllerCollection
 */
+ (id)sharedCollection;

@end
