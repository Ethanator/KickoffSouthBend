//
//  FriendsViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"

@interface FriendsViewController : UITableViewController {
    ProfileData *userProfileData;
    PFObject *myObject;
    NSArray *myFriends;
    NSArray *myInviters;
    NSArray *myInvitees;
    BOOL noFriends;
    NSInteger currentIndex;
}

@end
