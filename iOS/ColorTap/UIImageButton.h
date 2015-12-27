//
//  UIImageButton.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/29/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageButton : UIButton {
    UIImageView *backgroundImage;
}

-(void)setBackgroundImage:(UIImage*)image;
-(void)setCornerRadius:(CGFloat)radius;
-(void)commonInit;

@end
