//
//  VideoSubmitViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-14.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "VideoSubmitViewController.h"
//#import "VideoReviewViewController.m"

@interface VideoSubmitViewController ()

@end

@implementation VideoSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
    self.view.opaque = NO;
    
    
    UIImage *minImage = [[UIImage imageNamed:@"Location Line Light.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"Location Line Light.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
    
    //resize the thumb image
    UIImage * thumbImage = [UIImage imageNamed:@"Location Slider"];
    CGSize scaleSize = CGSizeMake(27, 27);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [thumbImage drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.locationAccuracySlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [self.locationAccuracySlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.locationAccuracySlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.locationAccuracySlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    self.accuracies = @[@"City", @"Neighbourhood", @"Intersection"];
    self.delegate = (id<VideoSubmitViewControllerDelegate>)[[ActionBarViewControllerCollection sharedCollection] cameraViewController];
    self.captionTextField.delegate = self;
    self.captionTextField.layer.cornerRadius = 8.0f;
    self.captionTextField.layer.masksToBounds = YES;
    self.captionTextField.layer.borderColor = [[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]CGColor];
    self.captionTextField.layer.borderWidth = 1.0f;

    self.locationTextField.delegate = self;
    self.locationTextField.layer.cornerRadius = 8.0f;
    self.locationTextField.layer.masksToBounds = YES;
    self.locationTextField.layer.borderColor = [[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]CGColor];
    self.locationTextField.layer.borderWidth = 1.0f;

    
    self.captionClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captionClearButton setImage:[UIImage imageNamed:@"Delete Button"] forState:UIControlStateNormal];
    [self.captionClearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    self.captionTextField.rightView = self.captionClearButton;
    self.captionTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.captionClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.captionClearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);

    self.locationClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.locationClearButton setImage:[UIImage imageNamed:@"Delete Button"] forState:UIControlStateNormal];
    [self.locationClearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    self.locationTextField.rightView = self.locationClearButton;
    self.locationTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.locationClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.locationClearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);

    
    self.cancelButton.layer.cornerRadius = 8.0f;
    self.cancelButton.layer.masksToBounds = YES;
    self.postButton.layer.cornerRadius = 8.0f;
    self.postButton.layer.masksToBounds = YES;
    
//    [self.postButton setEnabled:NO];

}
- (void)clearText:(id)sender
{
    if (sender == self.self.captionClearButton)
        self.captionTextField.text = @"";
    else if (sender == self.self.locationClearButton)
        self.locationTextField.text = @"";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(id)sender
{
    NSUInteger index = (NSUInteger)(self.locationAccuracySlider.value + 0.5);
    [self.locationAccuracySlider setValue:index animated:NO];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate cancel];
}

- (IBAction)post:(id)sender
{
    NetworkController *networkController = [NetworkController sharedController];
    if (![networkController hasConnectivity]) {
        NoNetworkErrorViewController *noNetworkErrorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoNetworkErrorViewController"];
        [self presentViewController:noNetworkErrorViewController animated:YES completion:nil];
        return;
    }

    
    if ([self.captionTextField.text isEqualToString:@""] ||
        [self.locationTextField.text isEqualToString:@""]) {
        
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:6];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.view center].x - 20.0f, [self.view center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.view center].x + 20.0f, [self.view center].y)]];
        [[self.view layer] addAnimation:animation forKey:@"position"];
    }
    else {
        NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
        [info setValue:self.captionTextField.text forKey:@"caption"];
        [info setValue:self.locationTextField.text forKey:@"location"];
        //    [self dismissViewControllerAnimated:NO completion:^{
        //        [self.delegate saveWithInfo:info];
        //    }];
        [self.delegate saveWithInfo:info];
        
    }

    
}

#pragma mark - Textfield methods
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return NO;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{

}

@end
