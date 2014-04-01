//
//  PicturesViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "PicturesViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface PicturesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FDTakeDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation PicturesViewController

@synthesize takeController;
@synthesize selectButton1, selectButton2, selectButton3;


#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    NSLog(@"cancel");
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        // cancelled, nothing happen
        return;
    }
    
    // obtain a human-readable option string
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"Nobody"])
    {
        shareMode = 0;
    } else if ([option isEqualToString:@"My Friends"])
    {
        shareMode = 1;
    } else if ([option isEqualToString:@"Everybody"])
    {
        shareMode = 2;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [[actionSheet layer] setBackgroundColor:[UIColor blackColor].CGColor];
}

- (void)uploadImage:(UIImage *)image
{
    userProfileData = [ProfileData sharedInstance];

    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Share Photo With"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"Nobody", @"My Friends", @"Everybody", nil];
    
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    
    CGSize oldSizeI = image.size;
    CGSize newSizeI;
    UIImage *newImage = image;
    if (oldSizeI.width > 77) {
        newSizeI.width = 77;
        newSizeI.height = oldSizeI.height / (oldSizeI.width/77);
        newImage = [self resizeImage:image newSize:newSizeI];
    }

    //UIImage *originalImage = image;
    //CGSize destinationSize = CGSizeMake(77.0, 77.0);
    //UIGraphicsBeginImageContext(destinationSize);
    //[originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    //UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();

    NSData *imageDataFull = UIImageJPEGRepresentation(image, 0.05f);
    NSData *imageDataSmall = UIImageJPEGRepresentation(newImage, 0.5f);
    
    PFFile *imageFileFull = [PFFile fileWithName:@"ImageFull.jpg" data:imageDataFull];
    PFFile *imageFileSmall = [PFFile fileWithName:@"ImageSmall.jpg" data:imageDataSmall];
    [imageFileFull save];
    [imageFileSmall save];

    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
    [userPhoto setObject:imageFileFull forKey:@"imageFileFull"];
    [userPhoto setObject:imageFileSmall forKey:@"imageFileSmall"];
    PFUser *user = [PFUser currentUser];
    [userPhoto setObject:user forKey:@"userLink"];
    [userPhoto setObject:[userProfileData getUserName] forKey:@"userName"];
    [userPhoto setObject:[NSNumber numberWithInt:shareMode] forKey:@"shareMode"];
    [userPhoto save];
}

- (IBAction)refresh:(id)sender
{
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
    
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];
}

