//
//  SignInViewController.h
//  davai
//
//  Created by Zhi Li on 2014-11-12.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NetworkController.h"
#import "NoNetworkErrorViewController.h"

@protocol SignInViewControllerDelegate <NSObject>

@required

- (void)signIn;
- (void)toggleMute;

@end


@interface SignInViewController : UIViewController<UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *usernameClearButton;
@property (nonatomic, strong) UIButton *passwordClearButton;
@property (nonatomic, weak) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) id<SignInViewControllerDelegate>delegate;
@end
