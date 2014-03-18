//
//  AppDelegate.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/5/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ProfileData *userProfileData; // Used for quick access to this user's profile info anywhere in app (ProfileData.h/m}
}

@property (strong, nonatomic) UIWindow *window;

@end
