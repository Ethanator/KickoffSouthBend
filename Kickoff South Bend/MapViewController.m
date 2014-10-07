//
//  MapViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "MapViewController.h"
#import "UIColor+HEX.h"

#define METERS_PER_MILE 1609.344

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {

    if (IS_OS_8_OR_LATER) {
        authorizationStatus = [CLLocationManager authorizationStatus];
    }
    
    /*
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 41.698409;
    zoomLocation.longitude= -86.234061;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
    
    NSLog(@"Map Location Set");
     */

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    
    NSLog(@"Creating location manager");
    
    if (IS_OS_8_OR_LATER) {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    
        authorizationStatus = [CLLocationManager authorizationStatus];
    }
    
    //Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    if (IS_OS_8_OR_LATER) {
        // Ensure that you can view your own location in the map view.
        if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.mapView setShowsUserLocation:YES];
        }
    } else {
        [self.mapView setShowsUserLocation:YES];
    }
    
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    firstLaunch = YES;
    
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    //activityView.color = [UIColor colorWithHexString:@"5bc6e3"];
    activityView.color = [UIColor colorWithHexString:@"0c64e8"];
    activityView.center = self.view.center;
    [self.view addSubview: activityView];
    spinWheel = FALSE;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSLog(@"REGION DID CHANGE");
    
    //Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set your current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set your current center point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
}

-(void) queryGooglePlaces: (NSString *) googleType {
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist], googleType, kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    [activityView stopAnimating];
    spinWheel = FALSE;

    [self plotPositions:places];
}

- (IBAction)dineButtonPressed:(id)sender {
    self.title = @"Concessions";
    [self showConcessions];
/*
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"restaurant"];
*/
}

- (IBAction)shopButtonPressed:(id)sender {
/*
    self.title = @"Shopping";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"store"];
*/
    self.title = @"Dining";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"restaurant"];
}

- (IBAction)stayButtonPressed:(id)sender {
    self.title = @"Hotels";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"lodging"];
}

- (IBAction)friendsButtonPressed:(id)sender {
    self.title = @"Friends";
    //[self queryGooglePlaces:@"restaurant"];
    [self showFriends];
}

- (IBAction)eventsButtonPressed:(id)sender {
    self.title = @"Events";
    //[self queryGooglePlaces:@"restaurant"];
    [self showEvents];
}

- (IBAction)stadiumButtonPressed:(id)sender {
    self.title = @"Sports Facilities";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"stadium"];
    //[self showStadium];
}

- (IBAction)medicalButtonPressed:(id)sender {
    self.title = @"Medical Facilities";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"health"];
    //[self showMedical];
}

- (IBAction)meButtonPressed:(id)sender {
    self.title = @"My Location";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self showMe];
}

- (void)showMe {
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
    
        
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            if ([annotation isKindOfClass:[MapPoint class]]) {
                [_mapView removeAnnotation:annotation];
            }
        }
        
        self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;

    }

    [activityView stopAnimating];
    spinWheel = FALSE;
}

- (void)showFriends {
    [activityView startAnimating];
    spinWheel = TRUE;

    userProfileData = [ProfileData sharedInstance];

    NSArray *myFriendsNames = [userProfileData getFriendList];
    
    if ([myFriendsNames count] == 0) {
        
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
        
        NSMutableArray *tempFriendsConfirmed2 = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [tempFriendsConfirmed count]; j++) {
            if ([tempFriendsConfirmed2 containsObject:[tempFriendsConfirmed objectAtIndex:j]]) {
                PFQuery *tempQuery = [PFQuery queryWithClassName:@"Friends"];
                [tempQuery whereKey:@"inviter" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                [tempQuery whereKey:@"invitee" equalTo:[userProfileData getUserName]];
                PFObject *tempObject = [tempQuery getFirstObject];
                if (tempObject == nil) {
                    PFQuery *tempQuery2 = [PFQuery queryWithClassName:@"Friends"];
                    [tempQuery2 whereKey:@"invitee" equalTo:[tempFriendsConfirmed objectAtIndex:j]];
                    [tempQuery2 whereKey:@"inviter" equalTo:[userProfileData getUserName]];
                    PFObject *tempObject2 = [tempQuery2 getFirstObject];
                    if (tempObject2 != nil) {
                        [tempObject2 delete];
                    }
                } else {
                    [tempObject delete];
                }
            } else {
                [tempFriendsConfirmed2 addObject:[tempFriendsConfirmed objectAtIndex:j]];
            }
        }
        
        [userProfileData setFriendList:(NSArray *)tempFriendsConfirmed2];
    }
    
    myFriendsNames = [userProfileData getFriendList];
    
    NSLog(@"Have %ld FRIENDS", [myFriendsNames count]);

    PFQuery *fquery1 = [PFQuery queryWithClassName:@"Profile"];
    [fquery1 whereKey:@"username" containedIn:myFriendsNames];
    [fquery1 whereKey:@"attendNextGame" equalTo:[NSNumber numberWithBool:TRUE]];
    [fquery1 whereKey:@"trackingAllowed" equalTo:[NSNumber numberWithBool:TRUE]];
    [fquery1 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    NSArray *myFriends = [fquery1 findObjects];
    int numFriends = (int)[myFriends count];
    
    NSLog(@"FOUND %d TRACKABLE FRIENDS", numFriends);
    
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }

    for (int i = 0; i < numFriends; i++) {
        PFObject *friendObject = [myFriends objectAtIndex:i];
        PFGeoPoint *geoPoint = [friendObject objectForKey:@"location"];
        if (geoPoint != nil) {
            
            NSLog(@"GOT LOCATION FOR FRIEND %d (%@)", i, [friendObject objectForKey:@"username"]);
            
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = geoPoint.latitude;
            ctrpoint.longitude = geoPoint.longitude;
            
            NSString *firstname = [friendObject objectForKey:@"firstname"];
            NSString *lastname = [friendObject objectForKey:@"lastname"];
            NSString *username = [friendObject objectForKey:@"username"];
            NSString *fullName;
            if (([firstname length] > 0) && ([lastname length] > 0))
                fullName = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
            else if ([lastname length] > 0)
                fullName = [NSString stringWithFormat:@"%@", lastname];
            else
                fullName = [NSString stringWithFormat:@"%@", username];
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:fullName address:@"" coordinate:ctrpoint];
            
            [_mapView addAnnotation:placeObject];
            
            //AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
            //[mapview addAnnotation:addAnnotation];
        }
    }
    
    [activityView stopAnimating];
    spinWheel = FALSE;
}

