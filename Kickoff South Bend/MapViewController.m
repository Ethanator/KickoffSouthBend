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
    
    //Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    firstLaunch=YES;
    
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
    self.title = @"Dining";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"restaurant"];
}

- (IBAction)shopButtonPressed:(id)sender {
    self.title = @"Shopping";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"store"];
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
    self.title = @"Stadium";
    [activityView startAnimating];
    spinWheel = TRUE;
    [self queryGooglePlaces:@"stadium"];
    //[self showStadium];
}

- (IBAction)medicalButtonPressed:(id)sender {
    self.title = @"Medical";
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
    self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
    [activityView stopAnimating];
    spinWheel = FALSE;
}

- (void)showFriends {
    [activityView startAnimating];
    spinWheel = TRUE;

    userProfileData = [ProfileData sharedInstance];

    NSArray *myFriendsNames = [userProfileData getFriendList];
    
    PFQuery *fquery1 = [PFQuery queryWithClassName:@"Profile"];
    [fquery1 whereKey:@"username" containedIn:myFriendsNames];
    [fquery1 whereKey:@"attendNextGame" equalTo:[NSNumber numberWithBool:TRUE]];
    [fquery1 whereKey:@"trackingAllowed" equalTo:[NSNumber numberWithBool:TRUE]];
    [fquery1 orderByAscending:@"lastname"];
    fquery1.limit = 1000;
    NSArray *myFriends = [fquery1 findObjects];
    int numFriends = (int)[myFriends count];
    
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [_mapView removeAnnotation:annotation];
        }
    }

    for (int i = 0; i < numFriends; i++) {
        PFObject *friendObject = [myFriends objectAtIndex:i];
        PFGeoPoint *geoPoint = [friendObject objectForKey:@"location"];
        if (geoPoint != nil) {
            
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = geoPoint.latitude;
            ctrpoint.longitude = geoPoint.longitude;
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:[friendObject objectForKey:@"username"] address:@"" coordinate:ctrpoint];
            
            [_mapView addAnnotation:placeObject];
            
            //AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
            //[mapview addAnnotation:addAnnotation];
        }
    }
    
    [activityView stopAnimating];
    spinWheel = FALSE;
}

- (void)showEvents {
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
    } else {
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    
    [mv setRegion:region animated:YES];
    
}

@end
