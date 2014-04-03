//
//  ChatCell.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 4/3/14.
//  Copyright (c) 2014 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell {
    
    IBOutlet UILabel *userLabel;
    IBOutlet UITextView *textString;
    IBOutlet UILabel *timeLabel;
    
}

@property (nonatomic,retain) IBOutlet UILabel *userLabel;
@property (nonatomic,retain) IBOutlet UITextView *textString;
@property (nonatomic,retain) IBOutlet UILabel *timeLabel;

@end