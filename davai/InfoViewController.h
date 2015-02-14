//
//  InfoViewController.h
//  infobar
//
//  Created by Zhi Li on 2014-09-16.
//  Copyright (c) 2014 Zhi Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "Comment.h"

@protocol InfoViewControllerDelegate <NSObject>

@required

- (void)addComment:(NSString*)comment;

@end


@interface InfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *infoBarView;
@property (nonatomic, weak) IBOutlet UITextField *commentInput;
@property (nonatomic, strong) UIButton *commentInputClearButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

//@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UIImageView *videoProgressImage;
//@property (weak, nonatomic) IBOutlet UITextView *videoDescription;
@property (nonatomic, weak) IBOutlet UILabel *videoCaptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *videoLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *videoInfoLabel;

@property (nonatomic, weak) IBOutlet UITableView *commentTable;
@property (nonatomic, weak) IBOutlet UIView *commentBarView;
@property (nonatomic, strong) NSMutableArray *commentData;

@property (nonatomic, strong) id<InfoViewControllerDelegate>delegate;

@property (nonatomic) BOOL liked;
@property (nonatomic, strong) UIImage *lowerImage;

- (void)updateLowerIcon;

- (void)updateVideoProgressWitePercent:(CGFloat) percent;

- (IBAction)addComment:(id)sender;

//- (void)updateAvatar;

@end
