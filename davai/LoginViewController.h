//
//  LoginViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-13.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SignInViewController.h"
#import "SignUpViewController.h"


@protocol LoginViewControllerDelegate <NSObject>

@required

//- (void)validate:(NSDictionary *)data;
- (void)registerWithUserData:(NSDictionary *)userData;
- (void)loginWithUserData:(NSDictionary *)userData;

@end


@interface LoginViewController : UIViewController<SignInViewControllerDelegate, SignUpViewControllerDelegate>


@property (nonatomic, weak) IBOutlet UIView *detailView;
//@property (nonatomic, strong) UIView *IDView;
@property (nonatomic, weak) IBOutlet UIView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton *signInButton;
@property (nonatomic, weak) IBOutlet UIImageView *homeScreenImageView;
@property (nonatomic) BOOL muted;

@property (strong, nonatomic) UITapGestureRecognizer *tapOnVideoGestureRecognizer;

@property (nonatomic, strong) SignUpViewController *signUpViewController;
@property (nonatomic, strong) SignInViewController *signInViewController;
@property (nonatomic, strong) UIView *signInView;
@property (nonatomic, strong) UIView *signUpView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *layer;
@property (nonatomic) Float64 duration;
//@property (strong, nonatomic) id playbackTimeObserver;


@property (nonatomic, strong) id<LoginViewControllerDelegate>delegate;

- (void)retry;
- (void)toggleMute;
- (void)signIn;
- (void)signUp;

@end
