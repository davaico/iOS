//
//  ExploreViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-20.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "ExploreViewController.h"
//int kMuteButtonWidth = 40;
NSTimeInterval kHideMuteButtonInterval = 5.0f;

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.videos = [[NSMutableArray alloc]init];
    [self reloadData];
    [self refresh];
//    [self setupMuteButton];
    self.barTitle.text = @"Explore";
    
    if ([self.videos count] == 0) {
        self.spinnerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SpinnerViewController"];
        NSLog(@"videos 0");
    }
    else {
        [self setupVideoView];
        [self setupMute];
    }
    [self.view bringSubviewToFront:self.actionBarView];

}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.spinnerViewController) {
        NSLog(@"spinnerViewController");
        [self.view addSubview:self.spinnerViewController.view];
        [self.view bringSubviewToFront:self.spinnerViewController.view];
        [self.view bringSubviewToFront:self.actionBarView];
        [self.spinnerViewController.spinner startAnimating];
//        [self presentViewController:self.spinnerViewController animated:NO completion:^{
//            [self.spinnerViewController.spinner startAnimating];
//        }];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(displayMuteButton)
//                                                 name:@"DisplayMuteButton"
//                                               object:nil];
    
    // mute / unmute player
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(mutePlayer)
//                                                 name:@"MutePlayer"
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(unmutePlayer)
//                                                 name:@"UnmutePlayer"
//                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                 name:@"DisplayMuteButton"
//                                               object:nil];

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"MutePlayer"
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"UnmutePlayer"
//                                                  object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    @synchronized(self) {
        NetworkController *networkController = [NetworkController sharedController];
        UserProfile *userProfile = [UserProfile sharedProfile];
        [networkController fetchVideos:userProfile.user.username];
    }
}

- (void)reloadData
{
    @synchronized(self) {
        DataController *dataController = [DataController sharedController];
        
        NSArray *result = [dataController fetchAllVideos];
        
        NSArray *dirPaths;
        NSString *docsDir;
        NSString *newDir;
        //    NSFileManager *fileManager = [NSFileManager defaultManager];
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        newDir = [docsDir stringByAppendingPathComponent:@"Videos"];
        //    NSArray *contents = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:newDir] includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
        
        NSMutableArray *newVideos = [[NSMutableArray alloc]init];
        
        // search the videos in the result list that are not in the explore view video list
        for (Video *video in result) {
            BOOL existed = NO;
            for (Video *oldVideo in self.videos) {
                if ([[video.localURL lastPathComponent] isEqualToString:[oldVideo.localURL lastPathComponent]]) {
                    existed = YES;
                    break;
                }
            }
            // new video
            if (!existed) {
                // special case, the default video
//                if ([video.username isEqualToString:@"Davai"]) {
//                    video.localURL = [[[NSBundle mainBundle] URLForResource:@"davai_portrait" withExtension:@"mp4"] absoluteString];
//                }
                // other videos
//                else {
                    NSURL *url = [NSURL fileURLWithPath:[newDir stringByAppendingPathComponent:[video.localURL lastPathComponent]]];
                    video.localURL = [url absoluteString];
//                }
                [newVideos insertObject:video atIndex:0];
            }
        }
//        NSLog(@"new videos: %lu", (unsigned long)[newVideos count]);
        if ([newVideos count] > 0) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                   NSMakeRange(0,[newVideos count])];
            [self.videos insertObjects:newVideos atIndexes:indexes];
            //        [self.videos addObjectsFromArray:newVideos];
            self.videos = [NSMutableArray arrayWithArray:[dataController sortVideos:self.videos ByDateAscending:NO]];
        }
        
        self.videoPageViewController.dataSource = nil;
        self.videoPageViewController.dataSource = self;

    }
}

- (void)likeVideo:(NSDictionary*)videoDict
{
    NetworkController *networkController = [NetworkController sharedController];
    [networkController likeVideo:videoDict];
}

- (void)moveToVideo:(NSDictionary*)videoDict
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if(self.spinnerViewController)
        [self dismissSpinner];
    
//    DataController *dataController = [DataController sharedController];
//    Video *video = [dataController videoWithVideoID:[videoDict objectForKey:@"videoID"]];
    int index = 0;
    for (int i = 0; i < self.videos.count; i = i + 1) {
        Video *video = [self.videos objectAtIndex:i];
//        NSLog(@"i %d, %@, %@", i, video.videoID, [videoDict objectForKey:@"videoID"]);
        if ([video.videoID isEqualToString:[videoDict objectForKey:@"videoID"]]) {
            index = i;
            break;
        }
    }
    
//    unsigned long index = [self.videos indexOfObject:video];
    VideoContentViewController* startingViewController = [self viewControllerAtIndex:index];
    NSArray* viewControllers = @[startingViewController];
    [self.videoPageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished)
            {
                if (finished) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
            }];
}


- (void)exploreButtonTapped
{
    [self refresh];
}
- (void)settingButtonTapped
{
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.settingViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}

- (void)cameraButtonTapped
{
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.cameraViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}

//- (void)muteButtonTapped
//{
//    if (self.muted)
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnmutePlayer" object:nil];
//    else
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MutePlayer" object:nil];
//}

//- (void)displayMuteButton:(NSNotification*)notification

- (void)dismissSpinner
{
    [self.spinnerViewController.spinner stopAnimating];
    [self.spinnerViewController.spinner removeFromSuperview];
    self.spinnerViewController = nil;
    [self setupVideoView];
    [self setupMute];
    [self.view bringSubviewToFront:self.actionBarView];
    
//    [self.spinnerViewController dismissViewControllerAnimated:NO completion:^{
//    }];
}

