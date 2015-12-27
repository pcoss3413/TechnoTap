//
//  UIImageButton.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/29/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "UIImageButton.h"

@implementation UIImageButton

-(id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit{
    backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImage.clipsToBounds = YES;
    [self insertSubview:backgroundImage atIndex:0];
}

-(void)setBackgroundImage:(UIImage*)image{
    [backgroundImage setImage:image];
}

-(void)setCornerRadius:(CGFloat)radius{
    backgroundImage.layer.cornerRadius = radius;
}

@end
