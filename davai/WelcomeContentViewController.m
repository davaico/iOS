//
//  WelcomeContentViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-17.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "WelcomeContentViewController.h"

@interface WelcomeContentViewController ()

@end

@implementation WelcomeContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.pageImageView.backgroundColor = [UIColor colorWithRed:25/255.0 green:171.0/255.0 blue:111.0/255.0 alpha:1.0];
    if (![self.imageFile isEqualToString:@""])
        self.pageImageView.image = [UIImage imageNamed:self.imageFile];
    self.pageImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
