//
//  SignInViewController.m
//  davai
//
//  Created by Zhi Li on 2014-11-12.
//  Copyright (c) 2014 davai. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.goButton.layer.cornerRadius=8.0f;
    self.goButton.layer.masksToBounds=YES;

    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.usernameTextField.layer.cornerRadius = 8.0f;
    self.usernameTextField.layer.masksToBounds = YES;
    self.usernameTextField.layer.borderColor = [[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]CGColor];
    self.usernameTextField.layer.borderWidth = 1.0f;
    
    self.passwordTextField.layer.cornerRadius = 8.0f;
    self.passwordTextField.layer.masksToBounds = YES;
    self.passwordTextField.layer.borderColor = [[UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]CGColor];
    self.passwordTextField.layer.borderWidth = 1.0f;
    
    self.usernameClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.usernameClearButton setImage:[UIImage imageNamed:@"Delete Button"] forState:UIControlStateNormal];
    [self.usernameClearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    self.usernameTextField.rightView = self.usernameClearButton;
    self.usernameTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.usernameClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.usernameClearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);

    self.passwordClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.passwordClearButton setImage:[UIImage imageNamed:@"Delete Button"] forState:UIControlStateNormal];
    [self.passwordClearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    self.passwordTextField.rightView = self.passwordClearButton;
    self.passwordTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.passwordClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordClearButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
}

- (void)clearText:(id)sender
{
    if (sender == self.usernameClearButton)
        self.usernameTextField.text = @"";
    if (sender == self.passwordClearButton)
        self.passwordTextField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonTapped:(id)sender
{
    self.userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.usernameTextField.text, @"username",
                                                                self.passwordTextField.text, @"password",
                                                                nil];
    [self.delegate signIn];
}


- (IBAction)muteButtonTapped:(id)sender {
//    NSLog(@"signin view mute button");
    [self.delegate toggleMute];
}


#pragma mark - Textfield methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        textField.secureTextEntry = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.usernameTextField &&
        [textField.text isEqualToString:@""]) {
        textField.text = @"Username";
    }
    if (textField == self.passwordTextField &&
        [textField.text isEqualToString:@""]) {
        textField.text = @"Password";
        textField.secureTextEntry = NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];
    return NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
