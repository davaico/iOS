//
//  SettingViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-13.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ActionViewController.h"
#import "ActionBarViewControllerCollection.h"
#import "UserProfile.h"
#import <MessageUI/MFMailComposeViewController.h>


@protocol SettingViewControllerDelegate <NSObject>

@required
/** Logout the current user from the app
 *
 *  SettingViewControllerDelegate Delegate Method
 *
 *  Called when the user tapped the "logout" button on the Setting View
 */
-(void)logout;

@end

@interface SettingViewController : ActionViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *buttonView;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UITextView *creditTextView;

@end
