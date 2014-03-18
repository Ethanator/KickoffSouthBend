//
//  MyProfileViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/26/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ProfileData.h"
#import "FDTakeController.h"

@interface MyProfileViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate> {
    IBOutlet UITextField *firstName;
    IBOutlet UITextField *lastName;
    IBOutlet UITextField *email;
    IBOutlet UITextField *affiliation;
    IBOutlet UITextField *gradYear;
    IBOutlet UISwitch *ndGrad;
    IBOutlet UISwitch *ndStudent;
    IBOutlet UILabel *addPhotoLabel;
    PFObject *myPFObject;
    UIImagePickerController *picker;
    UIImage *profileImage;
    ProfileData *userProfileData;
    float offset;
}

@property(nonatomic,retain) IBOutlet UITextField *firstName;
@property(nonatomic,retain) IBOutlet UITextField *lastName;
@property(nonatomic,retain) IBOutlet UITextField *email;
@property(nonatomic,retain) IBOutlet UITextField *affiliation;
@property(nonatomic,retain) IBOutlet UITextField *gradYear;
@property(nonatomic,retain) IBOutlet UIButton *imageButton;
@property(nonatomic,retain) IBOutlet UISwitch *ndGrad;
@property(nonatomic,retain) IBOutlet UISwitch *ndStudent;
@property(nonatomic,retain) PFObject *myPFObject;
@property(nonatomic,retain) UIImage *profileImage;
@property(nonatomic,retain) UILabel *addPhotoLabel;
@property FDTakeController *takeController;

-(IBAction)saveProfile:(id)sender;
-(IBAction)chooseImage:(id)sender;

-(void)cancel;


@end
