//
//  UIHeart.m
//  ColorTap
//
//  Created by Patrick Cossette on 5/2/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "UIHeart.h"

@implementation UIHeart

-(id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        
        [self setImage:[UIImage imageNamed:@"Images/heart_empty.png"]];
        
        imgHeart = [[UIImageView alloc] initWithFrame:self.bounds];
        imgHeart.backgroundColor = [UIColor clearColor];
        [imgHeart setImage:[UIImage imageNamed:@"Images/heart_full.png"]];
        [self addSubview:imgHeart];
    }
    
    return self;
}

-(void)setFilled:(BOOL)filled animated:(BOOL)animated completion:(void (^)())completion{
	
	//bahhh what the hell, lets go crazy with it!
    if (animated) {
        imgHeart.alpha = filled ? 0.f : 1.f;
        [UIView animateWithDuration:0.1f delay:4.f options:0 animations:^{
            imgHeart.alpha = filled ? 0.f : 1.f;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.1f animations:^{
                imgHeart.alpha = filled ? 1.f : 0.f;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.2f animations:^{
                    imgHeart.alpha = filled ? 0.f : 1.f;
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.25f animations:^{
                        imgHeart.alpha = filled ? 1.f : 0.f;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:0.3f animations:^{
                            imgHeart.alpha = filled ? 0.f : 1.f;
                        } completion:^(BOOL finished){
                            [UIView animateWithDuration:1.0f animations:^{
                                imgHeart.alpha = filled ? 1.f : 0.f;
                            } completion:^(BOOL finished){
                                if (completion) {
                                    completion();
                                }
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }
    else{
        imgHeart.alpha = filled ? 1.f : 0.f;
        if (completion) completion();
    }
}

@end
