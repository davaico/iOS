//
//  VideoContentViewController.m
//  davai
//
//  Created by Zhi Li on 2014-09-15.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "VideoContentViewController.h"
int kMuteButtonWidth = 25;


// Info Bar variables
enum InfoBarPosition {TOP, BOTTOM, KEYBOARD};
enum InfoBarPosition infoBarPosition;
int kActionBarHeight = 50;
CGFloat kInfoBarHeight = 80;
CGFloat kCommentInputHeight = 50;
//CGPoint kInfoBarCenterAtTop, kInfoBarCenterAtBottom;
CGPoint touchBeginPosition;
CGPoint lastTouchPosition;
CGPoint relativePositionToInfoBarOrigin;

CGRect infoBarFrameAtTop, infoBarFrameAtBottom;
//CGRect commentInputViewOriginalFrame;

@interface VideoContentViewController ()

@end

@implementation VideoContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerView = [[UIView alloc]initWithFrame:self.view.frame];
    NSURL *url = [NSURL URLWithString:self.video.localURL];
//    NSLog(@"%@\n%@\n%@", url, self.video.date, self.video.location);
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
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
    
    [self setupMuteButton];
    if (self.muted)
        [self mutePlayer];
    else
        [self unmutePlayer];

    if (![self.video.username isEqualToString:@"Davai"]) {
        [self setupInfoBar];
    }

    
    [self setupGestures];
}

#pragma mark - Setup Methods

- (void)setupInfoBar
{
    self.infoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    self.infoViewController.delegate = self;
    infoBarFrameAtTop = CGRectMake(0,
                                   kActionBarHeight,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height - kActionBarHeight);
    infoBarFrameAtBottom = CGRectMake(0,
                                      self.view.frame.size.height - kInfoBarHeight,
                                      self.view.frame.size.width,
                                      kInfoBarHeight + kCommentInputHeight);
    
    self.infoViewController.view.frame = CGRectMake(0, kActionBarHeight, self.view.frame.size.width, self.view.frame.size.height - kActionBarHeight);
    
    self.infoViewController.videoCaptionLabel.text = self.video.caption;
    if (self.video.location)
        self.infoViewController.videoLocationLabel.text = self.video.location;
    
    DataController *dataController = [DataController sharedController];
    self.infoViewController.commentData = [[NSMutableArray alloc]initWithArray:[dataController fetchCommentsForVideo:self.video]];
//    self.infoViewController.commentData = [[NSMutableArray alloc]initWithArray:[self.video.comment array]];
//    self.infoViewController.commentData = [[NSMutableArray alloc]init];
    self.infoViewController.liked = [self.video.liked boolValue];
    [self addChildViewController:self.infoViewController];
    [self.view addSubview: self.infoViewController.view];
    [self.infoViewController didMoveToParentViewController:self];
    [self moveInfoBarToBottom];
}

- (void)setupGestures
{
    // info bar tap gesture
    self.tapOnInfoBarGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToMoveInfoBar:)];
    self.tapOnInfoBarGestureRecognizer.numberOfTapsRequired = 1;
    self.tapOnInfoBarGestureRecognizer.delegate = self;
    [self.infoViewController.infoBarView addGestureRecognizer:self.tapOnInfoBarGestureRecognizer];

    // info bar swipe gesture
    self.swipeOnInfoBarGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToMoveInfoBar:)];
    self.swipeOnInfoBarGestureRecognizer.minimumPressDuration = 0.05;
    self.swipeOnInfoBarGestureRecognizer.numberOfTapsRequired = 0;
    self.swipeOnInfoBarGestureRecognizer.delegate = self;
    [self.infoViewController.infoBarView addGestureRecognizer:self.swipeOnInfoBarGestureRecognizer];
    
    // video tap gesture
    self.tapOnVideoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlay)];
    self.tapOnVideoGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapOnVideoGestureRecognizer];
    
    // dismiss keyboard gestures
    self.tapOnInfoBarDismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    self.tapOnInfoBarDismissKeyboardGestureRecognizer.numberOfTapsRequired = 1;
    self.tapOnVideoDismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    self.tapOnVideoDismissKeyboardGestureRecognizer.numberOfTapsRequired = 1;
    
    self.likeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeVideo)];
    self.likeGestureRecognizer.numberOfTapsRequired = 1;
    self.likeGestureRecognizer.delegate = self;
    [self.infoViewController.infoBarView addGestureRecognizer:self.likeGestureRecognizer];

}