- (void)downloadAllImages
{
    
    userProfileData = [ProfileData sharedInstance];

    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    if (filterType == 0) {
        [query whereKey:@"userLink" equalTo:user];
    } else if (filterType == 1) {
        PFQuery *friendQuery1 = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery1 whereKey:@"invitee" equalTo:[userProfileData getUserName]];
        PFQuery *friendQuery2 = [PFQuery queryWithClassName:@"Friends"];
        [friendQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
        friendQuery1.limit = 1000;
        friendQuery2.limit = 1000;
        NSArray *friendList1 = [friendQuery1 findObjects];
        NSArray *friendList2 = [friendQuery2 findObjects];
        [myFriends removeAllObjects];
        for (int i = 0; i < [friendList1 count]; i++) {
            NSString *username = [[friendList1 objectAtIndex:i] objectForKey:@"inviter"];
            [myFriends addObject:username];
        }
        for (int i = 0; i < [friendList2 count]; i++) {
            NSString *username = [[friendList2 objectAtIndex:i] objectForKey:@"invitee"];
            [myFriends addObject:username];
        }
        [query whereKey:@"userName" containedIn:myFriends];
        [query whereKey:@"shareMode" greaterThan:[NSNumber numberWithInt:0]];
    } else if (filterType == 2) {
        [query whereKey:@"shareMode" greaterThan:[NSNumber numberWithInt:1]];
    }
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [photosFound removeAllObjects];
            [photosFound addObjectsFromArray:objects];
            [thumbnails removeAllObjects];
            for (int i = 0; i < [photosFound count]; i++) {
                PFFile *myImageFile = [[photosFound objectAtIndex:i] objectForKey:@"imageFileSmall"];
                NSData *imageData = [myImageFile getData];
                UIImage *thisImage = [UIImage imageWithData:imageData];
                [thumbnails addObject:thisImage];
            }
            [self.collectionView reloadData];

        }
    }];
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    CGSize oldSizeI = photo.size;
    CGSize newSizeI;
    UIImage *smallImage = photo;
    if (oldSizeI.width > 640) {
        newSizeI.width = 640;
        newSizeI.height = oldSizeI.height / (oldSizeI.width/640);
        smallImage = [self resizeImage:photo newSize:newSizeI];
    }
    
    //UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    //[photo drawInRect: CGRectMake(0, 0, 640, 960)];
    //UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    
    [self uploadImage:smallImage];

    [self downloadAllImages];

    /*
    [imageButton setBackgroundImage:photo forState:UIControlStateNormal];
    addPhotoLabel.hidden = TRUE;
    profileImage = photo;
    
    CNVRSCropViewController *cropVC = [[CNVRSCropViewController alloc] initWithName:photo];
    [self.navigationController pushViewController:cropVC animated:YES];
    */
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
    HUD = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    
    photosFound = [[NSMutableArray alloc] init];
    thumbnails = [[NSMutableArray alloc] init];
    myFriends = [[NSMutableArray alloc] init];
    
    [selectButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectButton1 setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    [selectButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectButton2 setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    [selectButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectButton3 setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    
    selectButton1.selected = TRUE;
    selectButton2.selected = FALSE;
    selectButton3.selected = FALSE;
    
    filterType = 0;
    
    dateLabel = [[UILabel alloc] init];
    nameLabel = [[UILabel alloc] init];

    [self downloadAllImages];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [photosFound count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
    [currentView removeFromSuperview];
    [bgView removeFromSuperview];
    [nameLabel removeFromSuperview];
    [dateLabel removeFromSuperview];
    [downloadButton removeFromSuperview];
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFFile *myImageFile = [[photosFound objectAtIndex:indexPath.row] objectForKey:@"imageFileFull"];
    NSData *imageData = [myImageFile getData];
    UIImage *qImage = [UIImage imageWithData:imageData];
    
    currentView = [[UIImageView alloc] initWithImage:qImage];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    double width = qImage.size.width;
    double height = qImage.size.height;
    double framewidth = screenWidth;
    double frameheight = screenHeight;
    double width_ratio = width/framewidth;
    double new_height;
    double new_width;
    double xpos;
    double ypos;
    
    if ((height/width_ratio) > frameheight) {
        new_height = frameheight;
        double height_ratio = height/frameheight;
        new_width = width/height_ratio;
        ypos = 0.0;
        xpos = (framewidth-new_width)/2;
    } else {
        new_width = framewidth;
        new_height = height/width_ratio;
        xpos = 0.0;
        ypos = (frameheight - new_height)/2;
    }
    
    currentView.frame = CGRectMake(xpos, (frameheight - new_height)/2, new_width, new_height);
    
    currentView.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    UITapGestureRecognizer *pgr2 = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(handleTap:)];
    
    pgr.delegate = self;
    [currentView addGestureRecognizer:pgr];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIImage *bgImage = [UIImage imageNamed:@"BlackBG.png"];
    bgView = [[UIImageView alloc] initWithImage:bgImage];
    bgView.userInteractionEnabled = YES;
    
    bgView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width, keyWindow.frame.size.height);
    [bgView addGestureRecognizer:pgr2];
    
    //UILabel *nameLabel = [[UILabel alloc] init];
    NSString *userName = [[photosFound objectAtIndex:indexPath.row] objectForKey:@"userName"];
    nameLabel.text = [NSString stringWithFormat:@"Taken by: %@", userName];
    
    PFObject *object = [photosFound objectAtIndex:indexPath.row];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyy-MM-dd"];
    NSDate *createdAt = object.createdAt;
    NSDate *thisDate = [NSDate date];
    NSTimeInterval secondsBetween = [thisDate timeIntervalSinceDate:createdAt];
    NSInteger minutesPassed = secondsBetween/60;
    if (minutesPassed <= 0) minutesPassed = 1;
    
    NSString *dateString = @"";
    if (minutesPassed < 60) {
        if (minutesPassed == 1)
            dateString = [NSString stringWithFormat:@"%ld minute ago", (long)minutesPassed];
        else
            dateString = [NSString stringWithFormat:@"%ld minutes ago", (long)minutesPassed];
    } else {
        NSInteger hoursPassed = minutesPassed/60;
        if (hoursPassed <= 0) hoursPassed = 1;
        if (hoursPassed < 24) {
            if (hoursPassed == 1)
                dateString = [NSString stringWithFormat:@"%ld hour ago", (long)hoursPassed];
            else
                dateString = [NSString stringWithFormat:@"%ld hours ago", (long)hoursPassed];
        } else {
            NSInteger daysPassed = hoursPassed/24;
            if (daysPassed <= 0) daysPassed = 1;
            if (daysPassed < 7) {
                if (daysPassed == 1)
                    dateString = [NSString stringWithFormat:@"%ld day ago", (long)daysPassed];
                else
                    dateString = [NSString stringWithFormat:@"%ld days ago", (long)daysPassed];
            } else {
                NSInteger weeksPassed = daysPassed/7;
                if (weeksPassed <= 0) weeksPassed = 1;
                if (weeksPassed < 52) {
                    if (weeksPassed == 1)
                        dateString = [NSString stringWithFormat:@"%ld week ago", (long)weeksPassed];
                    else
                        dateString = [NSString stringWithFormat:@"%ld weeks ago", (long)weeksPassed];
                } else {
                    NSInteger yearsPassed = weeksPassed/52;
                    if (yearsPassed == 1)
                        dateString = [NSString stringWithFormat:@"%ld year ago", (long)yearsPassed];
                    else
                        dateString = [NSString stringWithFormat:@"%ld years ago", (long)yearsPassed];
                }
            }
        }
    }
    //UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(20.0, 40.0, 280.0, 20.0);
    nameLabel.frame = CGRectMake(20.0, 20.0, 280.0, 20.0);
    dateLabel.text = dateString;
    dateLabel.numberOfLines = 1;
    nameLabel.numberOfLines = 1;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    dateLabel.textColor = [UIColor whiteColor];
    nameLabel.textColor = [UIColor whiteColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.backgroundColor = [UIColor clearColor];
    nameLabel.backgroundColor = [UIColor clearColor];

    [keyWindow addSubview:bgView];
    [keyWindow addSubview:currentView];
    [keyWindow addSubview:nameLabel];
    [keyWindow addSubview:dateLabel];

    if (![userName isEqualToString:[userProfileData getUserName]]) {
        downloadButton = [[UIButton alloc] init];
        [downloadButton setBackgroundImage:[UIImage imageNamed:@"download2.png"] forState:UIControlStateNormal];
        downloadButton.frame = CGRectMake(280.0, 20.0, 30.0, 30.0);
        [downloadButton addTarget:self action:@selector(savePhoto:) forControlEvents:UIControlEventTouchUpInside];
        photoToSave = qImage;
        [keyWindow addSubview:downloadButton];
    }
}

- (void) savePhoto:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(photoToSave, nil, nil, nil);
    
    [[[UIAlertView alloc] initWithTitle:@"Image Saved"
                                message:@"The image has been saved to your photo roll."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    //ALAsset *asset = self.assets[indexPath.row];
    //cell.asset = asset;
    
    UIImageView *thisThumbNail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 77.0, 77.0)];
    thisThumbNail.contentMode = UIViewContentModeScaleAspectFill;
    [thisThumbNail setClipsToBounds:YES];
    thisThumbNail.image = [thumbnails objectAtIndex:indexPath.row];
    
    [cell addSubview:thisThumbNail];
    
    //cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImage *image = (UIImage *) [info objectForKey:
    //                              UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
        
        
        // Do something with the image
    }];
}

- (IBAction)takePhotoButtonTapped:(id)sender
{
    picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = @[(NSString *) kUTTypeImage];
    picker.allowsEditing = NO;
    
    self.takeController.imagePicker.allowsEditing = NO;
    [self.takeController takePhotoOrChooseFromLibrary];


/*
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO))
        return;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
 */
}

- (IBAction)myPhotoButtonTapped:(id)sender
{
    selectButton1.selected = TRUE;
    selectButton2.selected = FALSE;
    selectButton3.selected = FALSE;
    
    filterType = 0;
    [self downloadAllImages];
}

- (IBAction)friendsPhotoButtonTapped:(id)sender
{
    selectButton1.selected = FALSE;
    selectButton2.selected = TRUE;
    selectButton3.selected = FALSE;

    filterType = 1;
    [self downloadAllImages];
}

- (IBAction)allPhotoButtonTapped:(id)sender
{
    selectButton1.selected = FALSE;
    selectButton2.selected = FALSE;
    selectButton3.selected = TRUE;

    filterType = 2;
    [self downloadAllImages];
}

@end
