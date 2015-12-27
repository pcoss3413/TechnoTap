//
//  ScoreboardView.h
//  ColorTap
//
//  Created by Patrick Cossette on 5/3/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageButton.h"
#import "UIMotionUtil.h"
#import "SubmitScoreView.h"
#import "ScoreboardManager.h"

@protocol SubmitScoreViewDelegate <NSObject>
-(void)scoreboardDidCancel:(id)scoreboardView;
-(void)scoreboardDidSubmitScoreWithResponse:(NSDictionary*)response;
@end

@interface SubmitScoreView : UIView <UITextFieldDelegate, UIAlertViewDelegate> {
    UIView *contentView;
    
    UILabel *lblScore;
    UITextField *txtName;
    
    UIButton *btnSubmit;
    UIButton *btnCancel;
    
    UIActivityIndicatorView *actSubmitting;
    
    UIView *blocker;
}

@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, weak) id <SubmitScoreViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame score:(NSUInteger)s;
-(void)hideWithCompletion:(void (^)())completion;
-(void)submit;
-(void)cancel;
-(void)show;

@end
