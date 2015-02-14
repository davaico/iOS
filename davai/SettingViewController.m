//
//  SettingViewController.m
//  davai
//
//  Created by Zhi Li on 2014-10-13.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:11.0/255.0 green:78.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.barTitle.text = @"Settings";
//    NSString *version = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *version = [NSString stringWithFormat:@"v%@", @"0.9"];

    self.versionLabel.text = version;
    [self.view bringSubviewToFront:self.actionBarView];
    self.scrollView.frame = self.view.frame;
    self.buttonView.layer.cornerRadius = 8.0f;
    self.buttonView.layer.masksToBounds = YES;
    self.logoutButton.layer.cornerRadius = 8.0f;
    self.logoutButton.layer.masksToBounds = YES;

    
    
    // make the credit label
    NSString *shash = @"Shashwat Pandey";
    NSString *zhi = @"Zhi Li";
    NSString *matthew = @"Matthew Pereira";
    
    NSURL *shashURL = [NSURL URLWithString: @"https://ca.linkedin.com/pub/shashwat-pandey/65/79/8a6"];
    NSURL *matthewURL = [NSURL URLWithString: @"http://matthewpereira.com/"];
    
    UIFont *defaultFont = [UIFont fontWithName:@"ProximaNovaA-Regular" size:12];
    UIFont *boldFont = [UIFont fontWithName:@"ProximaNova-Bold" size:12];
    NSDictionary *defaultFontAttribute = @{ NSFontAttributeName:defaultFont };
    NSDictionary *boldFontAttribute = @{ NSFontAttributeName:boldFont };
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"Development by " attributes:defaultFontAttribute]];

    NSDictionary *shashAttribute = @{ NSFontAttributeName:boldFont,
                                      NSLinkAttributeName:shashURL};
    NSDictionary *matthewAttribute = @{ NSFontAttributeName:boldFont,
                                      NSLinkAttributeName:matthewURL};
    
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:shash attributes:shashAttribute]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@" and " attributes:defaultFontAttribute]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:zhi attributes:boldFontAttribute]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\nUI by " attributes:defaultFontAttribute]];

    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:matthew attributes:matthewAttribute]];
    [attributedString addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
                              range:NSMakeRange(0, [attributedString length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];

    self.creditTextView.attributedText = attributedString;
    self.creditTextView.linkTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                                NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle] };
    [self.creditTextView setEditable:NO];
    [self.creditTextView setSelectable:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)exploreButtonTapped
{
    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.exploreViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}
- (void)settingButtonTapped
{

}

- (void)cameraButtonTapped
{

    ActionBarViewControllerCollection *actionBarViewControllerCollection = [ActionBarViewControllerCollection sharedCollection];
    ActionViewController *actionViewController = actionBarViewControllerCollection.cameraViewController;
    [self.delegate transitFromActionViewController:self toActionViewController:actionViewController animated:YES];
}



#pragma mark - Button methods
- (IBAction)termsOfUseButtonTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.davai.co/legal/TermsofUse.pdf"]];
}

- (IBAction)privacyPolicyButtonTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.davai.co/legal/PrivacyPolicy.pdf"]];
}

- (IBAction)reportProblemButtonTapped:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        UserProfile *profile = [UserProfile sharedProfile];
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Report a problem"];
        [controller setMessageBody:[NSString stringWithFormat:@"Username: %@", profile.user.username] isHTML:NO];
        [controller setToRecipients:@[@"hey@davai.co"]];
        [self presentViewController:controller animated:YES completion:nil];
    } else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/davaico"]];
}

- (IBAction)contactUsButtonTapped:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        UserProfile *profile = [UserProfile sharedProfile];
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
//        [controller setSubject:@""];
        [controller setMessageBody:[NSString stringWithFormat:@"Username: %@", profile.user.username] isHTML:NO];
        [controller setToRecipients:@[@"hey@davai.co"]];
        [self presentViewController:controller animated:YES completion:nil];
    } else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/davaico"]];
}

- (IBAction)logoutButtonTapped:(id)sender
{
    [(id<SettingViewControllerDelegate>)self.delegate logout];
}


#pragma mark - Mail delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        ;
//        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
