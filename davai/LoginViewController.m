//
//  LoginViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-13.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "LoginViewController.h"

CGFloat kButtonHeight = 65;
CGFloat kDetailViewHeight = 260;
CGFloat kSignUpViewHeight = 195;
CGFloat kSignInViewHeight = 195;


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    self.signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    self.signInViewController.delegate = self;
    self.signUpViewController.delegate = self;
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"davai_portrait" withExtension:@"mp4"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.duration = CMTimeGetSeconds(asset.duration);
    
    self.layer = [AVPlayerLayer layer];
    [self.layer setPlayer:self.player];
    [self.layer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.playerView.layer addSublayer:self.layer];
//    [self.view.layer addSublayer:self.layer];
    
    [self mutePlayer];
    [self.player play];
    
    self.detailView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    self.detailView.opaque = NO;
    
    self.signUpView = self.signUpViewController.view;
    self.signInView = self.signInViewController.view;
    
    self.detailView.frame = CGRectMake(0, self.view.frame.size.height - kButtonHeight, self.view.frame.size.width, kDetailViewHeight);
    
    self.tapOnVideoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDetailView)];
    self.tapOnVideoGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.playerView addGestureRecognizer:self.tapOnVideoGestureRecognizer];


    [self.playerView bringSubviewToFront:self.detailView];
    [self.playerView addSubview:self.homeScreenImageView];
    [self.playerView bringSubviewToFront:self.homeScreenImageView];
    
//    [self.signInViewController.spinner setHidden:YES];
//    [self.signUpViewController.spinner setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissDetailView
{
    [self dismissKeyboard];
    [self.signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0, self.view.frame.size.height - kButtonHeight, self.view.frame.size.width, kDetailViewHeight);
    [self moveDetailViewWithFrame:frame animated:YES];
}

- (void)dismissKeyboard
{
    [self.signInViewController.usernameTextField resignFirstResponder];
    [self.signInViewController.passwordTextField resignFirstResponder];
    [self.signUpViewController.usernameTextField resignFirstResponder];
    [self.signUpViewController.emailTextField resignFirstResponder];
    [self.signUpViewController.passwordTextField resignFirstResponder];
}

- (IBAction)signUpButtonTapped:(id)sender
{
    [self.signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor colorWithRed:98.0f/255.0f green:167.0f/255.0f blue:113.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self dismissKeyboard];
    
    [self.signInView removeFromSuperview];
    CGFloat height = kButtonHeight + kSignUpViewHeight;
    CGRect detailViewframe = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height);
    CGRect signUpViewframe = CGRectMake(0, kButtonHeight, self.view.frame.size.width, kSignUpViewHeight);
    self.signUpView.frame = signUpViewframe;
    [self.detailView addSubview:self.signUpView];
    [self moveDetailViewWithFrame:detailViewframe animated:YES];
//    self.detailView.frame = detailViewframe;
//    [self.signUpView bringSubviewToFront:self.signUpViewController.muteButton];
}
- (IBAction)signInButtonTapped:(id)sender
{
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signInButton setTitleColor:[UIColor colorWithRed:98.0f/255.0f green:167.0f/255.0f blue:113.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self dismissKeyboard];
    
    [self.signUpView removeFromSuperview];
    CGFloat height = kButtonHeight + kSignInViewHeight;
    CGRect detailViewframe = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height);
    CGRect signInViewframe = CGRectMake(0, kButtonHeight, self.view.frame.size.width, kSignInViewHeight);
    self.signInView.frame = signInViewframe;
    [self.detailView addSubview:self.signInView];
    [self moveDetailViewWithFrame:detailViewframe animated:YES];
//    self.detailView.frame = detailViewframe;
//    [self.signInView bringSubviewToFront:self.signInViewController.muteButton];
}

#pragma mark -
- (void) moveDetailViewWithFrame:(CGRect)frame animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2f];
        self.detailView.frame = frame;
        [UIView commitAnimations];
    }
    else
        self.detailView.frame = frame;
}


#pragma mark - mute and unmute player methods
- (void)mutePlayer
{
    self.muted = YES;
    self.player.muted = YES;
    [self.signInViewController.muteButton setImage:[UIImage imageNamed:@"Unmuted"]
                                          forState:UIControlStateNormal];
    [self.signUpViewController.muteButton setImage:[UIImage imageNamed:@"Unmuted"]
                                          forState:UIControlStateNormal];
}

- (void)unmutePlayer
{
    self.muted = NO;
    self.player.muted = NO;
    [self.signInViewController.muteButton setImage:[UIImage imageNamed:@"Muted"]
                                          forState:UIControlStateNormal];
    [self.signUpViewController.muteButton setImage:[UIImage imageNamed:@"Muted"]
                                          forState:UIControlStateNormal];
}



