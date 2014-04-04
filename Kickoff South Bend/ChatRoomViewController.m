//
//  ChatRoomViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/3/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatCell.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 25


@interface ChatRoomViewController () <UITableViewDelegate, UITableViewDataSource,PF_EGORefreshTableHeaderDelegate>

@end

@implementation ChatRoomViewController

@synthesize tfEntry;
@synthesize chatData, chatTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        myFriends = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    userProfileData = [ProfileData sharedInstance];

    className = @"ChatRoom";
    userName = [userProfileData getUserName];
    
    chatData  = [[NSArray alloc] init];
    [self loadLocalChat];
}

- (IBAction)newChat
{
    NSLog(@"here now");
    [tfEntry becomeFirstResponder];
}

-(void)hideKeyBoard {
    NSLog(@"dismiss");
    [tfEntry resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    //CGRect screenBound = [[UIScreen mainScreen] bounds];
    //CGSize screenSize = screenBound.size;

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    [chatTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    chatTable.opaque = NO;
    chatTable.backgroundView = nil;
    
    noChats = TRUE;
    
    textFieldActive = FALSE;
    
    tfEntry.delegate = self;
    tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfEntry.hidden = TRUE;

    //backgroundText = [[UIImageView alloc] init];
    //backgroundText.image = [UIImage imageNamed:@"squared_metal.png"];
    backgroundText.hidden = TRUE;
    
    //tfEntry.frame = CGRectMake(20.0, screenSize.height-30.0, 280.0, 30.0);
    
    [self registerForKeyboardNotifications];
    
    if (_refreshHeaderView == nil) {

        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - chatTable.bounds.size.height, self.view.frame.size.width, chatTable.bounds.size.height)];
        view.delegate = self;
        [chatTable addSubview:view];
        _refreshHeaderView = view;
    }

    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];

    self.chatTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.chatTable setSeparatorInset:UIEdgeInsetsZero];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Chat textfield

-(IBAction) textFieldDoneEditing : (id) sender
{
    NSLog(@"the text content%@",tfEntry.text);
    [sender resignFirstResponder];
    [tfEntry resignFirstResponder];
    
    textFieldActive = FALSE;
}

-(IBAction) backgroundTap:(id) sender
{
    NSLog(@"background tap");
    [self.tfEntry resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"the text content: %@",tfEntry.text);
    [textField resignFirstResponder];
    
    textFieldActive = FALSE;
    
    if (tfEntry.text.length>0) {
        /*
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"userName", @"date", nil];
        NSArray *objects = [NSArray arrayWithObjects:tfEntry.text, userName, [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [chatData addObject:dictionary];
        
        NSLog(@"So far so good 1");
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        NSLog(@"So far so good 2");
        [chatTable beginUpdates];
        [chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [chatTable endUpdates];
        NSLog(@"So far so good 3");
        [chatTable reloadData];
        NSLog(@"So far so good 4");
        */
        
        NSLog(@"So far so good 1");

        // going for the parsing
        PFObject *newMessage = [PFObject objectWithClassName:@"ChatRoom"];
        [newMessage setObject:tfEntry.text forKey:@"text"];
        [newMessage setObject:userName forKey:@"userName"];
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage setObject:[NSNumber numberWithInt:0] forKey:@"response"];
        [newMessage setObject:[NSNumber numberWithInt:0] forKey:@"responses"];
        [newMessage save];
        NSLog(@"So far so good 2");

        tfEntry.text = @"";
    }
    
    // reload the data
    [self loadLocalChat];

    return NO;
}


-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    textFieldActive = TRUE;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    //[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:animationDuration];
    //[UIView setAnimationCurve:animationCurve];
    //[self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height+TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    [tfEntry setFrame:CGRectMake(tfEntry.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height - keyboardFrame.size.height - tfEntry.frame.size.height, tfEntry.frame.size.width, tfEntry.frame.size.height)];

    [backgroundText setFrame:CGRectMake(tfEntry.frame.origin.x-20.0, self.view.frame.origin.y + self.view.frame.size.height - keyboardFrame.size.height - tfEntry.frame.size.height-10.0, tfEntry.frame.size.width+40.0, tfEntry.frame.size.height+20.0)];

    tfEntry.hidden = FALSE;
    backgroundText.hidden = FALSE;

    
    //[UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //[self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
    //[self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
    tfEntry.hidden = TRUE;
    backgroundText.hidden = TRUE;

    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    NSLog(@"reload");

    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    [self loadLocalChat];
    [chatTable reloadData];
}

