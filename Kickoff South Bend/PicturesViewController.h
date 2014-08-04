//
//  PicturesViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FDTakeController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "ProfileData.h"

@interface PicturesViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate,UIActionSheetDelegate> {
    
    UIImagePickerController *picker;
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
    NSMutableArray *imageDataArray;
    NSMutableArray *allImages;
    ProfileData *userProfileData;
    NSMutableArray *photosFound;
    NSMutableArray *thumbnails;
    NSMutableArray *myFriends;
    IBOutlet UIButton *selectButton1;
    IBOutlet UIButton *selectButton2;
    IBOutlet UIButton *selectButton3;
    UIImageView *bgView;
    UIImageView *currentView;
    int filterType; // 0 = my pictures; 1 = friends' pictures; 2 = all pictures
    UILabel *nameLabel;
    UILabel *dateLabel;
    int shareMode;
    UIImage *photoToSave;
    UIButton *downloadButton;
    UIActivityIndicatorView *activityView;
    BOOL spinWheel;
    
}

@property FDTakeController *takeController;
@property (nonatomic,retain) IBOutlet UIButton *selectButton1;
@property (nonatomic,retain) IBOutlet UIButton *selectButton2;
@property (nonatomic,retain) IBOutlet UIButton *selectButton3;

- (IBAction)refresh:(id)sender;
- (void)uploadImage:(UIImage *)image;
//- (void)setUpImages:(NSArray *)images;

@end

