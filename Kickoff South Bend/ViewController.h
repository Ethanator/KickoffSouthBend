//
//  ViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/5/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    NSInteger gameReceived;
    UILabel *gameLabel;
    UILabel *countDownLabel;
    PFObject *gameObject;
    ProfileData *userProfileData;
}

@end
