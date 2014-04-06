//
//  ChatDetailTableViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/4/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"

@interface ChatDetailTableViewController : UIViewController <UITextFieldDelegate> {
    
    PFObject *chatObject;
    PFObject *thisObject;
    IBOutlet UITextField *tfEntry;
    IBOutlet UITableView *chatTable;
    PF_EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL textFieldActive;
    IBOutlet UIImageView *backgroundText;
    BOOL _reloading;
    NSString *userName;
    ProfileData *userProfileData;
    NSArray *chatData;
    BOOL noChats;
    NSArray *myFriends;
    
}

@property(nonatomic, strong) IBOutlet UITextField *tfEntry;
@property (nonatomic, retain) UITableView *chatTable;

- (void)setChatObject:(PFObject *)thisChatObject;
- (void)setAskerObject:(PFObject *)thisAskerObject;
- (IBAction)newChat;
-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;

@end