- (void)doneLoadingTableViewData{
    
    NSLog(@"done loading");

    //  model should call this when its done loading
    _reloading = NO;
    //[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTable];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"scroll1");

    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSLog(@"scroll2");

    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(PF_EGORefreshTableHeaderView*)view{
    
    NSLog(@"scroll3");

    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView*)view{
    
    NSLog(@"scroll4");

    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView*)view{
    
    NSLog(@"scroll5");

    return [NSDate date]; // should return date data source was last changed
    
}


#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([chatData count] > 0)
        return [chatData count];
    else
        return 1;
}

/*
-(CGSize)text:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size{
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              nil];
        
    CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
    return frame.size;
}
 */

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size{
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attributesDictionary
                                      context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"Clicked (%d)", textFieldActive);
    
    if (textFieldActive) {
        textFieldActive = FALSE;
        [tfEntry resignFirstResponder];
        return;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier: @"ChatCellID"];
    //NSUInteger row = [chatData count]-[indexPath row]-1;
    
    /*
    NSString *CellIdentifier = [NSString stringWithFormat:@"ChatCellID"];
    ChatCell *cell = (ChatCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    */
    
    static NSString *CellIdentifier = @"ChatCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    
    for(UIView* subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    if (noChats) {
        
        UILabel *noFriendsLabel = [[UILabel alloc] init];
        noFriendsLabel.text = @"No messages yet. Click the plus sign above to send a message to your friends.";
        noFriendsLabel.frame = CGRectMake(50.0, 0.0, self.view.frame.size.width - 100.0, 80.0f);
        noFriendsLabel.textAlignment = NSTextAlignmentCenter;
        noFriendsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        noFriendsLabel.textColor = [UIColor whiteColor];
        noFriendsLabel.backgroundColor = [UIColor clearColor];
        noFriendsLabel.numberOfLines = 0;
        [cell addSubview:noFriendsLabel];
        
        return cell;
    }

    PFObject *thisObject;
    PFObject *chatObject = [chatData objectAtIndex:indexPath.row];
    NSString *currentUserName = [[chatData objectAtIndex:indexPath.row] objectForKey:@"userName"];
    int count;
    for (int i = 0; i < [chatData count]; i++) {
        count = i;
        if ([currentUserName isEqualToString:[[myFriendsObjects objectAtIndex:i] objectForKey:@"username"]]) {
            thisObject = [myFriendsObjects objectAtIndex:i];
            break;
        }
    }
    
    if (count >= [chatData count]) {
        return cell;
    }
    
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
    nameLabel.text = currentUserName;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    nameLabel.frame = CGRectMake(48.0, 7.0, 150.0, 15.0);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:nameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    dateLabel.frame = CGRectMake(200.0, 7.0, 110.0, 15.0);
    dateLabel.textAlignment = NSTextAlignmentRight;
    NSDate *createdAt = [chatObject objectForKey:@"date"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyy-MM-dd"];
    NSDate *thisDate = [NSDate date];
    NSTimeInterval secondsBetween = [thisDate timeIntervalSinceDate:createdAt];
    NSInteger minutesPassed = secondsBetween/60;
    if (minutesPassed <= 0) minutesPassed = 1;
    NSString *dateString = @"";
    if (minutesPassed < 60)
        dateString = [NSString stringWithFormat:@"%ldm", (long)minutesPassed];
    else {
        NSInteger hoursPassed = minutesPassed/60;
        if (hoursPassed <= 0) hoursPassed = 1;
        if (hoursPassed < 24)
            dateString = [NSString stringWithFormat:@"%ldh", (long)hoursPassed];
        else {
            NSInteger daysPassed = hoursPassed/24;
            if (daysPassed <= 0) daysPassed = 1;
            if (daysPassed < 7)
                dateString = [NSString stringWithFormat:@"%ldd", (long)daysPassed];
            else {
                NSInteger weeksPassed = daysPassed/7;
                if (weeksPassed <= 0) weeksPassed = 1;
                if (weeksPassed < 52)
                    dateString = [NSString stringWithFormat:@"%ldw", (long)weeksPassed];
                else {
                    NSInteger yearsPassed = weeksPassed/52;
                    dateString = [NSString stringWithFormat:@"%ldy", (long)yearsPassed];
                }
            }
        }
    }
    dateLabel.text = dateString;
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:dateLabel];
    
    NSString *chatText = [chatObject objectForKey:@"text"];
    //cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    CGSize size = [self frameForText:chatText sizeWithFont:font constrainedToSize:CGSizeMake(260.0f, 1000.0f)];
    
    UITextView *textString = [[UITextView alloc] init];
    textString.frame = CGRectMake(45, 20, size.width + 30, size.height + 20);
    textString.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    textString.text = chatText;
    textString.textColor = [UIColor yellowColor];
    textString.backgroundColor = [UIColor clearColor];
    textString.editable = NO;
    [textString sizeToFit];
    [cell addSubview:textString];
    
    UILabel *responseLabel = [[UILabel alloc] init];
    int numResponses = [[chatObject objectForKey:@"responses"] integerValue];
    if (numResponses == 0)
        responseLabel.text = @"No responses";
    else if (numResponses == 1)
        responseLabel.text = @"1 response";
    else
        responseLabel.text = [NSString stringWithFormat:@"%d responses", numResponses];
    responseLabel.textColor = [UIColor whiteColor];
    responseLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    responseLabel.textAlignment = NSTextAlignmentCenter;
    responseLabel.frame = CGRectMake(20.0, textString.frame.origin.y + textString.frame.size.height - 5.0, 280.0, 15.0);
    [cell addSubview:responseLabel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if ((indexPath.row == 0) && (noChats == TRUE))
    //    return 60.0;
    
    //NSString *cellText = [[chatData objectAtIndex:chatData.count-indexPath.row-1] objectForKey:@"text"];
    NSString *cellText = [[chatData objectAtIndex:indexPath.row] objectForKey:@"text"];
    UIFont *cellFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    CGSize constraintSize = CGSizeMake(260.0f, MAXFLOAT);
    //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize labelSize = [self frameForText:cellText sizeWithFont:cellFont constrainedToSize:constraintSize];
    
    return labelSize.height + 50;
}

#pragma mark - Parse

- (void)loadLocalChat
{
    
    NSLog(@"load");

    userProfileData = [ProfileData sharedInstance];

    PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
    PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
    NSArray *friendList1 = [friendQuery1 findObjects];
    NSArray *friendList2 = [friendQuery2 findObjects];

    NSMutableArray *tempFriendsConfirmed = [[NSMutableArray alloc] init];

    for (int j = 0; j < [friendList1 count]; j++) {
        NSNumber *isFriend = [[friendList1 objectAtIndex:j] objectForKey:@"confirmed"];
        BOOL isFriendBool = [isFriend boolValue];
        if (isFriendBool)
            [tempFriendsConfirmed addObject:[[friendList1 objectAtIndex:j] objectForKey:@"inviter"]];
    }
    for (int k = 0; k < [friendList2 count]; k++) {
        NSNumber *isFriend = [[friendList2 objectAtIndex:k] objectForKey:@"confirmed"];
        BOOL isFriendBool = [isFriend boolValue];
        if (isFriendBool)
            [tempFriendsConfirmed addObject:[[friendList2 objectAtIndex:k] objectForKey:@"invitee"]];
    }
    
    [tempFriendsConfirmed addObject:[userProfileData getUserName]];
    
    myFriends = tempFriendsConfirmed;

    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"response" equalTo:[NSNumber numberWithInt:0]];
    [query whereKey:@"userName" containedIn:myFriends];
    [query orderByDescending:@"createdAt"];
    chatData = [query findObjects];
    
    if ([chatData count] > 0)
        noChats = FALSE;
    else
        noChats = TRUE;
    
    [chatTable reloadData];
    [chatTable scrollsToTop];
    
    PFQuery *fquery = [PFQuery queryWithClassName:@"Profile"];
    [fquery whereKey:@"username" containedIn:myFriends];
    [fquery orderByAscending:@"lastname"];
    fquery.limit = 1000;
    myFriends = [fquery findObjects];
    
    NSLog(@"Got %d chats", [chatData count]);
    
    /*
    __block int totalNumberOfEntries = 0;
    [query orderByAscending:@"createdAt"];
    NSLog(@"LLC2");
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSLog(@"LLC3");

            // The count request succeeded. Log the count
            NSLog(@"There are currently %d entries", number);
            totalNumberOfEntries = number;
            if (totalNumberOfEntries > [chatData count]) {
                NSLog(@"Retrieving data");
                int theLimit;
                if (totalNumberOfEntries-[chatData count] > MAX_ENTRIES_LOADED) {
                    theLimit = MAX_ENTRIES_LOADED;
                }
                else {
                    theLimit = totalNumberOfEntries-[chatData count];
                }
                query.limit = theLimit;
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved %d chats.", objects.count);
                        [chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        for (int ind = 0; ind < objects.count; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        [chatTable beginUpdates];
                        [chatTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                        [chatTable endUpdates];
                        [chatTable reloadData];
                        [chatTable scrollsToTop];
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
        } else {
            NSLog(@"LLC4");
            // The request failed, we'll keep the chatData count?
            number = [chatData count];
        }
    }];
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
