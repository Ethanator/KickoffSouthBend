//
//  ParkMapViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 8/12/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import "ParkMapViewController.h"

@interface ParkMapViewController ()

@end

@implementation ParkMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    //activityView.color = [UIColor colorWithHexString:@"5bc6e3"];
    activityView.color = [UIColor colorWithHexString:@"0c64e8"];
    activityView.center = self.view.center;
    [self.view addSubview: activityView];
    spinWheel = TRUE;
    [activityView startAnimating];
    
    NSString *fullURL = @"http://ndsp.nd.edu/assets/138045/parking_map.pdf";
    //NSString *fullURL = @"http://www.cnn.com";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_parkingView loadRequest:requestObj];
    
    spinWheel = false;
    [activityView stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
