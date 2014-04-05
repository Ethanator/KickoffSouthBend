//
//  ChatDetailTableViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/4/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatDetailTableViewController : UITableViewController {
    
    PFObject *chatObject;
    PFObject *askerObject;
    
}

- (void)setChatObject:(PFObject *)thisChatObject;
- (void)setAskerObject:(PFObject *)thisAskerObject;
- (IBAction)newChat;

@end
