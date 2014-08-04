//
//  SeeFriendViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 8/4/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import "SeeFriendViewController.h"

@interface SeeFriendViewController ()

@end

@implementation SeeFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setFriendObject:(PFObject *)thisFriendObject
{
    thisObject = thisFriendObject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *firstname = [thisObject objectForKey:@"firstname"];
    NSString *lastname = [thisObject objectForKey:@"lastname"];
    NSString *username = [thisObject objectForKey:@"username"];
    NSString *fullName;
    if (([firstname length] > 0) && ([lastname length] > 0))
    fullName = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    else if ([lastname length] > 0)
    fullName = [NSString stringWithFormat:@"%@", lastname];
    else
    fullName = [NSString stringWithFormat:@"%@", username];
    fullRecName = fullName;
    nameLabel.text = fullName;
    
    PFFile *myImageFile = [thisObject objectForKey:@"profileimage"];
    NSData *imageData = [myImageFile getData];
    UIImage *thisProfileImage = [UIImage imageWithData:imageData];
    if (thisProfileImage == nil)
    thisProfileImage = [UIImage imageNamed:@"profile_placeholder.png"];
    profilePic.image = thisProfileImage;
    
    NSString *affiliation = [thisObject objectForKey:@"affiliation"];
    affLabel.text = affiliation;
    
    BOOL graduate = [[thisObject objectForKey:@"ndgrad"] boolValue];
    BOOL student = [[thisObject objectForKey:@"ndstudent"] boolValue];
    NSString *myYear = [thisObject objectForKey:@"year"];
    NSString *myEmail = [thisObject objectForKey:@"emailAddress"];

    if (student) {
        ndInfo.text = @"ND Student";
    } else {
        if (graduate) {
            ndInfo.text = [NSString stringWithFormat:@"ND %@", myYear];

        } else {
            ndInfo.text = @"";
        }
    }
    
    if ([myEmail length] > 0) {
        emailButton.hidden = false;
        emailButton.enabled = true;
        [emailButton setTitle:myEmail forState:UIControlStateNormal];
    } else {
        emailButton.hidden = true;
        emailButton.enabled = false;
    }
}

- (IBAction)sendEmail:(id)sender
{
    NSString *mailaddr = [thisObject objectForKey:@"emailAddress"];
    
    // Email Subject
    NSString *emailTitle = @"";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:mailaddr];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
