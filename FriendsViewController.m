//
//  FriendsViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "FriendsViewController.h"
#import "CustomPeopleCell.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        noFriends = TRUE;
        myFriends = [[NSArray alloc] init];
        myInvitees = [[NSArray alloc] init];
        myInviters = [[NSArray alloc] init];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (noFriends)
        return 80.0;
    else
        return 44.0;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self fetchDataFromParse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void) fetchDataFromParse {
    
    userProfileData = [ProfileData sharedInstance];
    
    PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
    PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
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
    
    NSMutableArray *tempFriendsIInvited2 = [[NSMutableArray alloc] init];
    NSMutableArray *tempFriendsInvitedMe2 = [[NSMutableArray alloc] init];
    NSMutableArray *tempFriendsConfirmed2 = [[NSMutableArray alloc] init];

    for (int j = 0; j < [tempFriendsConfirmed count]; j++) {
        if ([tempFriendsConfirmed2 containsObject:[tempFriendsConfirmed objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                }
            } else {
                [tempObject delete];
            }
        } else {
            [tempFriendsConfirmed2 addObject:[tempFriendsConfirmed objectAtIndex:j]];
        }
        if ([tempFriendsIInvited containsObject:[tempFriendsConfirmed objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                    [tempFriendsIInvited removeObject:[tempFriendsConfirmed objectAtIndex:j]];
                }
            } else {
                [tempObject delete];
                [tempFriendsIInvited removeObject:[tempFriendsConfirmed objectAtIndex:j]];
            }
        }
        if ([tempFriendsInvitedMe containsObject:[tempFriendsConfirmed objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                    [tempFriendsInvitedMe removeObject:[tempFriendsConfirmed objectAtIndex:j]];
                }
            } else {
                [tempObject delete];
                [tempFriendsInvitedMe removeObject:[tempFriendsConfirmed objectAtIndex:j]];
            }
        }
    }
    
    for (int j = 0; j < [tempFriendsIInvited count]; j++) {
        if ([tempFriendsIInvited2 containsObject:[tempFriendsIInvited objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsIInvited objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsIInvited objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                }
            } else {
                [tempObject delete];
            }
        } else {
            [tempFriendsIInvited2 addObject:[tempFriendsIInvited objectAtIndex:j]];
        }
        if ([tempFriendsInvitedMe containsObject:[tempFriendsIInvited objectAtIndex:j]]) {
            PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
            [tempQuery whereKey:@"inviter" equalTo:[tempFriendsIInvited objectAtIndex:j]];
            [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
            PFObject *tempObject = [tempQuery getFirstObject];
            if (tempObject == nil) {
                PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsIInvited objectAtIndex:j]];
                [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                PFObject *tempObject2 = [tempQuery2 getFirstObject];
                if (tempObject2 != nil) {
                    [tempObject2 delete];
                    [tempFriendsInvitedMe removeObject:[tempFriendsIInvited objectAtIndex:j]];
                }
            } else {
                [tempObject delete];
                [tempFriendsInvitedMe removeObject:[tempFriendsIInvited objectAtIndex:j]];
            }
        }
    }
    
    tempFriendsInvitedMe2 = tempFriendsInvitedMe;
    
    PFQuery *fquery1 = [PFQuery queryWithClassName:@"Profile"];
    [fquery1 whereKey:@"username" containedIn:tempFriendsConfirmed2];
    [fquery1 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    myFriends = [fquery1 findObjects];
    
    PFQuery *fquery2 = [PFQuery queryWithClassName:@"Profile"];
    [fquery2 whereKey:@"username" containedIn:tempFriendsInvitedMe2];
    [fquery2 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    myInviters = [fquery2 findObjects];
    
    PFQuery *fquery3 = [PFQuery queryWithClassName:@"Profile"];
    [fquery3 whereKey:@"username" containedIn:tempFriendsIInvited2];
    [fquery3 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    myInvitees = [fquery3 findObjects];

}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Friends Inviting Me", @"Friends Inviting Me");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Friends I Invited", @"Friends I Invited");
            break;
        case 2:
            sectionName = NSLocalizedString(@"My Friends", @"My Friends");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (([myInvitees count] == 0) && ([myInviters count] == 0) && ([myFriends count] == 0))
        noFriends = TRUE;
    else
        noFriends = FALSE;
    
    return [myFriends count] + [myInvitees count] + [myInviters count];

    /*
    if (section == 0)
        return [myInviters count];
    else if (section == 1)
        return [myInvitees count];
    else if (section == 2)
        return [myFriends count];
    
    return 0;
    */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"FriendsCell"];
    CustomPeopleCell *cell = (CustomPeopleCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (noFriends) {
        
        UILabel *noFriendsLabel = [[UILabel alloc] init];
        noFriendsLabel.text = @"No friends yet. Click the plus sign above to search for friends.";
        noFriendsLabel.frame = CGRectMake(50.0, 0.0, self.view.frame.size.width - 100.0, 80.0f);
        noFriendsLabel.textAlignment = NSTextAlignmentCenter;
        noFriendsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        noFriendsLabel.textColor = [UIColor grayColor];
        noFriendsLabel.numberOfLines = 0;
        [cell addSubview:noFriendsLabel];
        
        return cell;
    }
    
    PFObject *thisObject;
    int friendType; // 0 = inviter, 1 = invitee, 2 = friend
    
    if (indexPath.row < [myInviters count]) {
        thisObject = [myInviters objectAtIndex:indexPath.row];
        friendType = 0;
    } else if (indexPath.row < ([myInviters count] + [myInvitees count])) {
        thisObject = [myInvitees objectAtIndex:indexPath.row - [myInviters count]];
        friendType = 1;
    } else {
        thisObject = [myFriends objectAtIndex:indexPath.row - [myInviters count] - [myInvitees count]];
        friendType = 2;
    }
    
    /*
    if (indexPath.section == 0) {
        thisObject = [myInviters objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        thisObject = [myInvitees objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        thisObject = [myFriends objectAtIndex:indexPath.row];
    }
    */
    
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
    
    if (friendType == 2) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:169.0/255 green:169.0/255 blue:169.0/255 alpha:1.0]];
        [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else if (friendType == 0) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:0.0/255 green:187.0/255 blue:223.0/255 alpha:1.0]];
        [connectButton setTitle:@"Accept\nInvitation" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else if (friendType == 1) {
        [connectButton setBackgroundColor:[UIColor colorWithRed:0.0/255 green:187.0/255 blue:223.0/255 alpha:1.0]];
        [connectButton setTitle:@"Invitation\nSent" forState:UIControlStateNormal];
        connectButton.enabled = TRUE;
    } else
        connectButton.hidden = TRUE;
    connectButton.selected = FALSE;
    connectButton.tag = indexPath.row;
    [cell addSubview:connectButton];
    [connectButton addTarget:self action:@selector(inviteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/*
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
*/

/*
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
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
