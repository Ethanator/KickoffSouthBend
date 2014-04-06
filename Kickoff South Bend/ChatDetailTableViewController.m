//
//  ChatDetailTableViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/4/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import "ChatDetailTableViewController.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 25


@interface ChatDetailTableViewController () <UITableViewDelegate, UITableViewDataSource,PF_EGORefreshTableHeaderDelegate>

@end

@implementation ChatDetailTableViewController

@synthesize tfEntry;
@synthesize chatTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    userProfileData = [ProfileData sharedInstance];
    
    userName = [userProfileData getUserName];
    
    chatData  = [[NSArray alloc] init];
    [self loadLocalChat];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [chatTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    chatTable.opaque = NO;
    chatTable.backgroundView = nil;
    backgroundText.hidden = TRUE;

    textFieldActive = FALSE;
    
    tfEntry.delegate = self;
    tfEntry.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfEntry.hidden = TRUE;

    noChats = TRUE;
    
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
    
    userProfileData = [ProfileData sharedInstance];

    if (tfEntry.text.length > 0) {
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
        [newMessage setObject:[userProfileData getUserName] forKey:@"userName"];
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage setObject:[NSNumber numberWithInt:1] forKey:@"response"];
        [newMessage setObject:[NSNumber numberWithInt:0] forKey:@"responses"];
        [newMessage setObject:chatObject.objectId forKey:@"parentID"];
        [newMessage save];
        NSLog(@"So far so good 2");
        
        [chatObject incrementKey:@"responses" byAmount:[NSNumber numberWithInt:1]];
        [chatObject save];
        
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideKeyBoard {
    NSLog(@"dismiss");
    [tfEntry resignFirstResponder];
}


- (void)loadLocalChat
{
  
    userProfileData = [ProfileData sharedInstance];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"response" equalTo:[NSNumber numberWithInt:1]];
    [query whereKey:@"parentID" equalTo:chatObject.objectId];
    [query orderByDescending:@"createdAt"];
    query.limit = 1000;
    chatData = [query findObjects];

    if ([chatData count] > 0)
        noChats = FALSE;
    else
        noChats = TRUE;
    
    [chatTable reloadData];
    [chatTable scrollsToTop];
    
    NSMutableArray *friendNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < [chatData count]; i++) {
        [friendNames addObject:[[chatData objectAtIndex:i] objectForKey:@"userName"]];
    }
    
    PFQuery *fquery = [PFQuery queryWithClassName:@"Profile"];
    [fquery whereKey:@"username" containedIn:friendNames];
    [fquery orderByAscending:@"lastname"];
    fquery.limit = 1000;
    myFriends = [fquery findObjects];
}

- (IBAction)newChat
{
    [tfEntry becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else
        return [chatData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    for(UIView* subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];

    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
    
        UILabel *responseHeader = [[UILabel alloc] init];
        responseHeader.text = @"Responses:";
        responseHeader.textColor = [UIColor blackColor];
        responseHeader.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        responseHeader.frame = CGRectMake(10.0, 3.0, 200.0, 20.0);
        [cell addSubview:responseHeader];
        cell.backgroundColor = [UIColor lightGrayColor];
        
        return cell;
        
    } else {
    
        if ([chatData count] == 0) {
            UILabel *responseHeader = [[UILabel alloc] init];
            responseHeader.text = @"No responses yet";
            responseHeader.textColor = [UIColor whiteColor];
            responseHeader.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
            responseHeader.frame = CGRectMake(10.0, 20.0, 300.0, 20.0);
            responseHeader.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:responseHeader];
            return cell;
        }
        chatObject = [chatData objectAtIndex:indexPath.row];
        NSString *thisName = [chatObject objectForKey:@"userName"];
        NSString *currentName;
        for (int i = 0; i < [myFriends count]; i++) {
            currentName = [[myFriends objectAtIndex:i] objectForKey:@"username"];
            if ([currentName isEqualToString:thisName]) {
                thisObject = [myFriends objectAtIndex:i];
                break;
            }
        }
    }

    NSString *currentUserName = [chatObject objectForKey:@"userName"];
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
    nameLabel.frame = CGRectMake(45.0, 7.0, 150.0, 15.0);
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
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
    CGSize size = [self frameForText:chatText sizeWithFont:font constrainedToSize:CGSizeMake(260.0f, 1000.0f)];
    
    //UITextView *textString = [[UITextView alloc] init];
    UILabel *textString = [[UILabel alloc] init];
    textString.frame = CGRectMake(45, 25, size.width + 30, size.height + 20);
    textString.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
    textString.text = chatText;
    textString.numberOfLines = 0;
    textString.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:204/255 alpha:1.0];
    //textString.textColor = [UIColor whiteColor];
    textString.backgroundColor = [UIColor clearColor];
    //textString.editable = NO;
    [textString sizeToFit];
    [cell addSubview:textString];
    
    for(UIView * cellSubviews in [cell.contentView subviews])
    {
        cellSubviews.userInteractionEnabled = NO;
    }

    cell.userInteractionEnabled = NO;
    
    return cell;
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *cellText;
    
    if (indexPath.section == 0)
        cellText = [chatObject objectForKey:@"text"];
    else if (indexPath.section == 1)
        return 25.0;
    else
        cellText = @"...";
    UIFont *cellFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
    CGSize constraintSize = CGSizeMake(260.0f, MAXFLOAT);
    CGSize labelSize = [self frameForText:cellText sizeWithFont:cellFont constrainedToSize:constraintSize];
    
    return labelSize.height + 40;
}

- (void)setChatObject:(PFObject *)thisChatObject
{
    chatObject = thisChatObject;
}

- (void)setAskerObject:(PFObject *)thisAskerObject
{
    thisObject = thisAskerObject;
}

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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
