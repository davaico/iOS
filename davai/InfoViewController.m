//
//  InfoViewController.m
//  infobar
//
//  Created by Zhi Li on 2014-09-16.
//  Copyright (c) 2014 Zhi Li. All rights reserved.
//

#import "InfoViewController.h"

int kVideoProgressIconHeight = 80;

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the colors for the views
    
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:45.0f/255.0f blue:45.0f/255.0f alpha:0.5f];
    self.view.opaque = NO;
    
    self.infoBarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.infoBarView.opaque = NO;
    
    self.videoProgressImage.userInteractionEnabled = YES;
    [self updateLowerIcon];
    
//    self.avatar.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//    self.avatar.opaque = NO;

    self.commentTable.backgroundColor = [UIColor clearColor];
    self.commentTable.opaque = NO;

    self.commentTable.alwaysBounceVertical = NO;
    self.commentTable.separatorColor = [UIColor clearColor];

//    NSString *imageFileName = @"icon.png";
//    self.avatar.image = [UIImage imageNamed: imageFileName];
//    self.commentData = [[NSMutableArray alloc] init];

    self.videoProgressImage.backgroundColor = [UIColor clearColor];
    self.videoProgressImage.opaque = NO;
    [self.view bringSubviewToFront:self.infoBarView];
    
    self.commentInput.delegate = self;
    self.commentInput.layer.cornerRadius = 8.0f;
    self.commentInput.layer.masksToBounds = YES;
    self.commentInput.layer.borderColor = [[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]CGColor];
    self.commentInput.layer.borderWidth = 1.0f;
    
    self.commentInputClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentInputClearButton setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
    [self.commentInputClearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    self.commentInput.rightView = self.commentInputClearButton;
    self.commentInput.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.commentInputClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.commentInputClearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);

    
    self.doneButton.enabled = NO;
;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
//    [self.view addGestureRecognizer:tap];
//    [self.view bringSubviewToFront:self.videoProgressImage];
    
}

- (void)updateLowerIcon
{
    if (self.liked)
        self.lowerImage = [UIImage imageNamed:@"Liked Lower Circle with +"];
    else
        self.lowerImage = [UIImage imageNamed:@"Lower Circle with +"];
}

- (void)clearText:(id)sender
{
    if (sender == self.commentInputClearButton)
        self.commentInput.text = @"";
}


//- (void)updateAvatar
//{
//    self.avatar.image = [UIImage imageNamed:[self.userProfile objectForKey:@"avatar"]];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Video Progress method


- (void)updateVideoProgressWitePercent:(CGFloat) percent
{
    self.videoProgressImage.image = [self getVideoProgressImageAtPercent:percent];
}


- (UIImage*)getVideoProgressImageAtPercent:(CGFloat) percent
{
    if (percent < 0.0)
        percent = 0.0;
    
    if (percent > 1.0)
        percent = 1.0;
    
    UIImage *countDown = [UIImage imageNamed:@"Countdown Circle"];
    
    CGSize size = countDown.size;
    
    CGPoint circleCenter = CGPointMake(size.width / 2, size.height / 2);
    CGFloat circleRadius = size.width / 2;
    
    UIGraphicsBeginImageContext(size);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:circleCenter
                    radius:circleRadius
                startAngle:M_PI * -0.5
                  endAngle:-0.5 * M_PI + M_PI * 2.0 * percent
                 clockwise:YES];
    [path addLineToPoint:circleCenter];
    [path closePath];
    UIImage *maskImage = [self maskImage:countDown toPath:path];
    
    return [self mergeImageTopImage:maskImage bottomImage:self.lowerImage];
}
- (UIImage *)maskImage:(UIImage *)Image toPath:(UIBezierPath *)path {
    
    UIGraphicsBeginImageContextWithOptions(Image.size, NO, 0);
    [path addClip];
    [Image drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskedImage;
}


- (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)size
{
    
    UIGraphicsBeginImageContext(size);
    
    [[UIColor clearColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    
    CGFloat originX = (size.width - image.size.width)/2.0f;
    CGFloat originY = (size.height - image.size.height)/2.0f;
    CGRect rect = CGRectMake(originX, originY, image.size.width, image.size.height);
    [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *resizedImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


- (UIImage*)mergeImageTopImage:(UIImage*)topImage bottomImage:(UIImage*)bottomImage
{
    CGFloat imageHeight = self.videoProgressImage.frame.size.height;
    CGSize newSize = CGSizeMake(imageHeight, imageHeight);
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Table methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int selectedRow = (int)indexPath.row;
//    NSLog(@"touch on row %d", selectedRow);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [self.commentData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CommentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set the color for this cell
    
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // Set the data for this cell
    
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
//    NSString *string = [NSString stringWithFormat:@"%@ %@", [[self.commentData objectAtIndex:indexPath.row] objectAtIndex:0], [[self.commentData objectAtIndex:indexPath.row] objectAtIndex:1]];
//    cell.textLabel.text = string;
    
    Comment *comment = [self.commentData objectAtIndex:indexPath.row];
    NSString *username = comment.username;
    NSString *commentText = comment.text;
//    NSString *username = @"";
//    NSString *commentText = @"";

    NSDictionary *usernameAttribute = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"ProximaNova-Bold" size:18] forKey:NSFontAttributeName];
    NSDictionary *commentAttribute = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"ProximaNovaA-Regular" size:14] forKey:NSFontAttributeName];
                                      
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:username attributes:usernameAttribute]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@" " attributes:commentAttribute]];
    [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:commentText attributes:commentAttribute]];
    
    cell.textLabel.attributedText = attributedString;
    
    // set the accessory view
    cell.accessoryType =  UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Textfield methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.commentInput.text = @"";
    self.doneButton.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.doneButton.enabled = NO;
    self.commentInput.text = @"Type here to add a comment ...";
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (![self.commentInput.text isEqualToString:@""])
        [self.delegate addComment:self.commentInput.text];
    [self.commentInput resignFirstResponder];
    return NO;
}

- (IBAction)addComment:(id)sender
{
    [self textFieldShouldReturn:self.commentInput];
}

-(void)dismissKeyboard {
    [self.commentInput resignFirstResponder];
}

@end
