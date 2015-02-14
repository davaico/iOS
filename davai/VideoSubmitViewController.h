//
//  VideoSubmitViewController.h
//  davai
//
//  Created by Zhi Li on 2014-10-14.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ActionBarViewControllerCollection.h"
#import "NoNetworkErrorViewController.h"
#import "NetworkController.h"

@protocol VideoSubmitViewControllerDelegate <NSObject>

@required

- (void)cancel;
- (void)saveWithInfo:(NSDictionary*)userInfo;

@end


@interface VideoSubmitViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UISlider *locationAccuracySlider;
@property (nonatomic, weak) IBOutlet UITextField *captionTextField;
@property (nonatomic, weak) IBOutlet UITextField *locationTextField;
@property (nonatomic, strong) UIButton *captionClearButton;
@property (nonatomic, strong) UIButton *locationClearButton;

@property (nonatomic, strong) NSArray *accuracies;


@property (nonatomic, weak) id<VideoSubmitViewControllerDelegate> delegate;

@end