- (void)setupMuteButton
{
    self.muteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMuteButtonWidth, kMuteButtonWidth)];
    self.muteButton.backgroundColor = [UIColor clearColor];
    self.muteButton.opaque = NO;
    
    [self.muteButton setImage:[UIImage imageNamed:@"Muted"] forState:UIControlStateNormal];
    
    [self.playerView addSubview:self.muteButton];
    [self.muteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewsDictionary = @{@"view":self.view,
                                      @"muteButton":self.muteButton};
    [self.muteButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[muteButton(==25)]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    [self.muteButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[muteButton(==25)]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    [self.playerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[muteButton]-180-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary]];
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:self.muteButton
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.playerView
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [self.muteButton addTarget:self action:@selector(muteButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];

    [self.playerView bringSubviewToFront:self.muteButton];

}

#pragma mark - Player Methods
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak VideoContentViewController *weakSelf = self;
    
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(300, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = (CGFloat)playerItem.currentTime.value/playerItem.currentTime.timescale;// The calculation of the current in the first few seconds
        [weakSelf updateVideoProgressIcon:currentSecond];
    }];
}

- (void)updateVideoProgressIcon
{
    NSTimeInterval videoDateElapsed = [[NSDate new]timeIntervalSinceDate:self.video.date];
    NSTimeInterval videoLife = 24.0 * 60.0 * 60.0;
    CGFloat percent = videoDateElapsed / videoLife;
    [self.infoViewController updateVideoProgressWitePercent:percent];
}

- (void)updateVideoProgressIcon:(CGFloat) currentSecond
{
    CGFloat percent = currentSecond / self.duration;
    [self.infoViewController updateVideoProgressWitePercent:percent];
}

- (void)togglePlay
{
    if (!self.player.error) {
        
        [self.delegate displayMuteButton];

        if (self.player.rate > 0)
            [self.player pause];
        else
            [self.player play];
    }
}

- (void)muteButtonTapped
{
    if (self.muted)
        [self.delegate unmutePlayer];
    else
        [self.delegate mutePlayer];
}


#pragma mark - show and dismiss action bar and info bar
- (void)dismissActionView
{
    
}

- (void)showActionView
{
    
}


#pragma mark - Touch methods
// Handle Tap Gestures

- (void)likeVideo
{
//    NSLog(@"likeVideo");
    
//    if ([self.video.liked boolValue] != YES) {
        UserProfile *userProfile = [UserProfile sharedProfile];
        NSDictionary *videoDict = @{@"videoID":self.video.videoID,
                                    @"username":userProfile.user.username};
        [self.delegate likeVideo:videoDict];
//    }
}

- (void)dismissKeyboard
{
    [self.infoViewController.commentInput resignFirstResponder];
}


- (void)tapToMoveInfoBar:(UITapGestureRecognizer*)gesture
{
    if (gesture == self.tapOnInfoBarGestureRecognizer
        || gesture == self.tapOnInfoBarDismissKeyboardGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerStateEnded){
            [self.infoViewController.commentBarView setHidden:YES];
            if (infoBarPosition == BOTTOM)
                [self moveInfoBarToTop];
            else if (infoBarPosition == TOP)
                [self moveInfoBarToBottom];
            [self.infoViewController.commentBarView setHidden:NO];
        }
    }
}

// Handle Vertical Swipe Gesture
- (void)swipeToMoveInfoBar:(UISwipeGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan){
        [self.infoViewController.commentBarView setHidden:YES];
        touchBeginPosition = [gesture locationInView:self.view];
        relativePositionToInfoBarOrigin = CGPointMake(self.infoViewController.view.frame.origin.x - touchBeginPosition.x,
                                                      self.infoViewController.view.frame.origin.y - touchBeginPosition.y);
        lastTouchPosition = touchBeginPosition;
        [self.muteButton setHidden:YES];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        lastTouchPosition = [gesture locationInView:self.view];;
        
        CGFloat frameY = lastTouchPosition.y + relativePositionToInfoBarOrigin.y;
        CGFloat frameHeight = self.view.frame.size.height - frameY;
        
        CGRect newFrame = CGRectMake(0, frameY, self.view.frame.size.width, frameHeight);
        self.infoViewController.view.frame = newFrame;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        if (infoBarPosition == TOP) {
            if (touchBeginPosition.y - lastTouchPosition.y < 5)
                [self moveInfoBarToBottom];
            else
                [self moveInfoBarToTop];
        }
        else if (infoBarPosition == BOTTOM) {
            if (touchBeginPosition.y - lastTouchPosition.y > -5)
                [self moveInfoBarToTop];
            else
                [self moveInfoBarToBottom];
        }
        [self.infoViewController.commentBarView setHidden:NO];
    }
    
}