- (void)setupMute
{
//    [self mutePlayer];
    if (self.muted)
        [self mutePlayer];
    else
        [self unmutePlayer];
    [self displayMuteButton];
}
- (void)displayMuteButton
{
    self.muteButtonHidden = NO;
    for (VideoContentViewController *vcvc in self.videoPageViewController.viewControllers)
        [vcvc unhideMuteButton];
//    if (self.cachedVideoContentViewControllers)
//        for (VideoContentViewController *vcvc in self.cachedVideoContentViewControllers)
//            [vcvc unhideMuteButton];
    
    if (self.hideMuteButtonTimer != nil) {
        [self.hideMuteButtonTimer invalidate];
        self.hideMuteButtonTimer = nil;
    }
    self.hideMuteButtonTimer = [NSTimer scheduledTimerWithTimeInterval:kHideMuteButtonInterval target:self selector:@selector(hideMuteButton) userInfo:nil repeats:NO];
}

- (void)hideMuteButton
{
    if (self.hideMuteButtonTimer != nil) {
        [self.hideMuteButtonTimer invalidate];
        self.hideMuteButtonTimer = nil;
    }
    self.muteButtonHidden = YES;
//    if (self.cachedVideoContentViewControllers)
//        for (VideoContentViewController *vcvc in self.cachedVideoContentViewControllers)
//            [vcvc hideMuteButton];
    for (VideoContentViewController *vcvc in self.videoPageViewController.viewControllers)
        [vcvc hideMuteButton];
}


//- (void)setupMuteButton
//{
//    self.muteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (4 * kMuteButtonWidth), 0, kMuteButtonWidth, kMuteButtonWidth)];
//    self.muteButton.backgroundColor = [UIColor clearColor];
//    self.muteButton.opaque = NO;
//    
//    [self.muteButton setImage:[UIImage imageNamed:@"Muted"] forState:UIControlStateNormal];
//
//    [self.actionBarView addSubview:self.muteButton];
//    [self.muteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSDictionary *viewsDictionary = @{@"actionBarView":self.actionBarView,
//                                      @"davaiLogo":self.davaiLogo,
//                                      @"barTitle":self.barTitle,
//                                      @"exploreButton":self.exploreButton,
//                                      @"settingButton":self.settingButton,
//                                      @"cameraButton":self.cameraButton,
//                                      @"muteButton":self.muteButton};
//    [self.muteButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[muteButton(==40)]"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//    [self.muteButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[muteButton(==40)]"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[muteButton][exploreButton]"
//                                                                               options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//    [self.muteButton addTarget:self action:@selector(muteButtonTapped)
//                 forControlEvents:UIControlEventTouchUpInside];
//}

- (void)setupVideoView
{
//    self.videoTitles = @[@"video 1", @"video 2", @"video 3"];
    
    self.videoPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPageViewController"];
    self.videoPageViewController.delegate = self;
    self.videoPageViewController.dataSource = self;
    
    VideoContentViewController* startingViewController = [self viewControllerAtIndex:0];
    NSArray* viewControllers = @[startingViewController];
    [self.videoPageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    [self reloadData];
    //    self.videoPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.videoPageViewController];
    [self.view addSubview:self.videoPageViewController.view];
    [self.videoPageViewController didMoveToParentViewController:self];
    
}

#pragma mark - Video Page Datasource Methods

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((VideoContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((VideoContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.videos count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark -

- (VideoContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.videos count] == 0) || (index >= [self.videos count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    VideoContentViewController *videoContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoContentViewController"];
    videoContentViewController.video = self.videos[index];
    videoContentViewController.pageIndex = index;
    videoContentViewController.delegate = self;
    videoContentViewController.muted = self.muted;
    videoContentViewController.muteButtonHidden = self.muteButtonHidden;
    
//    if (self.muted)
//        [videoContentViewController mutePlayer];
//    else
//        [videoContentViewController unmutePlayer];
    //    [videoContentViewController setupUserProfile:self.userProfile];
    
    return videoContentViewController;
}


#pragma mark - Page View Controller Delegate Method
// store the previous view controller
//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    if (completed) {
//        self.cachedVideoContentViewControllers = previousViewControllers;
//        for (VideoContentViewController *vcvc in previousViewControllers)
//            [vcvc.player pause];
//    }
//}

#pragma mark - Post Comment
- (void)postComment:(NSDictionary*)commentDict
{
    NetworkController *netwrokController = [NetworkController sharedController];
    [netwrokController postComment:commentDict];
}

#pragma mark - mute and unmute player methods
- (void)mutePlayer
{
    self.muted = YES;
    for (VideoContentViewController *vcvc in self.videoPageViewController.viewControllers)
        [vcvc mutePlayer];
//    if (self.cachedVideoContentViewControllers)
//        for (VideoContentViewController *vcvc in self.cachedVideoContentViewControllers)
//            [vcvc mutePlayer];
}

- (void)unmutePlayer
{
    self.muted = NO;
    for (VideoContentViewController *vcvc in self.videoPageViewController.viewControllers)
        [vcvc unmutePlayer];
//    if (self.cachedVideoContentViewControllers)
//        for (VideoContentViewController *vcvc in self.cachedVideoContentViewControllers)
//            [vcvc unmutePlayer];
}

#pragma mark - Internet Connectivity Method
- (void)reachabilityDidChange:(NSNotification*)notification
{
    NetworkController *networkController = [NetworkController sharedController];
    if (![networkController hasConnectivity]) {
        NoNetworkErrorViewController *noNetworkErrorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoNetworkErrorViewController"];
        [self presentViewController:noNetworkErrorViewController animated:YES completion:nil];
    }
}

@end
