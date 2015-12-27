//
//  UIScoreCell.m
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "UIScoreCell.h"

@implementation UIScoreCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier parentWidth:(CGFloat)width{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        width = MIN([[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height) - 30.f;
        
        lblRank = [[UILabel alloc] initWithFrame:CGRectMake(3.0f, 0.0f, 35.f, 35.f)];
        [lblRank setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:14.f]];
        [lblRank setTextAlignment:NSTextAlignmentCenter];
        lblRank.backgroundColor = [UIColor clearColor];
        [lblRank setTextColor:[UIColor redColor]];
        [self addSubview:lblRank];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(37.f, 0, width - 37.f - 64.f, 35.f)];
        [lblName setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:18.f]];
        [lblName setAdjustsFontSizeToFitWidth:YES];
        [lblName setTextAlignment:NSTextAlignmentCenter];
        lblName.backgroundColor = [UIColor clearColor];
        [lblName setTextColor:[UIColor blackColor]];
        [self addSubview:lblName];
        
        imgFlag = [[UIImageView alloc] initWithFrame:CGRectMake(width - 64.f, 0.f, 64.f, 35.f)];
        [imgFlag setContentMode:UIViewContentModeScaleAspectFit];
        [imgFlag setBackgroundColor:[UIColor clearColor]];
        [self addSubview:imgFlag];
    }
    
    return self;
}


-(void)setRank:(NSUInteger)rank{
    [lblRank setText:[NSString stringWithFormat:@"%lu.", (unsigned long)rank]];
}

-(void)setScore:(NSArray*)score{
    
    if (score.count > 2 && score[0] && score[1]){
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Images/flags/%@.png", score[1]]];
        [imgFlag setImage:image]; //Image may be nil
        
        if ([score[0] isEqualToString:@"<super secret username here!>"]) {
            [lblName setText:[NSString stringWithFormat:@"Game Maker: %@", score[2]]];          //Here I detect the presence of my own score using a custom version
            [lblName setTextColor:[UIColor redColor]];                                          //That allows this username, marking my own scores in red. Use with caution...
        }
        else{
            [lblName setText:[NSString stringWithFormat:@"%@: %@", score[0], score[2]]];
            [lblName setTextColor:[UIColor blackColor]];
        }
    }
    else{
        [imgFlag setImage:nil];
        [lblName setText:@""];
    }
    
}


@end
