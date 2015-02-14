//
//  ExploreViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-20.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionViewController.h"
#import "VideoContentViewController.h"
#import "ActionBarViewControllerCollection.h"
#import "DataController.h"
#import "NetworkController.h"
#import "NoNetworkErrorViewController.h"
#import "SpinnerViewController.h"

@interface ExploreViewController : ActionViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, VideoContentViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController* videoPageViewController;
@property (nonatomic, strong) SpinnerViewController* spinnerViewController;

//@property (nonatomic, strong) NSArray* cachedVideoContentViewControllers;

@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) NSTimer *hideMuteButtonTimer;
@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL muteButtonHidden;

- (void)refresh;
- (void)reloadData;
- (void)postComment:(NSDictionary*)commentDict;
- (void)likeVideo:(NSDictionary*)videoDict;
- (void)moveToVideo:(NSDictionary*)videoDict;
- (void)mutePlayer;
- (void)unmutePlayer;
- (void)displayMuteButton;
@end
