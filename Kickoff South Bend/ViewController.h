//
//  ViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/5/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileData.h"
#import<MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate> {
    NSInteger gameReceived;
    UILabel *gameLabel;
    UILabel *countDownLabel;
    PFObject *gameObject;
    ProfileData *userProfileData;
    UIButton *goBtn;
    UIButton *trackBtn;
    //CLLocationManager *locationManager;
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
