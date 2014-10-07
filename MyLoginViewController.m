//
//  MyLoginViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/6/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "MyLoginViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MyLoginViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation MyLoginViewController

@synthesize fieldsBackground;

- (void)viewDidLayoutSubviews {
    // Set frame for elements
    /*
    [self.logInView.dismissButton setFrame:CGRectMake(10, 10, 87.5, 45.5)];
    [self.logInView.logo setFrame:CGRectMake(66.5, 70, 187, 58.5)];
    [self.logInView.facebookButton setFrame:CGRectMake(35, 287, 120, 40)];
    [self.logInView.twitterButton setFrame:CGRectMake(35+130, 287, 120, 40)];
    [self.logInView.signUpButton setFrame:CGRectMake(35, 385, 250, 40)];
    [self.fieldsBackground setFrame:CGRectMake(80, 145, 160, 160)];
     */
    [self.logInView.logo setFrame:CGRectMake(self.view.frame.size.width/2-60, 55, 120, 120)];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)handleTapGesture:(UIGestureRecognizer*)recognizer {
    NSURL *url = [NSURL URLWithString:@"http://kickoffsb.com/terms.html"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnCampusIcon.png"]]];
    
    self.logInView.dismissButton.enabled = FALSE;
    self.logInView.dismissButton.hidden = TRUE;
    self.logInView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.logInView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.logInView.usernameField.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0];
    self.logInView.usernameField.textColor = [UIColor blackColor];
    self.logInView.passwordField.textColor = [UIColor blackColor];
    [self.logInView.passwordField setReturnKeyType:UIReturnKeyGo];
    [self.logInView.usernameField setReturnKeyType:UIReturnKeyGo];

    UILabel *termsAndCondition = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 30.0, self.logInView.frame.size.width-100.0, 13.0)];
    termsAndCondition.textAlignment = NSTextAlignmentRight;

//    UILabel *termsAndCondition = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.logInView.signUpButton.frame.origin.y + self.logInView.signUpButton.frame.size.height + 20.0, self.logInView.frame.size.width, 30.0f)];
    termsAndCondition.text = @"Terms & Conditions";
    termsAndCondition.font = [UIFont fontWithName:@"Arial" size:11.0];
    termsAndCondition.textColor = [UIColor grayColor];
    termsAndCondition.backgroundColor = [UIColor clearColor];
    [termsAndCondition setHidden:NO];
    termsAndCondition.numberOfLines = 1;
    [self.logInView addSubview:termsAndCondition];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [termsAndCondition setUserInteractionEnabled:YES];
    [termsAndCondition addGestureRecognizer:tapGesture];

    /*
    // Add login field background
    //fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    //[self.logInView insertSubview:fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];

    
    // Set buttons appearance
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"exit_down.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    // Add login field background
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.logInView insertSubview:fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
