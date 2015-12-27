//
//  UIMotionUtil.m
//  DrinkCounter
//
//  Created by Patrick on 7/30/14.
//  Copyright (c) 2014 Patrick. All rights reserved.
//

#import "UIMotionUtil.h"

@implementation UIMotionUtil

//This makes things sooo much more convinient
+(UIMotionEffectGroup*)centeredMotionGroupWithMaxValues:(CGPoint)maxRelativeMotion{
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @(-maxRelativeMotion.x);
    xAxis.maximumRelativeValue = @(maxRelativeMotion.x);
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @(-maxRelativeMotion.y);
    yAxis.maximumRelativeValue = @(maxRelativeMotion.y);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    
    return group;
}

@end