#pragma mark - InfoView Movement Methods
- (void)moveInfoBarToTop
{
    
    CGFloat cellRowHeight = self.infoViewController.commentTable.rowHeight;
    long numberOfCell = [self.infoViewController.commentTable numberOfRowsInSection:0];
    
    
    CGFloat maxFrameHeight = self.view.frame.size.height - kActionBarHeight;
    CGFloat frameHeight = kInfoBarHeight + kCommentInputHeight + cellRowHeight * numberOfCell;
    
    if (frameHeight > maxFrameHeight)
        frameHeight = maxFrameHeight;
    
    infoBarFrameAtTop = CGRectMake(0, self.view.frame.size.height - frameHeight,
                                   self.view.frame.size.width, frameHeight);
    
    [self moveInfoBarWithFrame:infoBarFrameAtTop animated:YES];
    infoBarPosition = TOP;
    [self.muteButton setHidden:YES];
}

- (void) moveInfoBarToBottom
{
    [self moveInfoBarWithFrame:infoBarFrameAtBottom animated:YES];
    infoBarPosition = BOTTOM;
//    [self.muteButton setHidden:NO];
}

- (void) moveInfoBarWithFrame:(CGRect)frame animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"MoveInfoBar" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2f];
        self.infoViewController.view.frame = frame;
        [UIView commitAnimations];
    }
    else
        self.infoViewController.view.frame = frame;
}


#pragma mark - mute and unmute player methods
- (void)mutePlayer
{
    self.muted = YES;
    self.player.muted = YES;
    [self.muteButton setImage:[UIImage imageNamed:@"Unmuted"]
                     forState:UIControlStateNormal];
}

- (void)unmutePlayer
{
    self.muted = NO;
    self.player.muted = NO;
    [self.muteButton setImage:[UIImage imageNamed:@"Muted"]
                     forState:UIControlStateNormal];
}

#pragma mark - hide and unhide mute button methods
- (void)hideMuteButton
{
    [self.muteButton setHidden:YES];
    self.muteButtonHidden = YES;
}

- (void)unhideMuteButton
{
    [self.muteButton setHidden:NO];
    self.muteButtonHidden = NO;
}

#pragma mark -

- (void)appDidBecomeForeground
{
    self.layer.player = nil;
    self.layer.player = self.player;
    [self.player play];
}


#pragma mark - Player method
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
//    [self.player pause];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
//    [self.view bringSubviewToFront:self.muteButton];
    self.layer.player = self.player;
    
    if (self.muteButtonHidden)
        [self hideMuteButton];
    else
        [self unhideMuteButton];

    if (self.videoLifeIconUpdateTimer != nil) {
        [self.videoLifeIconUpdateTimer invalidate];
    }
    self.videoLifeIconUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(updateVideoProgressIcon) userInfo:nil repeats:YES];

    
    [self.infoViewController.commentTable reloadData];
    [self.infoViewController updateLowerIcon];
    [self updateVideoProgressIcon];

    // player
    self.player.muted = self.muted;
//    [self monitoringPlayback:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadComments:)
                                                 name:@"CommentDidUpdate"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidLike:)
                                                 name:@"VideoDidLike"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player pause];
    [self.videoLifeIconUpdateTimer invalidate];
    self.videoLifeIconUpdateTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.layer.player = nil;
    // player
//    [self.player pause];
    // remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    
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
                                                    name:@"CommentDidUpdate"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VideoDidLike"
                                                  object:nil];

}


#pragma mark - Notifications
- (void)reloadComments:(NSNotification*)notification
{
    NSDictionary *videoDict = notification.userInfo;
    if ([[videoDict objectForKey:@"videoID"] isEqualToString:self.video.videoID]) {
        [self.infoViewController.commentTable reloadData];
    }
}

