//
//  MyProfileViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/26/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "MyProfileViewController.h"

@interface MyProfileViewController () <FDTakeDelegate,UITextFieldDelegate>

@end

@implementation MyProfileViewController

@synthesize firstName, lastName, email, gradYear, affiliation, imageButton, ndStudent, ndGrad;
@synthesize myPFObject;
@synthesize profileImage;
@synthesize addPhotoLabel;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard {
    [firstName resignFirstResponder];
    [lastName resignFirstResponder];
    [affiliation resignFirstResponder];
    [email resignFirstResponder];
    [gradYear resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    if ([firstName isFirstResponder]) {
        //CGPoint screenOrigin = [firstName convertPoint:firstName.bounds.origin toView:nil];
        //if (screenOrigin.y > 300.0f)
        //    offset = screenOrigin.y - 300.0f;
        //else if (screenOrigin.y < 80.0)
        //    offset = 0.0f;
        offset = 130.0f;
    }
    if ([lastName isFirstResponder]) {
        offset = 130.0f;
    }
    if ([email isFirstResponder]) {
        offset = 130.0f;
    }
    if ([affiliation isFirstResponder]) {
        offset = 130.0f;
    }
    if ([gradYear isFirstResponder]) {
        offset = 130.0f;
    }
    
    if(self.view.frame.origin.y >= 0)
        [self setViewMovedUp:YES];
    
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if(self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        
        rect.origin.y -= offset;
        rect.size.height += offset;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += offset;
        rect.size.height -= offset;
        offset = 0.0f;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CNVRS" message:@"Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alertView show];
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
    [[imageButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [imageButton setImage:photo forState:UIControlStateNormal];
    addPhotoLabel.hidden = TRUE;
    profileImage = photo;
    
    CGSize newSizeI;
    newSizeI.width = 120;
    newSizeI.height = 120;
    UIImage *newImage = [self resizeImage:profileImage newSize:newSizeI];;
    
    NSData *data = UIImageJPEGRepresentation(newImage, 0.0);
    PFFile *file = [PFFile fileWithName:@"snapshot.jpg" data:data];
    [file save];
    [myPFObject setObject:file forKey:@"profileimage"];
    [myPFObject save];
}

-(IBAction)saveProfile:(id)sender
{
    userProfileData = [ProfileData sharedInstance];
    
    [userProfileData setProfileUpdated:TRUE];
    
    PFObject *object = myPFObject;
    
    if (object == nil) {
        return;
    }
    
    NSString *myFirstname = firstName.text;
    NSString *myLastname = lastName.text;
    NSString *myEmailAddress = email.text;
    NSString *myAffiliation = affiliation.text;
    NSString *year = gradYear.text;
    BOOL isndgrad = ndGrad.on;
    BOOL isstudent = ndStudent.on;
    
    if (myFirstname.length) {
        [object setObject:firstName.text forKey:@"firstname"];
        [object setObject:[firstName.text lowercaseString] forKey:@"firstname_lower"];
    }
    if (myLastname.length) {
        [object setObject:lastName.text forKey:@"lastname"];
        [object setObject:[lastName.text lowercaseString] forKey:@"lastname_lower"];
    }
    if (myEmailAddress.length) {
        [object setObject:email.text forKey:@"emailAddress"];
    }
    if (myAffiliation.length) {
        [object setObject:affiliation.text forKey:@"affiliation"];
    }
    [object setObject:year forKey:@"year"];
    if (isndgrad) {
        [object setObject:[NSNumber numberWithBool:TRUE] forKey:@"ndgrad"];
    } else {
        [object setObject:[NSNumber numberWithBool:FALSE] forKey:@"ndgrad"];
    }
    if (isstudent) {
        [object setObject:[NSNumber numberWithBool:TRUE] forKey:@"ndstudent"];
    } else {
        [object setObject:[NSNumber numberWithBool:FALSE] forKey:@"ndstudent"];
    }
    
    /*
    NSData *data = UIImageJPEGRepresentation(profileImage, 0.0);
    PFFile *file = [PFFile fileWithName:@"snapshot.jpg" data:data];
    
    [file save];
    
    [object setObject:file forKey:@"profileimage"];
    */
    
    [object save];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Profile"
                                                      message:@"Profile information has been updated!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)chooseImage:(id)sender
{
    picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = @[(NSString *) kUTTypeImage];
    picker.allowsEditing = NO;
    
    self.takeController.imagePicker.allowsEditing = NO;
    [self.takeController takePhotoOrChooseFromLibrary];

}

 -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
 {
     UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
     profileImage = pickedImage;
 
     [imageButton setBackgroundImage:pickedImage forState:UIControlStateNormal];
 
     [self dismissViewControllerAnimated:YES completion:nil];
 }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    offset = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    userProfileData = [ProfileData sharedInstance];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Profile"];
    [query whereKey:@"username" equalTo:[userProfileData getUserName]];
    myPFObject = [query getFirstObject];
    [userProfileData setOwnObject:myPFObject];
        
    if ([myPFObject objectForKey:@"profileimage"] == nil)
    {
        [[imageButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [imageButton setImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
        profileImage = [UIImage imageNamed:@"profile_placeholder.png"];
    } else
    {
        PFFile *myImageFile = [[userProfileData getOwnObject] objectForKey:@"profileimage"];
        NSData *imageData = [myImageFile getData];
        
        [[imageButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [imageButton setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        addPhotoLabel.hidden = TRUE;
    }
        
    NSString *myFirstName = [[userProfileData getOwnObject] objectForKey:@"firstname"];
    NSString *myLastName = [[userProfileData getOwnObject] objectForKey:@"lastname"];
    NSString *myEmail = [[userProfileData getOwnObject] objectForKey:@"emailAddress"];
    NSString *myAffiliation = [[userProfileData getOwnObject] objectForKey:@"affiliation"];
    NSString *myYear = [[userProfileData getOwnObject] objectForKey:@"year"];
    BOOL graduate = [[userProfileData getOwnObject] objectForKey:@"ndgrad"];
    BOOL student = [[userProfileData getOwnObject] objectForKey:@"ndstudent"];
    
    firstName.text = myFirstName;
    lastName.text = myLastName;
    email.text = myEmail;
    affiliation.text = myAffiliation;
    gradYear.text = myYear;
    ndGrad.on = graduate;
    ndStudent.on = student;
    
    [firstName setDelegate:self];
    [lastName setDelegate:self];
    [email setDelegate:self];
    [affiliation setDelegate:self];
    [gradYear setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
