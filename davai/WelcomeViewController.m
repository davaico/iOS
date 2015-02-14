//
//  WelcomeViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-14.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.pageImages = @[@"icon.png", @"icon.png", @"icon.png", @"icon.png", @""];
//    self.view.backgroundColor = [UIColor colorWithRed:25/255.0 green:171.0/255.0 blue:111.0/255.0 alpha:1.0];
    
    self.pageImages = @[@"Welcome Message.png", @"Instructions Screen.png", @"Instructions Screen 2.png", @""];
    // Create page view controller
    self.welcomePageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
    self.welcomePageViewController.dataSource = self;
    
    WelcomeContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.welcomePageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.welcomePageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.welcomePageViewController];
    [self.view addSubview:self.welcomePageViewController.view];
    [self.welcomePageViewController didMoveToParentViewController:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)viewed
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"viewed"];
}

- (void)setViewed:(BOOL)viewed
{
    [[NSUserDefaults standardUserDefaults] setBool:viewed forKey:@"viewed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound))
        return nil;
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound)
        return nil;
    
    index++;
    if (index == [self.pageImages count]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (WelcomeContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count]))
        return nil;
    
    // Create a new view controller and pass suitable data.
    WelcomeContentViewController *welcomeContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeContentViewController"];
    welcomeContentViewController.imageFile = self.pageImages[index];
    welcomeContentViewController.pageIndex = index;
    
    return welcomeContentViewController;
}

@end
