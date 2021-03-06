//
//  ViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/5/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "MyLoginViewController.h"
#import "MySignUpViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"Logged in...");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    userProfileData = [ProfileData sharedInstance];
    [userProfileData setUserName:[user objectForKey:@"username"]];
    PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
    [query whereKey:@"username" equalTo:[userProfileData getUserName]];
    PFObject *object = [query getFirstObject];
    [userProfileData setOwnObject:object];
    
    PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
    PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
    NSArray *friendList1 = [friendQuery1 findObjects];
    NSArray *friendList2 = [friendQuery2 findObjects];
    
    NSMutableArray *tempFriendsConfirmed = [[NSMutableArray alloc] init];

    for (int j = 0; j < [friendList1 count]; j++) {
        NSNumber *isFriend = [[friendList1 objectAtIndex:j] objectForKey:@"confirmed"];
        BOOL isFriendBool = [isFriend boolValue];
        if (isFriendBool)
            [tempFriendsConfirmed addObject:[[friendList1 objectAtIndex:j] objectForKey:@"inviter"]];
    }
    for (int k = 0; k < [friendList2 count]; k++) {
        NSNumber *isFriend = [[friendList2 objectAtIndex:k] objectForKey:@"confirmed"];
        BOOL isFriendBool = [isFriend boolValue];
        if (isFriendBool)
            [tempFriendsConfirmed addObject:[[friendList2 objectAtIndex:k] objectForKey:@"invitee"]];
    }
    NSMutableArray *tempFriendsConfirmed2 = [[NSMutableArray alloc] init];

    for (int j = 0; j < [tempFriendsConfirmed count]; j++) {
        if ([tempFriendsConfirmed2 containsObject:[tempFriendsConfirmed objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                }
            } else {
                [tempObject delete];
            }
        } else {
            [tempFriendsConfirmed2 addObject:[tempFriendsConfirmed objectAtIndex:j]];
        }
    }

    /*
    PFQuery *fquery1 = [PFQuery queryWithClassName:@"Profile"];
    [fquery1 whereKey:@"username" containedIn:tempFriendsConfirmed2];
    [fquery1 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    NSArray *myFriends = [fquery1 findObjects];
    */
    [userProfileData setFriendList:(NSArray *)tempFriendsConfirmed2];
    


}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    PFObject *userProfile = [PFObject objectWithClassName:@"Profile"];
    [userProfile setObject:user.username forKey:@"username"];
    [userProfile setObject:user.email forKey:@"emailAddress"];
    [userProfile setObject:@"" forKey:@"affiliation"];
    [userProfile setObject:@"" forKey:@"year"];
    [userProfile setObject:[NSNumber numberWithBool:FALSE] forKey:@"ndgrad"];
    [userProfile setObject:[NSNumber numberWithBool:FALSE] forKey:@"ndstudent"];
    [userProfile save];
    userProfileData = [ProfileData sharedInstance];
    [userProfileData setUserName:user.username];

    [self dismissViewControllerAnimated:YES completion:nil];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void)buttonPressed:(id)sender
{
    UIButton *clicked = (UIButton *) sender;
    
    if (clicked.tag == 0) { // My Friends
        [self performSegueWithIdentifier: @"FriendsSegue" sender: self];
    } else if (clicked.tag == 1) { // Messages
        [self performSegueWithIdentifier: @"MessagesSegue" sender: self];
    } else if (clicked.tag == 2) { // Photos
        [self performSegueWithIdentifier: @"PicturesSegue" sender: self];
    } else if (clicked.tag == 3) { // My Schedule
        [self performSegueWithIdentifier: @"ScheduleSegue" sender: self];
    } else if (clicked.tag == 4) { // On Campus Events
        [self performSegueWithIdentifier: @"OnCampusSegue" sender: self];
    } else if (clicked.tag == 5) { // Off Campus Events
        [self performSegueWithIdentifier: @"OffCampusSegue" sender: self];
    } else if (clicked.tag == 6) { // Dining, etc.
        [self performSegueWithIdentifier: @"DiningSegue" sender: self];
    } else if (clicked.tag == 7) { // Parking Options
        [self performSegueWithIdentifier: @"ParkingSegue" sender: self];
    } else if (clicked.tag == 8) { // Map View
        [self performSegueWithIdentifier: @"MapSegue" sender: self];
    }
}

