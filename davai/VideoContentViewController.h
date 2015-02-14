//
//  VideoContentViewController.h
//  davai
//
//  Created by Zhi Li on 2014-09-15.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "InfoViewController.h"
//#import "Video.h"
#import "UserProfile.h"

@protocol VideoContentViewControllerDelegate <NSObject>

@required

- (void)postComment:(NSDictionary*)commentDict;
- (void)likeVideo:(NSDictionary*)videoDict;
- (void)mutePlayer;
- (void)unmutePlayer;
- (void)displayMuteButton;

@end


@interface VideoContentViewController : UIViewController<InfoViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *layer;
@property (nonatomic) Float64 duration;
@property (nonatomic, strong) id playbackTimeObserver;

@property (nonatomic, strong) NSTimer *videoLifeIconUpdateTimer;


//@property (nonatomic, weak) IBOutlet PlayerView *playerView;

@property (nonatomic) NSUInteger pageIndex;
//@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) Video *video;
@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL muteButtonHidden;


@property (nonatomic, strong) InfoViewController *infoViewController;


@property (nonatomic, strong) UIButton *muteButton;

//@property (strong, nonatomic) UITapGestureRecognizer *singleTapOnVideoGestureRecognizer;
//@property (strong, nonatomic) UITapGestureRecognizer *doubleTapOnVideoGestureRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *tapOnVideoGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapOnInfoBarGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *swipeOnInfoBarGestureRecognizer;;

@property (nonatomic, strong) UITapGestureRecognizer *tapOnInfoBarDismissKeyboardGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapOnVideoDismissKeyboardGestureRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *likeGestureRecognizer;


@property (nonatomic, strong) id<VideoContentViewControllerDelegate>delegate;

//- (void)setupUserProfile:(NSMutableDictionary *)userProfile;
- (void)mutePlayer;
- (void)unmutePlayer;
- (void)hideMuteButton;
- (void)unhideMuteButton;

- (void)addComment:(NSString *)comment;

//- (void)resetPlayer;

@end
