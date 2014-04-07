//
//  FindFriendViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "FindFriendViewController.h"

@interface FindFriendViewController ()

@end

@implementation FindFriendViewController

@synthesize userSearchBar, peopleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allFound = [[NSArray alloc] init];
    }
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    searchTerm = searchBar.text;
    
    if ([searchTerm isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Search Failed"
                                    message:@"No search string has been entered."
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    } else {
        searchRequested = YES;
        [self fetchDataFromParse];
        [peopleView reloadData];
    }
    
    [userSearchBar resignFirstResponder];
}

-(IBAction)searchNow:(id)sender
{
    
    NSLog(@"Search now");
    
    searchTerm = userSearchBar.text;

    NSLog(@"Search now (%@)", searchTerm);
    
    if ([searchTerm isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Search Failed"
                                    message:@"No search string has been entered."
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"Search now2");
        searchRequested = YES;
        //searchTerm = userSearchBar.text;
        [self fetchDataFromParse];
        [peopleView reloadData];
    }
    
    [userSearchBar resignFirstResponder];
}


#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    isSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    isSearching = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void) fetchDataFromParse {
    
    userProfileData = [ProfileData sharedInstance];
    
    if (searchRequested == YES) {
        PFQuery *query1 = [PFQuery queryWithClassName:@"Profile"];
        [query1 whereKey:@"username" notEqualTo:[userProfileData getUserName]];
        [query1 whereKey:@"lastname_lower" hasPrefix:[searchTerm lowercaseString]];
        [query1 orderByAscending:@"lastname"];
        query1.limit = 100;
        userArray1 = [query1 findObjects];
        arrayCount1 = [userArray1 count];
        PFQuery *query2 = [PFQuery queryWithClassName:@"Profile"];
        [query2 whereKey:@"username" notEqualTo:[userProfileData getUserName]];
        [query2 whereKey:@"firstname_lower" hasPrefix:[searchTerm lowercaseString]];
        [query2 orderByAscending:@"firstname"];
        query2.limit = 100;
        userArray2 = [query2 findObjects];
        arrayCount2 = [userArray2 count];
        PFQuery *query3 = [PFQuery queryWithClassName:@"Profile"];
        [query3 whereKey:@"username" notEqualTo:[userProfileData getUserName]];
        [query3 whereKey:@"username" hasPrefix:[searchTerm lowercaseString]];
        [query3 orderByAscending:@"username"];
        query3.limit = 100;
        userArray3 = [query3 findObjects];
        arrayCount3 = [userArray3 count];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:userArray1];
        [tempArray addObjectsFromArray:userArray2];
        [tempArray addObjectsFromArray:userArray3];

        NSMutableArray *uniqueValues = [[NSMutableArray alloc] init];
        NSMutableArray *foundUserNames = [[NSMutableArray alloc] init];
        for(id e in tempArray)
        {
            if (![foundUserNames containsObject:[e objectForKey:@"username"]]) {
                [foundUserNames addObject:[e objectForKey:@"username"]];
                [uniqueValues addObject:e];
            }
        }
        allFound = uniqueValues;

        NSMutableArray *tempFriends = [[NSMutableArray alloc] init];
        for (int i = 0; i < [allFound count]; i++) {
            [tempFriends addObject:[[allFound objectAtIndex:i] objectForKey:@"username"]];
        }
        
        PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery1 whereKey:@"inviter" containedIn:tempFriends];
        [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
        PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery2 whereKey:@"invitee" containedIn:tempFriends];
        [friendQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
        NSArray *friendList1 = [friendQuery1 findObjects];
        NSArray *friendList2 = [friendQuery2 findObjects];
        
        NSMutableArray *tempFriendsIInvited = [[NSMutableArray alloc] init];
        NSMutableArray *tempFriendsInvitedMe = [[NSMutableArray alloc] init];
        NSMutableArray *tempFriendsConfirmed = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [friendList1 count]; j++) {
            NSNumber *isFriend = [[friendList1 objectAtIndex:j] objectForKey:@"confirmed"];
            BOOL isFriendBool = [isFriend boolValue];
            NSNumber *isPending = [[friendList1 objectAtIndex:j] objectForKey:@"invited"];
            BOOL isPendingBool = [isPending boolValue];
            if (isFriendBool)
                [tempFriendsConfirmed addObject:[[friendList1 objectAtIndex:j] objectForKey:@"inviter"]];
            else if (isPendingBool)
                [tempFriendsInvitedMe addObject:[[friendList1 objectAtIndex:j] objectForKey:@"inviter"]];
        }
        for (int k = 0; k < [friendList2 count]; k++) {
            NSNumber *isFriend = [[friendList2 objectAtIndex:k] objectForKey:@"confirmed"];
            BOOL isFriendBool = [isFriend boolValue];
            NSNumber *isPending = [[friendList2 objectAtIndex:k] objectForKey:@"invited"];
            BOOL isPendingBool = [isPending boolValue];
            if (isFriendBool)
                [tempFriendsConfirmed addObject:[[friendList2 objectAtIndex:k] objectForKey:@"invitee"]];
            else if (isPendingBool)
                [tempFriendsIInvited addObject:[[friendList2 objectAtIndex:k] objectForKey:@"invitee"]];
        }
        
        NSMutableArray *tempAllFriends = [[NSMutableArray alloc] init];
        for (int l = 0; l < [allFound count]; l++) {
            if ([tempFriendsConfirmed containsObject:[[allFound objectAtIndex:l] objectForKey:@"username"]]) {
                [tempAllFriends addObject:[NSNumber numberWithInt:3]];
            } else if ([tempFriendsInvitedMe containsObject:[[allFound objectAtIndex:l] objectForKey:@"username"]]) {
                [tempAllFriends addObject:[NSNumber numberWithInt:2]];
            } else if ([tempFriendsIInvited containsObject:[[allFound objectAtIndex:l] objectForKey:@"username"]]) {
                [tempAllFriends addObject:[NSNumber numberWithInt:1]];
            } else
                [tempAllFriends addObject:[NSNumber numberWithInt:0]];
        }
        allFriends = [[NSArray alloc] initWithArray:tempAllFriends];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    userProfileData = [ProfileData sharedInstance];
    
    if (clearTable == YES) {
        clearTable = NO;
        return 0;
    }
    
    if (searchRequested) {
        totalCount = [allFound count];
        return totalCount;
    } else {
        totalCount = 0;
        return 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    
    PFObject *thisObject;
    
    thisObject = [allFound objectAtIndex:indexPath.row];
    
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
    
    PFFile *myImageFile = [thisObject objectForKey:@"profileimage"];
    NSData *imageData = [myImageFile getData];
    UIImage *thisProfileImage = [UIImage imageWithData:imageData];
    if (thisProfileImage == nil)
        thisProfileImage = [UIImage imageNamed:@"profile_placeholder.png"];
    UIImageView *profileImage = [[UIImageView alloc] initWithImage:thisProfileImage];
    profileImage.frame = CGRectMake(10.0, 7.0, 30.0, 30.0);
    [cell addSubview:profileImage];

    UILabel *nameLabel = [[UILabel alloc] init];
    UILabel *affiliationLabel = [[UILabel alloc] init];
    //UILabel *infoLabel = [[UILabel alloc] init];
    nameLabel.text = fullName;
    affiliationLabel.text = [thisObject objectForKey:@"affiliation"];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    affiliationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    //infoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    nameLabel.frame = CGRectMake(50.0, 5.0, 250.0, 20.0);
    affiliationLabel.frame = CGRectMake(50.0, 23.0, 250.0, 14.0);
    //infoLabel.frame = CGRectMake(50.0, 37.0, 250.0, 14.0);
    //infoLabel.textColor = [UIColor grayColor];
    //infoLabel.text = @"";
    
    NSNumber *isPersonGrad = [thisObject objectForKey:@"ndgrad"];
    NSNumber *isPersonStudent = [thisObject objectForKey:@"ndstudent"];
    BOOL isPGrad = [isPersonGrad boolValue];
    BOOL isStudent = [isPersonStudent boolValue];
    if (isPGrad) {
        NSString *degreeYear = [thisObject objectForKey:@"year"];
        if ([affiliationLabel.text length] > 0) {
            if ([degreeYear length] > 0)
                affiliationLabel.text = [NSString stringWithFormat:@"%@ (ND %@)", affiliationLabel.text, degreeYear];
            else
                affiliationLabel.text = [NSString stringWithFormat:@"%@ (ND graduate)", affiliationLabel.text];
        } else {
            if ([degreeYear length] > 0)
                affiliationLabel.text = [NSString stringWithFormat:@"ND %@", degreeYear];
            else
                affiliationLabel.text = [NSString stringWithFormat:@"ND graduate"];
        }
    } else if (isStudent) {
        if ([affiliationLabel.text length] > 0)
            affiliationLabel.text = [NSString stringWithFormat:@"%@ (Student)", affiliationLabel.text];
        else
            affiliationLabel.text = [NSString stringWithFormat:@"Student"];
    }
    //[cell addSubview:infoLabel];
    [cell addSubview:nameLabel];
    [cell addSubview:affiliationLabel];
    
    UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    connectButton.frame = CGRectMake(cell.frame.size.width - 80.0, 7.0, 70.0, 30.0);
    [connectButton setBackgroundColor:[UIColor colorWithRed:29.0/255 green:64.0/255 blue:115.0/255 alpha:1.0]];
    connectButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    connectButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    connectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSNumber *thisNumber = [allFriends objectAtIndex:indexPath.row];
    int number = [thisNumber intValue];
    
    if (number == 3) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:169.0/255 green:169.0/255 blue:169.0/255 alpha:1.0]];
        [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else if (number == 2) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:0.0/255 green:187.0/255 blue:223.0/255 alpha:1.0]];
        [connectButton setTitle:@"Accept\nInvitation" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else if (number == 1) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:0.0/255 green:187.0/255 blue:223.0/255 alpha:1.0]];
        [connectButton setTitle:@"Invitation\nSent" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else if (number == 0) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:29.0/255 green:64.0/255 blue:115.0/255 alpha:1.0]];
        [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else
        connectButton.hidden = TRUE;
    connectButton.selected = FALSE;
    connectButton.tag = indexPath.row;
    [cell addSubview:connectButton];
    [connectButton addTarget:self action:@selector(inviteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger thisTag = alertView.tag;
    
    if (thisTag == 1) { // Disconnect or cancel
        NSLog(@"Disconnect?");
        if (buttonIndex == 0) // Cancel
            return;
        else { // Disconnect
            PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
            [friendQuery1 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
            [friendQuery1 whereKey:@"invitee" equalTo:[[allFound objectAtIndex:currentIndex] objectForKey:@"username"]];
            PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
            [friendQuery2 whereKey:@"inviter" equalTo:[[allFound objectAtIndex:currentIndex] objectForKey:@"username"]];
            [friendQuery2 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            NSArray *objects1 = [friendQuery1 findObjects];
            NSArray *objects2 = [friendQuery2 findObjects];
            NSInteger counter = [objects1 count];
            while (counter > 0) {
                counter--;
                PFObject *thisObject = [objects1 objectAtIndex:counter];
                [thisObject delete];
            }
            counter = [objects2 count];
            while (counter > 0) {
                counter--;
                PFObject *thisObject = [objects2 objectAtIndex:counter];
                [thisObject delete];
            }
        }
    } else if (thisTag == 2) { // Accept/discard invite
        NSLog(@"Accept?");
        PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery1 whereKey:@"inviter" equalTo:[[allFound objectAtIndex:currentIndex] objectForKey:@"username"]];
        [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
        NSArray *objects1 = [friendQuery1 findObjects];
        NSInteger counter = [objects1 count];
        if (buttonIndex == 0) { // Discard invite
            while (counter > 0) {
                counter--;
                PFObject *thisObject = [objects1 objectAtIndex:counter];
                [thisObject delete];
            }
        } else { // Accept invite
            while (counter > 1) {
                counter--;
                PFObject *thisObject = [objects1 objectAtIndex:counter];
                [thisObject delete];
            }
            if (counter == 1) {
                PFObject *thisObject = [objects1 objectAtIndex:0];
                [thisObject setObject:[NSNumber numberWithInt:0] forKey:@"invited"];
                [thisObject setObject:[NSNumber numberWithInt:1] forKey:@"confirmed"];
                [thisObject save];
            }
        }
    } else if (thisTag == 3) { // Cancel invite
        NSLog(@"Cancel?");
        if (buttonIndex == 0) { // Yes
            PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
            [friendQuery1 whereKey:@"invitee" equalTo:[[allFound objectAtIndex:currentIndex] objectForKey:@"username"]];
            [friendQuery1 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
            NSArray *objects1 = [friendQuery1 findObjects];
            NSInteger counter = [objects1 count];
            while (counter > 0) {
                counter--;
                PFObject *thisObject = [objects1 objectAtIndex:counter];
                [thisObject delete];
            }
        } else { // No
            return;
        }
    } else if (thisTag == 4) { // Connect
        NSLog(@"Invite (%ld, %@, %@)?", (long)currentIndex, [userProfileData getUserName], [[allFound objectAtIndex:currentIndex] objectForKey:@"username"]);
        if (buttonIndex == 0) { // Cancel
            return;
        } else { // Yes
            PFObject *newObject = [PFObject objectWithClassName:@"Friends"];
            [newObject setObject:[userProfileData getUserName] forKey:@"inviter"];
            [newObject setObject:[[allFound objectAtIndex:currentIndex] objectForKey:@"username"] forKey:@"invitee"];
            [newObject setObject:[NSNumber numberWithInt:0] forKey:@"confirmed"];
            [newObject setObject:[NSNumber numberWithInt:1] forKey:@"invited"];
            [newObject save];
        }
    }
    
    float verticalContentOffset = self.peopleView.contentOffset.y;
    [self fetchDataFromParse];
    [self.peopleView reloadData];
    [self.peopleView setContentOffset:CGPointMake(0, verticalContentOffset)];
}

-(void)inviteButton:(id)sender {
 
    UIButton *thisButton = (UIButton *)sender;
    NSInteger index = thisButton.tag;
    PFObject *thisObject = [allFound objectAtIndex:index];
    NSNumber *thisNumber = [allFriends objectAtIndex:index];
    int number = [thisNumber intValue];
    currentIndex = index;
    
    NSString *firstname = [thisObject objectForKey:@"firstname"];
    NSString *lastname = [thisObject objectForKey:@"lastname"];
    NSString *username = [thisObject objectForKey:@"username"];
    NSString *fullname;
    if ([firstname length] > 0)
        fullname = firstname;
    else if ([lastname length] > 0)
        fullname = lastname;
    else
        fullname = username;
        
    if (number == 3) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Friends"
                                    message:[NSString stringWithFormat:@"Are you sure you want to disconnect from %@?", fullname]
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
        [alert1 setTag:1];
        [alert1 show];
    } else if (number == 2) {
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Friends"
                                    message:[NSString stringWithFormat:@"Do you want to accept or discard the invitation from %@?", fullname]
                                   delegate:self
                          cancelButtonTitle:@"Discard"
                          otherButtonTitles:@"Accept", nil];
        [alert2 setTag:2];
        [alert2 show];
    } else if (number == 1) {
        UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle:@"Friends"
                                    message:[NSString stringWithFormat:@"Do you want to cancel your invitation to %@?", fullname]
                                   delegate:self
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil];
        [alert3 setTag:3];
        [alert3 show];
    } else if (number == 0) {
        UIAlertView *alert4 = [[UIAlertView alloc] initWithTitle:@"Friends"
                                    message:[NSString stringWithFormat:@"Do you want to connect to %@?", fullname]
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Yes", nil];
        [alert4 setTag:4];
        [alert4 show];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    searchRequested = NO;
    searchTerm = @"";
    clearTable = NO;
    addMore = NO;
    currentSkip = 0;
    
    peopleView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [peopleView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.userSearchBar setDelegate:self];
    
    [self fetchDataFromParse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 44.0;
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    if(y > h + reload_distance) {
        addMore = TRUE;
        [self fetchDataFromParse];
    }
}
*/

@end
