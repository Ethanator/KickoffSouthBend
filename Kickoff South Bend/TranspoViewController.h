//
//  TranspoViewController.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 8/12/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HEX.h"

@interface TranspoViewController : UIViewController {
    
    UIActivityIndicatorView *activityView;
    BOOL spinWheel;

}

@property(strong, nonatomic) IBOutlet UIWebView *parkingView;

@end