- (void)showConcessions {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }
    
    //NSDate *nowDate = [NSDate date];
    PFQuery *eQuery = [PFQuery queryWithClassName:@"Concessions"];
    //[eQuery whereKey:@"EndTime" greaterThan:nowDate];
    eQuery.limit = 1000;
    NSArray *allEvents = [eQuery findObjects];
    int numEvents = (int)[allEvents count];
    
    for (int i = 0; i < numEvents; i++) {
        PFObject *eventObject = [allEvents objectAtIndex:i];
        PFGeoPoint *geoPoint = [eventObject objectForKey:@"Location"];
        if (geoPoint != nil) {
            
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = geoPoint.latitude;
            ctrpoint.longitude = geoPoint.longitude;
            
            NSString *title = [eventObject objectForKey:@"Organizer"];
            NSString *location = [eventObject objectForKey:@"Description"];
            //NSDate *startDate = [eventObject objectForKey:@"StartTime"];
            
            //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //[dateFormat setDateFormat:@"EEE HH:mma"];
            //NSString *dateString = [dateFormat stringFromDate:startDate];
            
            //NSString *subTitle = [NSString stringWithFormat:@"%@ (%@)", location, dateString];
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:title address:location coordinate:ctrpoint];
            
            [_mapView addAnnotation:placeObject];
            
            //AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
            //[mapview addAnnotation:addAnnotation];
        }
    }
}

- (void)showEvents {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }

    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    NSInteger seconds = [tz secondsFromGMTForDate:[NSDate date]];
    NSDate *nowDate = [NSDate date];
    NSDate *adjustedDate = [nowDate dateByAddingTimeInterval:seconds];
    NSTimeInterval adjustmentSeconds = -60*60*3; // 3 hours tolerance
    NSDate *dateAhead = [adjustedDate dateByAddingTimeInterval:adjustmentSeconds];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"EndTime" greaterThan:dateAhead];
    query.limit = 1000;
    NSArray *allEvents = [query findObjects];
    int numEvents = (int)[allEvents count];

    for (int i = 0; i < numEvents; i++) {
        PFObject *eventObject = [allEvents objectAtIndex:i];
        PFGeoPoint *geoPoint = [eventObject objectForKey:@"Location"];
        if (geoPoint != nil) {
            
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = geoPoint.latitude;
            ctrpoint.longitude = geoPoint.longitude;
            
            NSString *title = [eventObject objectForKey:@"Title"];
            NSString *location = [eventObject objectForKey:@"LocationName"];
            NSDate *startDate = [eventObject objectForKey:@"StartTime"];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEE HH:mma"];
            NSString *dateString = [dateFormat stringFromDate:startDate];
            
            NSString *subTitle = [NSString stringWithFormat:@"%@ (%@)", location, dateString];
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:title address:subTitle coordinate:ctrpoint];
            
            [_mapView addAnnotation:placeObject];
            
            //AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
            //[mapview addAnnotation:addAnnotation];
        }
    }

    
}

-(void)plotPositions:(NSArray *)data {
    // 1 - Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }
    // 2 - Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        // Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        // 5 - Create a new annotation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [_mapView addAnnotation:placeObject];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
    return nil;
}

#pragma mark - MKMapViewDelegate methods.
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    
    MKCoordinateRegion region;
    CLLocationCoordinate2D zoomLocation;
    CLLocationCoordinate2D centre = [mv centerCoordinate];

    zoomLocation.latitude = 41.698409;
    zoomLocation.longitude= -86.234061;

    if (firstLaunch) {
        //region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
        region = MKCoordinateRegionMakeWithDistance(zoomLocation, 2000, 2000);
        firstLaunch = false;
    } else {
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    
    [mv setRegion:region animated:YES];
    
}

@end
