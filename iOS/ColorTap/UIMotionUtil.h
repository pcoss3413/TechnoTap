//
//  UIMotionUtil.h
//  DrinkCounter
//
//  Created by Patrick on 7/30/14.
//  Copyright (c) 2014 Patrick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIMotionUtil : NSObject

+(UIMotionEffectGroup*)centeredMotionGroupWithMaxValues:(CGPoint)maxRelativeMotion;

@end
