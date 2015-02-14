//
//  ActionViewController.m
//  davai
//
//  Created by Zhi Li on 2014-09-18.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "ActionViewController.h"
//#import "SettingViewController.h"
//#import "CameraViewController.h"
//#import "ExploreViewController.h"

int kActionViewHeight = 50;
int kDavaiIconWidth = 50;
int kBarTitleWidth = 160;
int kButtonWidth = 25;


@interface ActionViewController ()

@end

@implementation ActionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self createViews];
    
    [self setupConstraints];
    
    [self linkButtons];

    
}

- (void)createViews
{
    
    // setup action bar
    
    self.actionBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kActionViewHeight)];
    self.actionBarView.backgroundColor = [UIColor colorWithRed:25.0f/255.0f green:171.0f/255.0f blue:111.0f/255.0f alpha:1.0f];
    self.actionBarView.opaque = NO;
    
    self.exploreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kDavaiIconWidth, kDavaiIconWidth)];
    self.exploreButton.backgroundColor = [UIColor clearColor];
    self.exploreButton.opaque = NO;
    [self.exploreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.exploreButton setImage:[UIImage imageNamed:@"Davai White Logo"] forState:UIControlStateNormal];
//    [self.exploreButton setImage:[UIImage imageNamed:@"Toolbar Logo"] forState:UIControlStateNormal];
    
    self.barTitle = [[UILabel alloc] initWithFrame:CGRectMake(0 + kDavaiIconWidth, 0, kBarTitleWidth, kActionViewHeight)];
    self.barTitle.text = @"Action";
    self.barTitle.textColor = [UIColor whiteColor];
    self.barTitle.backgroundColor = [UIColor clearColor];
//    [self.barTitle setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:20]];
    [self.barTitle setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20]];    
    
    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (2 * kButtonWidth), 0, kButtonWidth, kButtonWidth)];
    self.settingButton.backgroundColor = [UIColor clearColor];
    self.settingButton.opaque = NO;
    
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kButtonWidth, 0, kButtonWidth, kButtonWidth)];
    self.cameraButton.backgroundColor = [UIColor clearColor];
    self.cameraButton.opaque = NO;
    
    [self.settingButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.cameraButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.settingButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
    [self.cameraButton setImage:[UIImage imageNamed:@"Record"] forState:UIControlStateNormal];
    
    [self.actionBarView addSubview:self.exploreButton];
//    [self.actionBarView addSubview:self.davaiLogo];
    [self.actionBarView addSubview:self.barTitle];

    [self.actionBarView addSubview:self.settingButton];
    [self.actionBarView addSubview:self.cameraButton];
    [self.view addSubview:self.actionBarView];
}

- (void)setupConstraints
{
    // setup constraints
    
//    [self.davaiLogo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.barTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.exploreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.settingButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cameraButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.actionBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    NSDictionary *viewsDictionary = @{@"actionBarView":self.actionBarView,
//                                      @"davaiLogo":self.davaiLogo,
                                      @"barTitle":self.barTitle,
                                      @"exploreButton":self.exploreButton,
                                      @"settingButton":self.settingButton,
                                      @"cameraButton":self.cameraButton};
    
//    [self.davaiLogo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[davaiLogo(==40)]"
//                                                                           options:0
//                                                                           metrics:nil
//                                                                             views:viewsDictionary]];
//    [self.davaiLogo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[davaiLogo(==40)]"
//                                                                           options:0
//                                                                           metrics:nil
//                                                                             views:viewsDictionary]];
    
    [self.exploreButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[exploreButton(==50)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    [self.exploreButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[exploreButton(==50)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];

    [self.barTitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[barTitle(==160)]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    [self.barTitle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[barTitle(==40)]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    
    [self.settingButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[settingButton(==25)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    [self.settingButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[settingButton(==25)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    [self.cameraButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cameraButton(==25)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
    [self.cameraButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cameraButton(==25)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
    
    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[actionBarView(==50)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    
    
    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[exploreButton]-10-[barTitle]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];
    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[settingButton]-15-[cameraButton]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDictionary]];

//    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[exploreButton]-(-5)-|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];

    
    [self.actionBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.exploreButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:0
                                                                      toItem:self.actionBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:5.0]];
    
    [self.actionBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.barTitle
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:0
                                                                      toItem:self.actionBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
    
    
    
    [self.actionBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.settingButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:0
                                                                      toItem:self.actionBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
    
    [self.actionBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:0
                                                                      toItem:self.actionBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
    
    
//    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[settingButton]-10-|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
//    [self.actionBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[cameraButton]-10-|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[actionBarView]|"
                                                                      options:NSLayoutFormatAlignAllTop
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (void)linkButtons
{
    [self.exploreButton addTarget:self action:@selector(exploreButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton addTarget:self action:@selector(settingButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(cameraButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
}


//- (void)setupUserProfile:(NSMutableDictionary *)userProfile
//{
//    self.userProfile = userProfile;
//    self.profileViewController.userProfile = userProfile;
//}


#pragma mark - Button Methods

- (void)exploreButtonTapped
{
//    NSLog(@"exploreButtonTapped");
}
- (void)settingButtonTapped
{
//    NSLog(@"settingButtonTapped");
}
- (void)cameraButtonTapped
{
//    NSLog(@"cameraButtonTapped");
}


#pragma mark -


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
