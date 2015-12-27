//
//  UIHeart.h
//  ColorTap
//
//  Created by Patrick Cossette on 5/2/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHeart : UIImageView {
    UIImageView *imgHeart;
}

-(void)setFilled:(BOOL)filled animated:(BOOL)animated completion:(void (^)())completion;

@end
