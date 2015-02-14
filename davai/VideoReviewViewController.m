//
//  VideoReviewViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-01.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "VideoReviewViewController.h"

CGFloat kVideoSubmitViewHeight = 170;
CGFloat kPadding = 20;
CGRect videoSubmitViewFrame;

BOOL isPlaying = NO;

@interface VideoReviewViewController ()

@end

@implementation VideoReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
//    [self setupPlayer];

    self.barTitle.text = @"Review";
//    [self.view bringSubviewToFront:self.actionBarView];
}


- (void)setupPlayer
{
    self.playerView = [[UIView alloc]initWithFrame:self.view.frame];
//    self.videoFileUrl = videoFileUrl;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoFileUrl options:nil];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.duration = CMTimeGetSeconds(asset.duration);
//    NSLog(@"duration: %f", self.duration);
    
    
    self.layer = [AVPlayerLayer layer];
    [self.layer setPlayer:self.player];
    [self.layer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [self.playerView.layer addSublayer:self.layer];
    [self.view addSubview:self.playerView];

    
    self.videoSubmitViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoSubmitViewController"];
//    [self addChildViewController:self.videoSubmitViewController];
    
    videoSubmitViewFrame = CGRectMake(0, self.view.frame.size.height - kVideoSubmitViewHeight,
                                      self.view.frame.size.width, kVideoSubmitViewHeight);

    self.videoSubmitViewController.view.frame = videoSubmitViewFrame;
    [self.view addSubview:self.videoSubmitViewController.view];
    [self.view bringSubviewToFront:self.actionBarView];
    [self.player play];
    
    self.singleTapOnVideoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    self.singleTapOnVideoGestureRecognizer.numberOfTapsRequired = 1;
    
}

- (void)startPlayback
{
    [self.player play];
//    [self monitoringPlayback:self.playerItem];

}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    __weak VideoReviewViewController *weakSelf = self;
    
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = (CGFloat)playerItem.currentTime.value/playerItem.currentTime.timescale;
        [weakSelf updateVideoProgress:currentSecond];
    }];
}

- (void)updateVideoProgress:(CGFloat) currentSecond
{
    ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)togglePlay:(id)sender
{
    if (isPlaying) {
        [self.player pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
//        self.playButton.titleLabel.text = @"Play";
        isPlaying = NO;
    }
    else{
        [self.player play];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
//        self.playButton.titleLabel.text = @"Pause";
        isPlaying = YES;

    }
}

- (void)dismissKeyboard
{
    [self.videoSubmitViewController.captionTextField resignFirstResponder];
    [self.videoSubmitViewController.locationTextField resignFirstResponder];
}

- (void)exploreButtonTapped
{
    [self.delegate exploreButtonOnVideoReviewViewTapped];
}
- (void)settingButtonTapped
{
    [self.delegate settingButtonOnVideoReviewViewTapped];
}
- (void)cameraButtonTapped
{
    [self.delegate cameraButtonOnVideoReviewViewTapped];
}




- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:@"UIKeyboardDidHideNotification"
                                               object:nil];
    
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardDidHideNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}


#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
//    CGRect locationFrame = [self.view convertRect:self.videoSubmitViewController.locationTextField.frame fromView:self.videoSubmitViewController.view];
    
    CGRect locationFrame = [self.videoSubmitViewController.view convertRect:self.videoSubmitViewController.locationTextField.frame toView:self.view];
    
    CGFloat locationY = locationFrame.origin.y + self.videoSubmitViewController.locationTextField.frame.size.height;
    
    CGFloat keyboardY = self.view.frame.size.height - kbSize.height;
    
    if (locationY > keyboardY) {
        
        CGFloat y = keyboardY - self.videoSubmitViewController.locationTextField.frame.size.height
                              - self.videoSubmitViewController.locationTextField.frame.origin.y
                              - kPadding;
        
        CGFloat height = self.view.frame.size.height - y;
        
        CGRect newFrame = CGRectMake(0, y,
                                     self.view.frame.size.width, height);

//        CGRect newFrame = CGRectMake(0, keyboardY - self.videoSubmitViewController.locationTextField.frame.size.height - kCaptionPadding,
//                                     self.view.frame.size.width, keyboardY + self.videoSubmitViewController.captionTextField.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            self.videoSubmitViewController.view.frame = newFrame;
        }];
    }
    
    [self.playerView addGestureRecognizer:self.singleTapOnVideoGestureRecognizer];
}

- (void)keyboardDidHide:(NSNotification *)note {
    CGRect frame = self.videoSubmitViewController.view.frame;
    
    if (frame.size.height != videoSubmitViewFrame.size.height ||
        frame.origin.y != videoSubmitViewFrame.origin.y) {
        [UIView animateWithDuration:0.3 animations:^{
            self.videoSubmitViewController.view.frame = videoSubmitViewFrame;
        }];

    }
    
    [self.playerView removeGestureRecognizer:self.singleTapOnVideoGestureRecognizer];
}

#pragma mark - Player method

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    self.player.muted = YES;
    [playerItem seekToTime:kCMTimeZero];
}

@end
