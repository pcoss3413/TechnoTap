//
//  UIScoreCell.h
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScoreCell : UITableViewCell {
    UILabel *lblRank;
    UILabel *lblName;
    UIImageView *imgFlag;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier parentWidth:(CGFloat)width;
-(void)setScore:(NSArray*)score;
-(void)setRank:(NSUInteger)rank;

@end
