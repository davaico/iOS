//
//  ViewController.m
//  davai
//
//  Created by Zhi Li on 2014-09-15.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "ViewController.h"

BOOL initFinished = NO;
NSDictionary *transitionControllers;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DataController sharedController] setManagedObjectContext:self.managedObjectContext];
    [NetworkController sharedController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addVideoToStore:)
                                                 name:@"VideoInformationDidPost"
                                               object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(completeVideoFileUpload:)
//                                                 name:@"VideoFileDidUpload"
//                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addVideoToStore:)
                                                 name:@"VideoFileDidDownload"
                                               object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeSpinner:)
//                                                 name:@"SpinnerShouldRemove"
//                                               object:nil];
//
    
    [self setupActionBar];

    self.welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
//    [self setupDefaultVideo];
}

//- (void)displayFonts
//{
//    for (id familyName in [UIFont familyNames]) {
//        NSLog(@"%@", familyName);
//        for (id fontName in [UIFont fontNamesForFamilyName:familyName]) NSLog(@"  %@", fontName);
//    }
//}

- (void)viewDidAppear:(BOOL)animated
{
    [self initialView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup Methods

- (void)setupActionBar
{
    ExploreViewController *exploreViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExploreViewController"];
    SettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    CameraViewController *cameraViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    actionBarViewControllerCollection.exploreViewController = (ActionViewController*)exploreViewController;
    actionBarViewControllerCollection.settingViewController = (ActionViewController*)settingViewController;
    actionBarViewControllerCollection.cameraViewController = (ActionViewController*)cameraViewController;

    exploreViewController.delegate = self;
    settingViewController.delegate = self;
    cameraViewController.delegate = self;

    exploreViewController.modalPresentationStyle = UIModalPresentationCustom;
    settingViewController.modalPresentationStyle = UIModalPresentationCustom;
    cameraViewController.modalPresentationStyle = UIModalPresentationCustom;
    exploreViewController.transitioningDelegate = self;
    settingViewController.transitioningDelegate = self;
    cameraViewController.transitioningDelegate = self;
}

- (void)setupDefaultVideo
{
    DataController *dataController = [DataController sharedController];
    NSArray *videos = [dataController fetchAllVideos];
    if ([videos count] ==0) {
        User *user = [dataController userWithUsername:@"Davai"];
        if (!user) {
            NSDictionary *userInfo = @{ @"username" : @"Davai" };
            user = [dataController userMake:userInfo];
        }
        NSString *localURL = [[[NSBundle mainBundle] URLForResource:@"davai_portrait" withExtension:@"mp4"]absoluteString];
        NSDictionary *videoInfo = @{ @"caption" : @"Davai",
                                     @"localURL" : localURL };
        [dataController addVideo:videoInfo author:user comments:nil];
        NSArray *result = [dataController fetchAllVideos];
//        NSLog(@"videos count %lu", (unsigned long)[result count]);
        [dataController save];
    }
}

//- (void)showSpinner
//{
//    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.center.x - 50,self.view.center.y - 50,100,100)];
//    self.spinner.color = [UIColor greenColor];
//    [self.spinner startAnimating];
//    [self.view addSubview:self.spinner];
//}
//
//- (void)removeSpinner:(NSNotification*)notification
//{
//    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
//    ExploreViewController *exploreViewController = (ExploreViewController*)actionBarViewControllerCollection.exploreViewController;
//    if (self.spinner && [exploreViewController.videos count] > 0) {
//        [self.spinner removeFromSuperview];
//        self.spinner = nil;
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:@"SpinnerShouldRemove"
//                                                      object:nil];
//    }
//}

- (void)initialView
{
    if (![[UserProfile sharedProfile]userLoggedIn]) {
        self.loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.loginViewController.delegate = self;
        
        [self presentViewController:self.loginViewController
                           animated:YES
                         completion:nil];
    }
    else{
        if (![self.welcomeViewController viewed]) {
            [self presentViewController:self.welcomeViewController
                               animated:YES
                             completion:nil];
            [self.welcomeViewController setViewed:YES];
        }
        else{
            if (!initFinished) {
                ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
                ExploreViewController *exploreViewController = (ExploreViewController*)actionBarViewControllerCollection.exploreViewController;
                if (self.loginViewController) {
                    if (self.loginViewController.muted)
                        exploreViewController.muted = YES;
                    else
                        exploreViewController.muted = NO;
                    self.loginViewController = nil;
                }
                else
                    exploreViewController.muted = YES;
                
//                if ([exploreViewController.videos count] == 0)
//                    [self showSpinner];
//                else
                [self presentViewController:exploreViewController
                                   animated:YES
                                 completion:nil];
                initFinished = YES;
            }
        }
    }
}



#pragma mark - Rotation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Video Information Posting Notification Method
- (void)addVideoToStore:(NSNotification*)notification
{
    NSDictionary *videoDict = notification.userInfo;
//    NSLog(@"completeVideoInformationPost : %@", videoDict);
    UserProfile *userProfile = [UserProfile sharedProfile];
    DataController *dataController = [DataController sharedController];
    [dataController addVideo:videoDict author:userProfile.user comments:nil];
    [dataController save];

    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ExploreViewController *exploreViewController = (ExploreViewController*)actionBarViewControllerCollection.exploreViewController;
    if (exploreViewController.isViewLoaded && exploreViewController.view.window) {
        [exploreViewController reloadData];
        [exploreViewController moveToVideo:videoDict];
    }
//    if (self.spinner) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpinnerShouldRemove"
//                                                            object:nil];
//    }
}



//#pragma mark - Video File Upload Notification Method
//- (void)completeVideoFileUpload:(NSNotification*)notification
//{
//    NSDictionary *videoDict = notification.userInfo;
//    NSLog(@"completeVideoFileUpload : %@", videoDict);
//    DataController *dataController = [DataController sharedController];
////    Video *video = [dataController videoWithVideoID:[videoDict objectForKey:@"videoID"]];
//    
//}


#pragma mark - Delegate Methods
#pragma mark - Action View Controller Delegate Method
- (void)transitFromActionViewController:(ActionViewController *)fromActionViewController toActionViewController:(ActionViewController *)toActionViewController animated:(BOOL)animated
{
    transitionControllers = @{ @"fromActionViewController":fromActionViewController,
                               @"toActionViewController":toActionViewController };
    [fromActionViewController dismissViewControllerAnimated:animated
                                                 completion:^{
        [self presentViewController:toActionViewController
                           animated:animated
                         completion:nil];
    }];
    
}

#pragma mark - Camera View Controller Delegate Method
-(void)postVideo:(NSDictionary*)info
{
    UserProfile *userProfile = [UserProfile sharedProfile];
    NSMutableDictionary *videoInfo = [[NSMutableDictionary alloc]initWithDictionary:info];
    [videoInfo setObject:userProfile.user.username forKey:@"author"];
    
    
    NSString *username = userProfile.user.username;
    NSString *filePath = [info objectForKey:@"localURL"];
    NSString *filename = [filePath lastPathComponent];
    
    NSString *videokey = [NSString stringWithFormat:@"%@/%@", username, filename];
//    [videoInfo setObject:filename forKey:@"videokey"];
    [videoInfo setObject:videokey forKey:@"videokey"];
    
//    NSLog(@"vc videoInfo %@", videoInfo);

    NetworkController *networkController = [NetworkController sharedController];
    [networkController uploadVideoFile:videoInfo];
    
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    CameraViewController *cameraViewController = (CameraViewController*)actionBarViewControllerCollection.cameraViewController;
    ExploreViewController *exploreViewController = (ExploreViewController*)actionBarViewControllerCollection.exploreViewController;

    [self transitFromActionViewController:cameraViewController
                   toActionViewController:exploreViewController
                                 animated:YES];
}

#pragma mark - Login View Delegate Methods
- (void)registerWithUserData:(NSDictionary *)userData
{
    NSDictionary *user = [NetworkController registerWithUserData:userData];
//    NSLog(@"registerWithUserData :%@", user);
    if (user) {
        User *newUser = [[DataController sharedController] userMake:user];
        [[UserProfile sharedProfile] loginWithUser:newUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self.loginViewController retry];
}
- (void)loginWithUserData:(NSDictionary *)userData
{
    NSDictionary *user = [NetworkController logInWithUserData:userData];
//    NSLog(@"loginWithUserData :%@", user);
    if (user) {
        User *newUser = [[DataController sharedController] userMake:user];
        [[UserProfile sharedProfile] loginWithUser:newUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self.loginViewController retry];
}
\
#pragma mark - Setting View Controller Delegate Method
- (void)logout
{
    [[UserProfile sharedProfile] logout];
    initFinished = NO;
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    SettingViewController *settingViewController = (SettingViewController*)actionBarViewControllerCollection.settingViewController;
    [settingViewController dismissViewControllerAnimated:YES completion:^{
        [self initialView];
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate Delegate Methods
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:[ActionViewController class]]) {
        ActionViewPresentAnimationController *actionViewPresentAnimationController = [[ActionViewPresentAnimationController alloc] init];
        
        ActionViewController *fromActionViewController = [transitionControllers objectForKey:@"fromActionViewController"];
        ActionViewController *toActionViewController = [transitionControllers objectForKey:@"toActionViewController"];
        
        ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
        ExploreViewController *exploreViewController = (ExploreViewController*)actionBarViewControllerCollection.exploreViewController;
        SettingViewController *settingViewController = (SettingViewController*)actionBarViewControllerCollection.settingViewController;
        CameraViewController *cameraViewController = (CameraViewController*)actionBarViewControllerCollection.cameraViewController;
        
        if ( (fromActionViewController == exploreViewController) &&
            (toActionViewController == settingViewController || toActionViewController == cameraViewController) )
            actionViewPresentAnimationController.direction = LEFT;
        else if ( (fromActionViewController == settingViewController) &&
                 (toActionViewController == exploreViewController) )
            actionViewPresentAnimationController.direction = RIGHT;
        else if ( (fromActionViewController == settingViewController) &&
                 (toActionViewController == cameraViewController) )
            actionViewPresentAnimationController.direction = LEFT;
        else if ( (fromActionViewController == cameraViewController) &&
                 (toActionViewController == settingViewController || toActionViewController == exploreViewController) )
            actionViewPresentAnimationController.direction = RIGHT;
        
        transitionControllers = nil;
        return actionViewPresentAnimationController;
    }
    else
        return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:[ActionViewController class]])
         return [[ActionViewDismissAnimationController alloc] init];
    else
         return nil;
}

@end
