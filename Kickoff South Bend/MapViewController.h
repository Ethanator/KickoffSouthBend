//
//  MapViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/7/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"

#define kGOOGLE_API_KEY @"AIzaSyCajOs_0xjgDyvSxPaug2NdGfUpAFs5qNQ"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
    UIActivityIndicatorView *activityView;
    BOOL spinWheel;
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
    
@end