- (void)addLabels
{
    //gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 130)];
//    gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, 300, 30)];
    gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 300, 30)];
    gameLabel.textAlignment = NSTextAlignmentCenter;
    gameLabel.backgroundColor = [UIColor clearColor];
    gameLabel.textColor = [UIColor whiteColor];
    gameLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    gameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:26.0];
    gameLabel.numberOfLines = 3;
    gameLabel.text = @"";

    countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 40)];
    countDownLabel.textAlignment = NSTextAlignmentCenter;
    countDownLabel.backgroundColor = [UIColor clearColor];
    //countDownLabel.textColor = [UIColor whiteColor];
    countDownLabel.textColor = [UIColor colorWithRed:222.0f/255.0f green:182.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
    countDownLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
    countDownLabel.text = @"";
    
    [self.view addSubview:gameLabel];
    [self.view addSubview:countDownLabel];
}

- (void)addButtons
{
    /*
#define BTN_X 20
#define BTN_Y 185
#define BTN_X_DIFF 105
#define BTN_Y_DIFF 105
#define BTN_SIZE 70
#define LABEL_DISTANCE_Y -5
#define LABEL_Y 12
     */

/* OLD LOCATIONS:
#define BTN_X 20
#define BTN_Y 205
#define BTN_X_DIFF 105
#define BTN_Y_DIFF 90
#define BTN_SIZE 70
#define LABEL_DISTANCE_Y - 10
#define LABEL_Y 12
*/

    
#define BTN_X 20
#define BTN_Y 230
#define BTN_X_DIFF 105
#define BTN_Y_DIFF 120
#define BTN_SIZE 70
#define LABEL_DISTANCE_Y - 0
#define LABEL_Y 12


#define FONT_SIZE 12.0
#define FONT "ArialRoundedMTBold"
    
    int y_offset;
    int y_dist;
    if ((int)[[UIScreen mainScreen] bounds].size.height == 568) {
        // This is iPhone 5 screen
        y_offset = 25;
        y_dist = 10;
    } else {
        // This is iPhone 4/4s screen
        y_offset = 0;
        y_dist = 0;
    }

    UIButton *friendsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendsBtn.frame = CGRectMake(BTN_X, BTN_Y + y_offset, BTN_SIZE, BTN_SIZE);
    UIImage *friendsImage = [UIImage imageNamed:@"FriendsIcon.png"];
    [friendsBtn setBackgroundImage:friendsImage forState:UIControlStateNormal];
    [friendsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    friendsBtn.tag = 0;
    UILabel *friendsLabel = [[UILabel alloc] init];
    friendsLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y, BTN_SIZE*2, LABEL_Y);
    friendsLabel.textAlignment = NSTextAlignmentCenter;
    friendsLabel.textColor = [UIColor whiteColor];
    friendsLabel.backgroundColor = [UIColor clearColor];
    friendsLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    friendsLabel.text = @"Friends";

    UIButton *messagesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    messagesBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+y_offset, BTN_SIZE, BTN_SIZE);
    UIImage *messagesImage = [UIImage imageNamed:@"MessagesIcon.png"];
    [messagesBtn setBackgroundImage:messagesImage forState:UIControlStateNormal];
    [messagesBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    messagesBtn.tag = 1;
    UILabel *messagesLabel = [[UILabel alloc] init];
    messagesLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y, BTN_SIZE*2, LABEL_Y);
    messagesLabel.textAlignment = NSTextAlignmentCenter;
    messagesLabel.textColor = [UIColor whiteColor];
    messagesLabel.backgroundColor = [UIColor clearColor];
    messagesLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    messagesLabel.text = @"Group Chat";
    
    UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+y_offset, BTN_SIZE, BTN_SIZE);
    UIImage *pictureImage = [UIImage imageNamed:@"PictureIcon.png"];
    [pictureBtn setBackgroundImage:pictureImage forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    pictureBtn.tag = 2;
    UILabel *pictureLabel = [[UILabel alloc] init];
    pictureLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y, BTN_SIZE*2, LABEL_Y);
    pictureLabel.textAlignment = NSTextAlignmentCenter;
    pictureLabel.textColor = [UIColor whiteColor];
    pictureLabel.backgroundColor = [UIColor clearColor];
    pictureLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    pictureLabel.text = @"Photos";
    
    /*
    UIButton *scheduleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scheduleBtn.frame = CGRectMake(BTN_X, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *scheduleImage = [UIImage imageNamed:@"ScheduleIcon.png"];
    [scheduleBtn setBackgroundImage:scheduleImage forState:UIControlStateNormal];
    [scheduleBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    scheduleBtn.tag = 3;
    UILabel *scheduleLabel = [[UILabel alloc] init];
    scheduleLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist, BTN_SIZE*2, LABEL_Y);
    scheduleLabel.textAlignment = NSTextAlignmentCenter;
    scheduleLabel.textColor = [UIColor whiteColor];
    scheduleLabel.backgroundColor = [UIColor clearColor];
    scheduleLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    scheduleLabel.text = @"Schedule";
    */
    
    /*
    UIButton *onCampusEventsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    onCampusEventsBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *onCampusEventsImage = [UIImage imageNamed:@"OnCampusIcon.png"];
    [onCampusEventsBtn setBackgroundImage:onCampusEventsImage forState:UIControlStateNormal];
    [onCampusEventsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    onCampusEventsBtn.tag = 4;
    UILabel *events1Label = [[UILabel alloc] init];
    events1Label.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist-LABEL_Y, BTN_SIZE*2, LABEL_Y*3);
    events1Label.textAlignment = NSTextAlignmentCenter;
    events1Label.textColor = [UIColor whiteColor];
    events1Label.backgroundColor = [UIColor clearColor];
    events1Label.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    events1Label.numberOfLines = 2;
    events1Label.text = @"Sports News";
    */
    
    UIButton *offCampusEventsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    offCampusEventsBtn.frame = CGRectMake(BTN_X, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *offCampusEventsImage = [UIImage imageNamed:@"OffCampusIcon.png"];
    [offCampusEventsBtn setBackgroundImage:offCampusEventsImage forState:UIControlStateNormal];
    [offCampusEventsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    offCampusEventsBtn.tag = 5;
    UILabel *events2Label = [[UILabel alloc] init];
    events2Label.frame = CGRectMake(BTN_X-BTN_SIZE/2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist, BTN_SIZE*2, LABEL_Y);
    events2Label.textAlignment = NSTextAlignmentCenter;
    events2Label.textColor = [UIColor whiteColor];
    events2Label.backgroundColor = [UIColor clearColor];
    events2Label.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    events2Label.numberOfLines = 2;
    events2Label.text = @"Events";

    /* OLD LOCATION:
    UIButton *offCampusEventsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    offCampusEventsBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *offCampusEventsImage = [UIImage imageNamed:@"OffCampusIcon.png"];
    [offCampusEventsBtn setBackgroundImage:offCampusEventsImage forState:UIControlStateNormal];
    [offCampusEventsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    offCampusEventsBtn.tag = 5;
    UILabel *events2Label = [[UILabel alloc] init];
    events2Label.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist-LABEL_Y, BTN_SIZE*2, LABEL_Y*3);
    events2Label.textAlignment = NSTextAlignmentCenter;
    events2Label.textColor = [UIColor whiteColor];
    events2Label.backgroundColor = [UIColor clearColor];
    events2Label.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    events2Label.numberOfLines = 2;
    events2Label.text = @"Events";
    */
    
    /*
    UIButton *diningBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    diningBtn.frame = CGRectMake(BTN_X, BTN_Y+y_offset+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE, BTN_SIZE);
    UIImage *diningImage = [UIImage imageNamed:@"DiningIcon.png"];
    [diningBtn setBackgroundImage:diningImage forState:UIControlStateNormal];
    [diningBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    diningBtn.tag = 6;
    UILabel *diningLabel = [[UILabel alloc] init];
    diningLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE*2, LABEL_Y*2);
    diningLabel.textAlignment = NSTextAlignmentCenter;
    diningLabel.textColor = [UIColor whiteColor];
    diningLabel.backgroundColor = [UIColor clearColor];
    diningLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    //diningLabel.text = @"Eat & Shop";
    diningLabel.text = @"Around Town";
    */
    
    UIButton *parkingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    parkingBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *parkingImage = [UIImage imageNamed:@"ParkingIcon.png"];
    [parkingBtn setBackgroundImage:parkingImage forState:UIControlStateNormal];
    [parkingBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    parkingBtn.tag = 7;
    UILabel *parkingLabel = [[UILabel alloc] init];
    parkingLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist-LABEL_Y, BTN_SIZE*2, LABEL_Y*3);
    parkingLabel.textAlignment = NSTextAlignmentCenter;
    parkingLabel.textColor = [UIColor whiteColor];
    parkingLabel.backgroundColor = [UIColor clearColor];
    parkingLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    parkingLabel.numberOfLines = 2;
    //parkingLabel.text = @"Parking & \rTransportation";
    parkingLabel.text = @"Getting Around";

    /* OLD LOCATION:
    UIButton *parkingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    parkingBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+y_offset+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE, BTN_SIZE);
    UIImage *parkingImage = [UIImage imageNamed:@"ParkingIcon.png"];
    [parkingBtn setBackgroundImage:parkingImage forState:UIControlStateNormal];
    [parkingBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    parkingBtn.tag = 7;
    UILabel *parkingLabel = [[UILabel alloc] init];
    parkingLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE*2, LABEL_Y*3);
    parkingLabel.textAlignment = NSTextAlignmentCenter;
    parkingLabel.textColor = [UIColor whiteColor];
    parkingLabel.backgroundColor = [UIColor clearColor];
    parkingLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    parkingLabel.numberOfLines = 2;
    //parkingLabel.text = @"Parking & \rTransportation";
    parkingLabel.text = @"Getting Around";
    */
    
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_Y_DIFF+y_dist-10, BTN_SIZE, BTN_SIZE);
    UIImage *mapImage = [UIImage imageNamed:@"MapIcon.png"];
    [mapBtn setBackgroundImage:mapImage forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    mapBtn.tag = 8;
    UILabel *mapLabel = [[UILabel alloc] init];
    mapLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+BTN_Y_DIFF+y_dist-LABEL_Y, BTN_SIZE*2, LABEL_Y*3);
    mapLabel.textAlignment = NSTextAlignmentCenter;
    mapLabel.textColor = [UIColor whiteColor];
    mapLabel.backgroundColor = [UIColor clearColor];
    mapLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    mapLabel.text = @"Map";
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]];

    /* OLD LOCATION:
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+y_offset+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE, BTN_SIZE);
    UIImage *mapImage = [UIImage imageNamed:@"MapIcon.png"];
    [mapBtn setBackgroundImage:mapImage forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    mapBtn.tag = 8;
    UILabel *mapLabel = [[UILabel alloc] init];
    mapLabel.frame = CGRectMake(BTN_X-BTN_SIZE/2+BTN_X_DIFF*2, BTN_Y+y_offset+BTN_SIZE+LABEL_DISTANCE_Y+(BTN_Y_DIFF+y_dist)*2, BTN_SIZE*2, LABEL_Y*2);
    mapLabel.textAlignment = NSTextAlignmentCenter;
    mapLabel.textColor = [UIColor whiteColor];
    mapLabel.backgroundColor = [UIColor clearColor];
    mapLabel.font = [UIFont fontWithName:@FONT size:FONT_SIZE];
    mapLabel.text = @"Map";
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]];
    */
    
    //[self.view addSubview:onCampusEventsBtn];
    [self.view addSubview:offCampusEventsBtn];
    //[self.view addSubview:scheduleBtn];
    //[self.view addSubview:diningBtn];
    [self.view addSubview:parkingBtn];
    [self.view addSubview:mapBtn];
    [self.view addSubview:friendsBtn];
    [self.view addSubview:messagesBtn];
    [self.view addSubview:pictureBtn];
    
    [self.view addSubview:friendsLabel];
    [self.view addSubview:messagesLabel];
    [self.view addSubview:pictureLabel];
    //[self.view addSubview:scheduleLabel];
    //[self.view addSubview:events1Label];
    [self.view addSubview:events2Label];
    //[self.view addSubview:diningLabel];
    [self.view addSubview:parkingLabel];
    [self.view addSubview:mapLabel];
}

