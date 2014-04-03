//
//  ChatRoomViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/3/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"

@interface ChatRoomViewController : UIViewController <UITextFieldDelegate>
{
    
    IBOutlet UITextField *tfEntry;
    IBOutlet UITableView *chatTable;
    NSArray *chatData;
    PF_EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSString *className;
    NSString *userName;
    NSArray *myFriends;
    ProfileData *userProfileData;
    
}

@property(nonatomic, strong) IBOutlet UITextField *tfEntry;
@property (nonatomic, retain) UITableView *chatTable;
@property (nonatomic, retain) NSArray *chatData;

-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;
-(void)loadLocalChat;
- (IBAction)newChat;

@end