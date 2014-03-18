//
//  MySignUpViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/6/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "MySignUpViewController.h"

@interface MySignUpViewController ()

@end

@implementation MySignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [self.signUpView.logo setFrame:CGRectMake(80, 50, 160, 160)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OnCampusIcon.png"]]];
    self.signUpView.dismissButton.enabled = TRUE;
    self.signUpView.dismissButton.hidden = FALSE;
    self.signUpView.usernameField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpView.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpView.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.signUpView.additionalField.enabled = FALSE;
    self.signUpView.usernameField.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0];
    self.signUpView.passwordField.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0];
    self.signUpView.emailField.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0];
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
