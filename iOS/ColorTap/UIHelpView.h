//
//  UIScoreboard.h
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageButton.h"

@protocol UIHelpViewDelegate <NSObject>
-(void)helpviewDidDismiss;
-(void)showEmailController;
@end

@interface UIHelpView: UIView <UIScrollViewDelegate> {
    UILabel *lblScores;
    UIView *contentView;
    
    UIImageButton *btnTryAgain;
    UIImageButton *btnDone;
    
    UIScrollView *scrollview;
    UIPageControl *pageControl;
    
    UITextView *txtAbout;
    
}

-(void)show;
-(NSString*)imageNameForDevice:(NSString*)name;
-(void)hideWithCompletion:(void (^)())completion;

@property (nonatomic, weak) id <UIHelpViewDelegate> delegate;

@end
