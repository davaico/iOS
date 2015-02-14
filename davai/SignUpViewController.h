//
//  SignUpViewController.h
//  davai
//
//  Created by Zhi Li on 2014-11-12.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NetworkController.h"
#import "NoNetworkErrorViewController.h"

@protocol SignUpViewControllerDelegate <NSObject>

@required

- (void)signUp;
- (void)toggleMute;

@end


@interface SignUpViewController : UIViewController<UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *usernameClearButton;
@property (nonatomic, strong) UIButton *emailClearButton;
@property (nonatomic, strong) UIButton *passwordClearButton;
@property (nonatomic, weak) IBOutlet UIButton *goButton;
@property (nonatomic, weak) IBOutlet UIButton *muteButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;



@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) id<SignUpViewControllerDelegate>delegate;
@end