#pragma mark -
- (void)appDidBecomeForeground
{
    [self.player play];
}


#pragma mark - Player method
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
}

#pragma mark -
- (void)viewWillAppear:(BOOL)animated
{
    [self.view bringSubviewToFront:self.detailView];

    [self.player play];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    // register notification for player
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    // register notifications for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:@"UIKeyboardDidHideNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    
    // add an observer for backgrounding
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // mute / unmute player
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mutePlayer)
                                                 name:@"MutePlayer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unmutePlayer)
                                                 name:@"UnmutePlayer"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.player pause];
    
    // remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardDidHideNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"MutePlayer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"UnmutePlayer"
                                               object:nil];
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    [self.homeScreenImageView setHidden:YES];
    
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat height = kbSize.height + kDetailViewHeight;
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height - height,
                              self.view.frame.size.width, height);
    
    [self moveDetailViewWithFrame:frame animated:YES];
}

- (void)keyboardDidHide:(NSNotification *)notification {

}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat height = kDetailViewHeight;
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height - height,
                              self.view.frame.size.width, height);
    
    [self moveDetailViewWithFrame:frame animated:YES];
    [self.homeScreenImageView setHidden:NO];
}


#pragma mark - Delegate Methods
- (void)toggleMute
{
    if (self.muted)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnmutePlayer" object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MutePlayer" object:nil];
}

- (void)signIn
{
    if (![[NetworkController sharedController] hasConnectivity]) {
        NoNetworkErrorViewController *noNetworkErrorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoNetworkErrorViewController"];
        [self presentViewController:noNetworkErrorViewController animated:YES completion:nil];
        return;
    }
    NSLog(@"signin");
    [self.signInViewController.usernameTextField setEnabled:NO];
    [self.signInViewController.passwordTextField setEnabled:NO];
    [self.signInViewController.goButton setEnabled:NO];
//    [self.signInViewController.view bringSubviewToFront:self.signInViewController.spinner];
    [self.signInViewController.spinner setHidden:NO];
    [self.signInViewController.spinner startAnimating];
//    [self.signInViewController.goButton setHidden:YES];
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    CGPoint center = self.signInViewController.goButton.center;
//    CGFloat height = self.signInViewController.goButton.frame.size.height;
//    CGRect frame = CGRectMake(center.x - height / 2, center.y - height / 2, height, height);
//    self.spinner.frame = self.signInViewController.goButton.bounds;
//    
//    [self.signInViewController.goButton addSubview:self.spinner];
//    [self.spinner startAnimating];
    
    NSDictionary *userData = @{@"username" : self.signInViewController.usernameTextField.text,
                               @"password" : self.signInViewController.passwordTextField.text};
    [self.delegate loginWithUserData:userData];
}

- (void)signUp
{
    if (![[NetworkController sharedController] hasConnectivity]) {
        NoNetworkErrorViewController *noNetworkErrorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoNetworkErrorViewController"];
        [self presentViewController:noNetworkErrorViewController animated:YES completion:nil];
        return;
    }
    
    [self.signUpViewController.usernameTextField setEnabled:NO];
    [self.signUpViewController.emailTextField setEnabled:NO];
    [self.signUpViewController.passwordTextField setEnabled:NO];
    [self.signUpViewController.goButton setEnabled:NO];
    NSDictionary *userData = @{@"username" : self.signUpViewController.usernameTextField.text,
                               @"password" : self.signUpViewController.passwordTextField.text,
                               @"email" : self.signUpViewController.emailTextField.text};
    [self.delegate registerWithUserData:userData];
}

#pragma mark - Login Method
- (void)retry
{
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:6];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.detailView center].x - 20.0f, [self.detailView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.detailView center].x + 20.0f, [self.detailView center].y)]];
    [[self.detailView layer] addAnimation:animation forKey:@"position"];
    
//    [self.spinnerViewController.spinner stopAnimating];
//    [self.spinnerViewController.spinner removeFromSuperview];
//    self.spinnerViewController = nil;
    
    [self.signInViewController.usernameTextField setEnabled:YES];
    [self.signInViewController.passwordTextField setEnabled:YES];
    [self.signInViewController.goButton setEnabled:YES];
    [self.signInViewController.goButton setHidden:NO];
    [self.signInViewController.spinner stopAnimating];
    [self.signInViewController.spinner setHidden:YES];
    
    [self.signUpViewController.usernameTextField setEnabled:YES];
    [self.signUpViewController.emailTextField setEnabled:YES];
    [self.signUpViewController.passwordTextField setEnabled:YES];
    [self.signUpViewController.goButton setEnabled:YES];
    [self.signUpViewController.goButton setHidden:NO];
}


@end
