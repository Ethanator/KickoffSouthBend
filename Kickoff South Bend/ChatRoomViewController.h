//
//  ChatRoomViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/3/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatRoomViewController : UIViewController <UITextFieldDelegate>
{
    
    UITextField             *tfEntry;
    IBOutlet UITableView    *chatTable;
    NSMutableArray          *chatData;
    PF_EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
}

@property(nonatomic, strong) IBOutlet UITextField *tfEntry;
@property (nonatomic, retain) UITableView *chatTable;
@property (nonatomic, retain) NSArray *chatData;

-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;

@end