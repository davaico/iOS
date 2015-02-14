//
//  VideoReviewViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-01.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoSubmitViewController.h"
#import "ActionViewController.h"
#import "ActionBarViewControllerCollection.h"

@protocol VideoReviewViewControllerDelegate <NSObject>

@required

- (void)exploreButtonOnVideoReviewViewTapped;
- (void)settingButtonOnVideoReviewViewTapped;
- (void)cameraButtonOnVideoReviewViewTapped;
@end


@interface VideoReviewViewController : ActionViewController

@property (nonatomic, strong) VideoSubmitViewController *videoSubmitViewController;

@property (nonatomic, strong) NSURL *videoFileUrl;


@property (strong, nonatomic) UIView *playerView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *layer;
@property (nonatomic) Float64 duration;
@property (strong, nonatomic) id playbackTimeObserver;



@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) UIButton *stopButton;
@property (nonatomic, weak) UILabel *progressLabel;

@property (strong, nonatomic) UITapGestureRecognizer *singleTapOnVideoGestureRecognizer;


@property (nonatomic, strong) id<VideoReviewViewControllerDelegate> delegate;

- (void)setupPlayer;
//- (void)setNewVideoFile:(NSURL *)videoFileUrl;
@end
