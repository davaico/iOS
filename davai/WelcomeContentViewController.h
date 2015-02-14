//
//  WelcomeContentViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-17.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeContentViewController : UIViewController


@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, strong) NSString *imageFile;
@property (nonatomic, strong) IBOutlet UIImageView *pageImageView;


@end
