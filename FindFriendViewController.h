//
//  FindFriendViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileData.h"

//@interface FindFriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate> {
@interface FindFriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UISearchBarDelegate> {
    BOOL isSearching;
    IBOutlet UISearchBar *userSearchBar;
    NSString *searchTerm;
    BOOL searchRequested;
    IBOutlet UITableView *peopleView;
    BOOL clearTable;
    ProfileData *userProfileData;
    NSArray *userArray1;
    NSArray *userArray2;
    NSArray *userArray3;
    NSArray *userArray4;
    NSArray *allPeople;
    NSInteger arrayCount1;
    NSInteger arrayCount2;
    NSInteger arrayCount3;
    NSInteger arrayCount4;
    BOOL addMore;
    int currentSkip;
    NSArray *allFound;
    NSArray *allFriends; // 0 is no friends; 1 is invitation sent; 2 is invitation waiting; 3 is friends
    NSInteger totalCount;
    NSInteger currentIndex;
}

@property(nonatomic,retain) IBOutlet UISearchBar *userSearchBar;
@property(nonatomic,retain) IBOutlet UITableView *peopleView;

-(IBAction)searchNow:(id)sender;

@end
