//
//  ActionViewController.h
//  davai
//
//  Created by Zhi Li on 2014-09-18.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"


@class ActionViewController;

@protocol ActionViewControllerDelegate <NSObject>

@required
/** Present the given ActionViewController
 *
 *  ActionViewControllerDelegate Delegate Method
 *  @param ActionViewController The ActionViewController to be presented
 *  @param animated YES to animate the presentation; otherwise, NO
 */
- (void)transitFromActionViewController:(ActionViewController *)fromActionViewController toActionViewController:(ActionViewController *)toActionViewController animated:(BOOL)animated;

@end


/** Abstract class for ExploreViewController, SettingViewController, and CameraViewController
 */
@interface ActionViewController : UIViewController

@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) UIView *actionBarView;
@property (strong, nonatomic) UIButton *exploreButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UILabel *barTitle;


@property (strong, nonatomic) UserProfile *userProfile;

- (void)exploreButtonTapped;
- (void)settingButtonTapped;
- (void)cameraButtonTapped;


@end
