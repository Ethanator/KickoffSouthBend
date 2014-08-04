//
//  ProfileData.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "ProfileData.h"

@implementation ProfileData

static ProfileData *sharedInstance = nil;



- (id) init
{
    self = [super init];
    if (self)
    {
        userName = [NSString string];
        emailAddress = [NSString string];
        contactAddress = [NSString string];
        phoneNumber1 = [NSString string];
        phoneNumber2 = [NSString string];
        profileActive = 0;
    }
    return self;
}

+ (ProfileData *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[ProfileData alloc] init];
        }
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

- (void) setLocationTracking:(BOOL)locTracking
{
    locationTracking = locTracking;
}

- (BOOL) getLocationTracking
{
    return locationTracking;
}

- (void) setLocationMgr:(CLLocationManager *)locationManager
{
    locationMgr = locationManager;
}

- (CLLocationManager *) getLocationMgr
{
    return locationMgr;
}

- (void) setFriendList:(NSArray *)newfriendList
{
    friendList = newfriendList;
}

- (NSArray *) getFriendList
{
    return friendList;
}

- (NSString *) getUserName
{
    return userName;
}

- (void) setUserName:(NSString *)newVal
{
    userName = [newVal copy];
}

- (NSString *) getEmailAddress
{
    return emailAddress;
}

- (void) setEmailAddress:(NSString *)newVal
{
    emailAddress = [newVal copy];
}

- (NSString *) getContactAddress
{
    return contactAddress;
}

- (void) setContactAddress:(NSString *)newVal
{
    contactAddress = [newVal copy];
}

- (NSString *) getPhoneNumber1
{
    return phoneNumber1;
}

- (void) setPhoneNumber1:(NSString *)newVal
{
    phoneNumber1 = [newVal copy];
}

- (NSString *) getPhoneNumber2
{
    return phoneNumber2;
}

- (void) setPhoneNumber2:(NSString *)newVal
{
    phoneNumber2 = [newVal copy];
}

- (NSInteger) getProfileActive
{
    return profileActive;
}

- (void) setProfileActive:(NSInteger)newVal
{
    profileActive = newVal;
}

- (PFObject *) getOwnObject
{
    return ownObject;
}

- (void) setOwnObject:(PFObject *)newVal
{
    ownObject = newVal;
}

- (void) setProfileUpdated: (BOOL)newVal
{
    profileUpdated = newVal;
}

- (BOOL) getProfileUpdated
{
    return profileUpdated;
}

@end