- (void)videoDidLike:(NSNotification*)notification
{
    NSDictionary *videoDict = notification.userInfo;
//    NSLog(@"videodidlike %@", videoDict);
    if ([[videoDict objectForKey:@"videoID"] isEqualToString:self.video.videoID]) {
        self.video.liked = [NSNumber numberWithBool:YES];
        self.infoViewController.liked = [self.video.liked boolValue];
        [self.infoViewController updateLowerIcon];
        [self updateVideoProgressIcon];
    }
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // keyboard gestures
    [self.infoViewController.infoBarView removeGestureRecognizer:self.swipeOnInfoBarGestureRecognizer];
    [self.infoViewController.infoBarView removeGestureRecognizer:self.tapOnInfoBarGestureRecognizer];
    [self.view removeGestureRecognizer:self.tapOnVideoGestureRecognizer];
    
    [self.infoViewController.infoBarView addGestureRecognizer:self.tapOnInfoBarDismissKeyboardGestureRecognizer];
    [self.view addGestureRecognizer:self.tapOnVideoDismissKeyboardGestureRecognizer];
    
    
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat cellRowHeight = self.infoViewController.commentTable.rowHeight;
    long numberOfCell = [self.infoViewController.commentTable numberOfRowsInSection:0];
    
    CGFloat maxFrameHeight = self.view.frame.size.height - kActionBarHeight - kbSize.height;
    CGFloat frameHeight = kInfoBarHeight + kCommentInputHeight + cellRowHeight * numberOfCell;
    
    if (frameHeight > maxFrameHeight)
        frameHeight = maxFrameHeight;
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height - frameHeight - kbSize.height,
                                   self.view.frame.size.width, frameHeight);
    
    [self moveInfoBarWithFrame:frame animated:YES];
    infoBarPosition = KEYBOARD;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [self moveInfoBarToTop];
    
    // keyboard gestures
    [self.infoViewController.infoBarView removeGestureRecognizer:self.tapOnInfoBarDismissKeyboardGestureRecognizer];
    [self.view removeGestureRecognizer:self.tapOnVideoDismissKeyboardGestureRecognizer];
    
    [self.infoViewController.infoBarView addGestureRecognizer:self.swipeOnInfoBarGestureRecognizer];
    [self.infoViewController.infoBarView addGestureRecognizer:self.tapOnInfoBarGestureRecognizer];
    [self.view addGestureRecognizer:self.tapOnVideoGestureRecognizer];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frame = CGRectMake(self.infoViewController.view.frame.origin.x,
                              self.infoViewController.view.frame.origin.y,
                              self.infoViewController.view.frame.size.width,
                              self.view.frame.size.height - self.infoViewController.view.frame.origin.y);
    self.infoViewController.view.frame = frame;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delegate Method
- (void)addComment:(NSString *)comment
{
//    return;
    UserProfile *userProfile = [UserProfile sharedProfile];
    DataController *dataController = [DataController sharedController];
    NSDate *now = [NSDate new];
    NSDictionary *commentDict = @{ @"text" : comment,
                                   @"username" : userProfile.user.username,
                                   @"videoAuthorName":self.video.username,
                                   @"videoID":self.video.videoID,
                                   @"date":now};
    Comment *newComment = [dataController addComment:commentDict toVideo:self.video];
    [self.infoViewController.commentData insertObject:newComment atIndex:self.infoViewController.commentData.count];
    [self.infoViewController.commentTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    [self.delegate postComment:commentDict];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pointInView = [touch locationInView:gestureRecognizer.view];
    
//    NSLog(@"shouldReceiveTouch %@", gestureRecognizer);
    if (gestureRecognizer == self.likeGestureRecognizer
        && CGRectContainsPoint(self.infoViewController.videoProgressImage.frame, pointInView) ) {
//        NSLog(@"like frame");
        return YES;
    }
    if ((gestureRecognizer == self.tapOnInfoBarGestureRecognizer || gestureRecognizer == self.swipeOnInfoBarGestureRecognizer)
        && !CGRectContainsPoint(self.infoViewController.videoProgressImage.frame, pointInView) ) {
//        NSLog(@"! like frame");
        return YES;
    }
    
    return NO;
}

@end
