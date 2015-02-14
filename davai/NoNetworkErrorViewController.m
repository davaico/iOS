//
//  NoNetworkErrorViewController.m
//  davai
//
//  Created by Zhi Li on 2014-11-26.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import "NoNetworkErrorViewController.h"

@interface NoNetworkErrorViewController ()

@end

@implementation NoNetworkErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor colorWithRed:98.0f/255.0f green:167.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    gesture.minimumPressDuration = 0.0f;
    gesture.numberOfTapsRequired = 0;
    [self.view addGestureRecognizer:gesture];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
