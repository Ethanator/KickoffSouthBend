//
//  CustomPeopleCell.h
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/9/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPeopleCell : UITableViewCell {
	UILabel *primaryLabel;
	UILabel *secondaryLabel;
	UILabel *dateLabel;
    UILabel *starLabel;
	UIImageView *myImageView;
	UIImageView *starImageView;
    UILabel *summaryLabel;
}

@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *secondaryLabel;
@property(nonatomic,retain)UILabel *dateLabel;
@property(nonatomic,retain)UILabel *starLabel;
@property(nonatomic,retain)UILabel *summaryLabel;
@property(nonatomic,retain)UIImageView *myImageView;
@property(nonatomic,retain)UIImageView *starImageView;

@end