/*
- (void)addButtons
{
#define BTN_X 25
#define BTN_Y 145
#define BTN_X_DIFF 100
#define BTN_Y_DIFF 90
#define BTN_SIZE 70
    
    UIButton *onCampusEventsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    onCampusEventsBtn.frame = CGRectMake(BTN_X, BTN_Y, BTN_SIZE, BTN_SIZE);
    UIImage *onCampusEventsImage = [UIImage imageNamed:@"OnCampusIcon.png"];
    [onCampusEventsBtn setBackgroundImage:onCampusEventsImage forState:UIControlStateNormal];
    [onCampusEventsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    onCampusEventsBtn.tag = 0;

    UIButton *offCampusEventsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    offCampusEventsBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y, BTN_SIZE, BTN_SIZE);
    UIImage *offCampusEventsImage = [UIImage imageNamed:@"OffCampusIcon.png"];
    [offCampusEventsBtn setBackgroundImage:offCampusEventsImage forState:UIControlStateNormal];
    [offCampusEventsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    offCampusEventsBtn.tag = 1;
    
    UIButton *scheduleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scheduleBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y, BTN_SIZE, BTN_SIZE);
    UIImage *scheduleImage = [UIImage imageNamed:@"ScheduleIcon.png"];
    [scheduleBtn setBackgroundImage:scheduleImage forState:UIControlStateNormal];
    [scheduleBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    scheduleBtn.tag = 2;
   
    UIButton *diningBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    diningBtn.frame = CGRectMake(BTN_X, BTN_Y+BTN_Y_DIFF, BTN_SIZE, BTN_SIZE);
    UIImage *diningImage = [UIImage imageNamed:@"DiningIcon.png"];
    [diningBtn setBackgroundImage:diningImage forState:UIControlStateNormal];
    [diningBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    diningBtn.tag = 3;

    UIButton *shoppingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shoppingBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+BTN_Y_DIFF, BTN_SIZE, BTN_SIZE);
    UIImage *shoppingImage = [UIImage imageNamed:@"ShoppingIcon.png"];
    [shoppingBtn setBackgroundImage:shoppingImage forState:UIControlStateNormal];
    [shoppingBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    shoppingBtn.tag = 4;

    UIButton *lodgingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lodgingBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+BTN_Y_DIFF, BTN_SIZE, BTN_SIZE);
    UIImage *lodgingImage = [UIImage imageNamed:@"LodgingIcon.png"];
    [lodgingBtn setBackgroundImage:lodgingImage forState:UIControlStateNormal];
    [lodgingBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    lodgingBtn.tag = 5;

    UIButton *parkingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    parkingBtn.frame = CGRectMake(BTN_X, BTN_Y+BTN_Y_DIFF*2, BTN_SIZE, BTN_SIZE);
    UIImage *parkingImage = [UIImage imageNamed:@"ParkingIcon.png"];
    [parkingBtn setBackgroundImage:parkingImage forState:UIControlStateNormal];
    [parkingBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    parkingBtn.tag = 6;

    UIButton *transportationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    transportationBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+BTN_Y_DIFF*2, BTN_SIZE, BTN_SIZE);
    UIImage *transportationImage = [UIImage imageNamed:@"TransportationIcon.png"];
    [transportationBtn setBackgroundImage:transportationImage forState:UIControlStateNormal];
    [transportationBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    transportationBtn.tag = 7;

    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+BTN_Y_DIFF*2, BTN_SIZE, BTN_SIZE);
    UIImage *mapImage = [UIImage imageNamed:@"MapIcon.png"];
    [mapBtn setBackgroundImage:mapImage forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    mapBtn.tag = 8;

    UIButton *friendsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendsBtn.frame = CGRectMake(BTN_X, BTN_Y+BTN_Y_DIFF*3, BTN_SIZE, BTN_SIZE);
    UIImage *friendsImage = [UIImage imageNamed:@"FriendsIcon.png"];
    [friendsBtn setBackgroundImage:friendsImage forState:UIControlStateNormal];
    [friendsBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    friendsBtn.tag = 9;

    UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF, BTN_Y+BTN_Y_DIFF*3, BTN_SIZE, BTN_SIZE);
    UIImage *pictureImage = [UIImage imageNamed:@"PictureIcon.png"];
    [pictureBtn setBackgroundImage:pictureImage forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    pictureBtn.tag = 10;

    UIButton *messagesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    messagesBtn.frame = CGRectMake(BTN_X+BTN_X_DIFF*2, BTN_Y+BTN_Y_DIFF*3, BTN_SIZE, BTN_SIZE);
    UIImage *messagesImage = [UIImage imageNamed:@"MessagesIcon.png"];
    [messagesBtn setBackgroundImage:messagesImage forState:UIControlStateNormal];
    [messagesBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    messagesBtn.tag = 11;

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]];
    
    [self.view addSubview:onCampusEventsBtn];
    [self.view addSubview:offCampusEventsBtn];
    [self.view addSubview:scheduleBtn];
    [self.view addSubview:diningBtn];
    [self.view addSubview:lodgingBtn];
    [self.view addSubview:shoppingBtn];
    [self.view addSubview:parkingBtn];
    [self.view addSubview:transportationBtn];
    [self.view addSubview:mapBtn];
    [self.view addSubview:friendsBtn];
    [self.view addSubview:messagesBtn];
    [self.view addSubview:pictureBtn];
}
 */


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"View did appear");
    
    // Check if user is logged in
    if (![PFUser currentUser]) {
        // Create the log in view controller
        MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword
         //| PFLogInFieldsFacebook
         | PFLogInFieldsSignUpButton];
    
        // Instantiate our custom sign up view controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault ];
    
        // Link the sign up view controller
        [logInViewController setSignUpController:signUpViewController];
    
        // Present log in view controller
        logInViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Create the log in view controller
    MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController setDelegate:self];
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword
     | PFLogInFieldsFacebook
     | PFLogInFieldsSignUpButton];
    
    // Instantiate our custom sign up view controller
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsDefault ];
    
    // Link the sign up view controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present log in view controller
    logInViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:logInViewController animated:YES completion:NULL];
}
*/

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:18.0];
        titleView.numberOfLines = 2;
        titleView.textAlignment = NSTextAlignmentCenter;
        //titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        //titleView.textColor = [UIColor blackColor];
        titleView.textColor = [UIColor colorWithRed:222.0f/255.0f green:182.0f/255.0f blue:89.0f/255.0f alpha:1.0f];

        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)logOutClicked:(id)sender
{
    NSLog(@"logout clicked");
    [PFUser logOut];
    
    if (![PFUser currentUser]) {
        // Create the log in view controller
        MyLoginViewController *logInViewController = [[MyLoginViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword
         //| PFLogInFieldsFacebook
         | PFLogInFieldsSignUpButton];
        
        // Instantiate our custom sign up view controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault ];
        
        // Link the sign up view controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present log in view controller
        logInViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }

}

- (void)profileClicked:(id)sender
{
    [self performSegueWithIdentifier: @"EditProfileSegue" sender: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AppBackground.png"]]];

    [self setTitle:@"Kickoff App"];
    
    [self addButtons];
    [self addLabels];
    
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Logout"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(logOutClicked:)];
    self.navigationItem.leftBarButtonItem = logOutButton;
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Profile"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(profileClicked:)];
    self.navigationItem.rightBarButtonItem = profileButton;

    gameReceived = 0;
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    NSInteger seconds = [tz secondsFromGMTForDate:[NSDate date]];
    NSDate *nowDate = [NSDate date];
    //NSLog(@"Seconds: %ld Minutes: %ld, Hours: %ld", seconds, seconds/60, seconds/3600);
    NSDate *adjustedDate = [nowDate dateByAddingTimeInterval:seconds];
    //NSLog(@"ADJ = %@", adjustedDate);
    //NSTimeInterval secondsInThirtySixHours = 36 * 60 * 60;
    //NSDate *dateAhead = [nowDate dateByAddingTimeInterval:secondsInThirtySixHours];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FootballSchedule"];
    [query orderByAscending:@"gameDate"];
//    [query whereKey:@"gameDate" greaterThan:dateAhead];
    [query whereKey:@"gameDate" greaterThan:adjustedDate];
    PFObject *object = [query getFirstObject];
    
    
    //[query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"query failed");
            gameReceived = 0;
            gameLabel.text = [NSString stringWithFormat:@"No game scheduled"];
            countDownLabel.text = @"";
        } else {
            NSLog(@"query succeeded");
            gameReceived = 1;
            gameObject = object;
            //gameLabel.text = [NSString stringWithFormat:@"%@\r-\rNotre Dame", [gameObject objectForKey:@"opponent"]];
            gameLabel.text = [NSString stringWithFormat:@"%@ - ND", [gameObject objectForKey:@"opponent"]];
            //gameLabel.text = [NSString stringWithFormat:@"%@ @ ND", [gameObject objectForKey:@"opponent"]];
            NSDate *gameDate = [gameObject objectForKey:@"gameDate"];
            
            NSDateFormatter *dayFormater = [[NSDateFormatter alloc]init];
            [dayFormater setDateFormat:@"dd"];
            
            int secondsBetween = [gameDate timeIntervalSinceDate:adjustedDate];
            int minutesBetween = secondsBetween/60;
            int hoursBetween = minutesBetween/60;
            int daysBetween = hoursBetween/24;
            
            NSLog(@"NOW = %@", adjustedDate);
            NSLog(@"GAME = %@", gameDate);
            
            NSLog(@"s=%d, m=%d, h=%d, d=%d", secondsBetween, minutesBetween, hoursBetween, daysBetween);
 
            NSLog(@"gamedate=%@", gameDate);
            
            BOOL gameScheduled = TRUE;

            if (secondsBetween < 0) {
                //gameLabel.text = [NSString stringWithFormat:@"No game scheduled"];
                countDownLabel.text = @"";
                gameScheduled = FALSE;
            } else {
                if (daysBetween < 0) {
                    if ([[gameObject objectForKey:@"kickoffTime"] isEqual: @"TBA"]) {
                        countDownLabel.text = [NSString stringWithFormat:@"Kickoff Time: TBA"];
                    } else {
                        if (hoursBetween > 0)
                            countDownLabel.text = [NSString stringWithFormat:@"Kickoff in %d hrs %d mins", hoursBetween, minutesBetween];
                        else
                            countDownLabel.text = [NSString stringWithFormat:@"Kickoff in %d mins", minutesBetween];
                    }
                } else {
                    countDownLabel.text = [NSString stringWithFormat:@"Kickoff in %d days", daysBetween];
                }
            }
            
            if (gameScheduled) {
                
                //PFObject *myObject = [userProfileData getOwnObject];
                
                //UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height + 7.0, 200.0, 25.0)];
                UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height + 17.0, 200.0, 25.0)];
                goingLabel.text = @"Going to this game?";
                goingLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
                goingLabel.textColor = [UIColor whiteColor];
                goingLabel.backgroundColor = [UIColor clearColor];
                
                //UILabel *trackingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height + 37.0, 200.0, 25.0)];
                UILabel *trackingLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height + 47.0, 200.0, 25.0)];
                trackingLabel.text = @"Allow friends to track me?";
                trackingLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
                trackingLabel.textColor = [UIColor whiteColor];
                trackingLabel.backgroundColor = [UIColor clearColor];
                
                goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [goBtn addTarget:self action:@selector(goMethod:) forControlEvents:UIControlEventTouchUpInside];
                //goBtn.frame = CGRectMake(self.view.frame.size.width - 90.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height
                //                                                             + 7.0, 50.0, 25.0);
                goBtn.frame = CGRectMake(self.view.frame.size.width - 90.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height
                                         + 17.0, 50.0, 25.0);
                
                [goBtn setTitle:@"No" forState:UIControlStateNormal];
                [goBtn setTitle:@"Yes" forState:UIControlStateSelected];
                goBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];

                [goBtn setBackgroundImage:[UIImage imageNamed:@"nostate"] forState:UIControlStateNormal];
                [goBtn setBackgroundImage:[UIImage imageNamed:@"yesstate"] forState:UIControlStateSelected];
                
                [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [goBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
                [goBtn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
                
                [goBtn setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
                
                goBtn.selected = NO;
                
                trackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [trackBtn addTarget:self action:@selector(trackMethod:) forControlEvents:UIControlEventTouchUpInside];
                //trackBtn.frame = CGRectMake(self.view.frame.size.width - 90.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height
                //                         + 37.0, 50.0, 25.0);
                trackBtn.frame = CGRectMake(self.view.frame.size.width - 90.0, countDownLabel.frame.origin.y + countDownLabel.frame.size.height
                                            + 47.0, 50.0, 25.0);
                
                [trackBtn setTitle:@"No" forState:UIControlStateNormal];
                [trackBtn setTitle:@"Yes" forState:UIControlStateSelected];
                
                [trackBtn setBackgroundImage:[UIImage imageNamed:@"nostate"] forState:UIControlStateNormal];
                [trackBtn setBackgroundImage:[UIImage imageNamed:@"yesstate"] forState:UIControlStateSelected];
                
                [trackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [trackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                
                trackBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];

                [trackBtn setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];

                trackBtn.selected = NO;
                
                userProfileData = [ProfileData sharedInstance];
                PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
                [query whereKey:@"username" equalTo:[userProfileData getUserName]];
                PFObject *object = [query getFirstObject];
                [userProfileData setOwnObject:object];
                
                if ([object objectForKey:@"attendNextGame"] == [NSNumber numberWithBool:TRUE]) {
                    goBtn.selected = YES;
                    if ([object objectForKey:@"trackingAllowed"] == [NSNumber numberWithBool:TRUE]) {
                        trackBtn.selected = YES;
                    }
                }
                
                [self.view addSubview:goingLabel];
                [self.view addSubview:goBtn];
                [self.view addSubview:trackBtn];

                //[self.view addSubview:goingToGameSwitch];
                [self.view addSubview:trackingLabel];
                //[self.view addSubview:trackingSwitch];
            }
            
        }
    //}];
    [self reloadInputViews];
    
    userProfileData = [ProfileData sharedInstance];
    [userProfileData setProfileUpdated:TRUE];

    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        [userProfileData setUserName:[currentUser objectForKey:@"username"]];
        PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
        [query whereKey:@"username" equalTo:[userProfileData getUserName]];
        PFObject *object = [query getFirstObject];
        [userProfileData setOwnObject:object];
        //[self setTitle:[userProfileData getUserName]];
        
        BOOL isGoing = [[object objectForKey:@"attendNextGame"] boolValue];
        if (isGoing)
            goBtn.selected = YES;
        else
            goBtn.selected = NO;

        BOOL isTracking = [[object objectForKey:@"trackingAllowed"] boolValue];
        if (isTracking)
            trackBtn.selected = YES;
        else
            trackBtn.selected = NO;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //NSLog(@"Start recording locations");
    //[self.locationManager startUpdatingLocation];

    
}


-(void)goMethod:(id)sender
{
    UIButton *thisButton = (UIButton *)sender;
    
    if (thisButton.selected == TRUE) {
        thisButton.selected = FALSE;
        trackBtn.selected = FALSE;
        [self stopTracking];
    } else {
        thisButton.selected = TRUE;
    }
    
    // Update parse with new information
    
    userProfileData = [ProfileData sharedInstance];

    PFObject *object = [userProfileData getOwnObject];

    if (object == nil) {
        PFQuery *myObjectQuery = [PFQuery queryWithClassName:@"Profile"];
        [myObjectQuery whereKey:@"username" equalTo:[userProfileData getUserName]];
        PFObject *resultObject = [myObjectQuery getFirstObject];
        [userProfileData setOwnObject:resultObject];
        object = resultObject;
    }

    [object setObject:[NSNumber numberWithBool:thisButton.selected] forKey:@"attendNextGame"];
    [object setObject:[NSNumber numberWithBool:trackBtn.selected] forKey:@"trackingAllowed"];
    [object save];
}

- (void)startTracking {
    NSLog(@"Start tracking");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        userProfileData = [ProfileData sharedInstance];
        [userProfileData setLocationTracking:TRUE];
        [userProfileData setLocationMgr:self.locationManager];
        [self.locationManager startUpdatingLocation];
    });
    
}

