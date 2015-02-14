//
//  ViewController.h
//  davai
//
//  Created by Zhi Li on 2014-09-15.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UserProfile.h"
#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "ActionBarViewControllerCollection.h"
#import "ActionViewController.h"
#import "ExploreViewController.h"
#import "SettingViewController.h"
#import "CameraViewController.h"
#import "NetworkController.h"
#import "DataController.h"
#import "ActionViewPresentAnimationController.h"
#import "ActionViewDismissAnimationController.h"

/** The root view controller
 */

@interface ViewController : UIViewController <UIViewControllerTransitioningDelegate, LoginViewControllerDelegate, ActionViewControllerDelegate, CameraViewControllerDelegate, SettingViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) WelcomeViewController* welcomeViewController;
@property (nonatomic, strong) LoginViewController* loginViewController;
//@property (nonatomic, strong) UIActivityIndicatorView *spinner;

#pragma mark - Delegate Methods

// LoginViewControllerDelegate Delegate Method
- (void)registerWithUserData:(NSDictionary *)userData;
- (void)loginWithUserData:(NSDictionary *)userData;

/** Present the given ActionViewController
 *
 *  ActionViewControllerDelegate Delegate Method
 *  @param ActionViewController The ActionViewController to be presented
 *  @param animated YES to animate the presentation; otherwise, NO
 */
- (void)transitFromActionViewController:(ActionViewController *)fromActionViewController toActionViewController:(ActionViewController *)toActionViewController animated:(BOOL)animated;

/** Add a new captured video
 *
 *  CameraViewControllerDelegate Delegate Method
 *
 *  Called when the user "post" a new video
 */
-(void)postVideo:(NSDictionary*)info;

/** Logout the current user from the app
 *
 *  SettingViewControllerDelegate Delegate Method
 *
 *  Called when the user tapped the "logout" button on the Setting View
 */
- (void)logout;

@end
