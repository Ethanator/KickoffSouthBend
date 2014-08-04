//
//  ProfileData.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ProfileData : NSObject {
    NSInteger profileActive;
    NSString *userName;
    NSString *emailAddress;
    NSString *contactAddress;
    NSString *phoneNumber1;
    NSString *phoneNumber2;
    PFObject *ownObject;
    NSArray *friendList;
    BOOL profileUpdated;
    BOOL locationTracking;
    CLLocationManager *locationMgr;
}

+ (ProfileData *)sharedInstance;

- (void) setLocationTracking:(BOOL)locTracking;
- (BOOL) getLocationTracking;
- (void) setLocationMgr:(CLLocationManager *)locationManager;
- (CLLocationManager *) getLocationMgr;
- (void) setFriendList:(NSArray *)newfriendList;
- (NSArray *) getFriendList;
- (void) setUserName:(NSString *)newVal;
- (NSString *) getUserName;
- (void) setEmailAddress:(NSString *)newVal;
- (NSString *) getEmailAddress;
- (void) setContactAddress:(NSString *)newVal;
- (NSString *) getContactAddress;
- (void) setPhoneNumber1:(NSString *)newVal;
- (NSString *) getPhoneNumber1;
- (void) setPhoneNumber2:(NSString *)newVal;
- (NSString *) getPhoneNumber2;
- (void) setProfileActive:(NSInteger)newVal;
- (NSInteger) getProfileActive;
- (void) setOwnObject: (PFObject *)newVal;
- (PFObject *) getOwnObject;
- (void) setProfileUpdated: (BOOL)newVal;
- (BOOL) getProfileUpdated;

@end
