//
//  SeeFriendViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 8/4/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"
#import <MessageUI/MessageUI.h>

@interface SeeFriendViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    PFObject *thisObject;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *affLabel;
    IBOutlet UILabel *ndInfo;
    IBOutlet UILabel *emailLabel;
    IBOutlet UIImageView *profilePic;
    IBOutlet UIButton *emailButton;
    NSString *fullRecName;

}

- (void)setFriendObject:(PFObject *)thisFriendObject;

- (IBAction)sendEmail:(id)sender;

@end
