//
//  CustomPeopleCell.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 6/9/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "CustomPeopleCell.h"

@implementation CustomPeopleCell

@synthesize primaryLabel,secondaryLabel,dateLabel,myImageView,starImageView,starLabel,summaryLabel;


- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	
	frame= CGRectMake(boundsX+10 ,6, 35, 35);
	myImageView.frame = frame;
    
    frame = CGRectMake(boundsX+50, 21, 15, 15);
    starImageView.frame = frame;
	
	//frame= CGRectMake(boundsX+10 , 37, 80, 20);
	frame= CGRectMake(boundsX+50 , 5, 250, 20);
	primaryLabel.frame = frame;
	
	//frame= CGRectMake(boundsX+100 , 8, 180, 40);
	frame= CGRectMake(boundsX+10 , 38, 300, 100);
	secondaryLabel.frame = frame;
    
	frame= CGRectMake(boundsX+285 , 8, 25, 15);
	dateLabel.frame = frame;
    
	//frame= CGRectMake(boundsX+40 , 5, 35, 20);
    frame = CGRectMake(boundsX+50, 25, 300, 20);
	starLabel.frame = frame;
    
    frame = CGRectMake(boundsX+50, 70, 300, 20);
	summaryLabel.frame = frame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		primaryLabel = [[UILabel alloc]init];
        primaryLabel.textAlignment = NSTextAlignmentLeft;
		primaryLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0];
		primaryLabel.textColor = [UIColor blackColor];
        primaryLabel.numberOfLines = 1;
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = NSTextAlignmentLeft;
		secondaryLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
		secondaryLabel.textColor = [UIColor blackColor];
        secondaryLabel.numberOfLines = 0;
        dateLabel = [[UILabel alloc]init];
        dateLabel.textAlignment = NSTextAlignmentCenter;
		dateLabel.font = [UIFont fontWithName:@"Arial" size:10.0];
		dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.numberOfLines = 1;
        starLabel = [[UILabel alloc]init];
		starLabel.textAlignment = NSTextAlignmentLeft;
		starLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0];
		starLabel.textColor = [UIColor blackColor];
        starLabel.numberOfLines = 1;
        summaryLabel = [[UILabel alloc]init];
		summaryLabel.textAlignment = NSTextAlignmentCenter;
		starLabel.font = [UIFont fontWithName:@"Arial" size:10.0];
		starLabel.textColor = [UIColor blackColor];
        starLabel.numberOfLines = 1;
        
		myImageView = [[UIImageView alloc]init];
		//starImageView = [[UIImageView alloc]init];
		
		[self.contentView addSubview:primaryLabel];
		//[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:dateLabel];
		[self.contentView addSubview:starLabel];
		[self.contentView addSubview:myImageView];
		//[self.contentView addSubview:summaryLabel];
		//[self.contentView addSubview:starImageView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