- (void)stopTracking {
    NSLog(@"Stop tracking");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        userProfileData = [ProfileData sharedInstance];
        [userProfileData setLocationTracking:FALSE];
        [self.locationManager stopUpdatingLocation];
    });

}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    NSLog(@"GOT NEW LOCATION");
    
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                  longitude:coordinate.longitude];
    
    PFObject *myObject = [userProfileData getOwnObject];
    
    [myObject setObject:geoPoint forKey:@"location"];
    
    [myObject saveInBackground];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"GOT LOCATION ERROR");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        trackBtn.selected = TRUE;
        [self startTracking];
        
        userProfileData = [ProfileData sharedInstance];
        
        PFObject *object = [userProfileData getOwnObject];
        
        if (object == nil) {
            PFQuery *myObjectQuery = [PFQuery queryWithClassName:@"Profile"];
            [myObjectQuery whereKey:@"username" equalTo:[userProfileData getUserName]];
            PFObject *resultObject = [myObjectQuery getFirstObject];
            [userProfileData setOwnObject:resultObject];
            object = resultObject;
        }
        [object setObject:[NSNumber numberWithBool:goBtn.selected] forKey:@"attendNextGame"];
        [object setObject:[NSNumber numberWithBool:trackBtn.selected] forKey:@"trackingAllowed"];
        [object save];

    }
}

-(void)trackMethod:(id)sender
{
    UIButton *thisButton = (UIButton *)sender;

    if (thisButton.selected == TRUE) {
        thisButton.selected = FALSE;
        [self stopTracking];
    } else {
        if (goBtn.selected == TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Tracking" message:@"Your location will be recorded and made available to your friends only (tracking will turn off automatically about 24 hours after a game)!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert addButtonWithTitle:@"Yes"];
            [alert show];
            return;
        }
    }
    
    userProfileData = [ProfileData sharedInstance];
    
    PFObject *object = [userProfileData getOwnObject];
    
    if (object == nil) {
        PFQuery *myObjectQuery = [PFQuery queryWithClassName:@"Profile"];
        [myObjectQuery whereKey:@"username" equalTo:[userProfileData getUserName]];
        PFObject *resultObject = [myObjectQuery getFirstObject];
        [userProfileData setOwnObject:resultObject];
        object = resultObject;
    }
    
    [object setObject:[NSNumber numberWithBool:goBtn.selected] forKey:@"attendNextGame"];
    [object setObject:[NSNumber numberWithBool:thisButton.selected] forKey:@"trackingAllowed"];
    [object save];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
