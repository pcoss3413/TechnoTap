//
//  StatusView.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/30/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubmitScoreView.h"
#import "UISettingsView.h"
#import "UIImageButton.h"
#import "UIScoreboard.h"
#import "UIHeart.h"

@protocol StatusViewDelegate <NSObject>
-(void)statusViewDidContinue;
-(void)statusViewDidExitToMenu;
@end

@interface StatusView : UIView <UISettingsViewDelegate, SubmitScoreViewDelegate, UIScoreboardDelegate> {
    UIHeart *hearts[3];
    UILabel *lblGameover;
    UILabel *lblPoints;
    UILabel *lblScore;
    UILabel *lblLevel;
    
    UIImageButton *btnSubmitScore;
    UIImageButton *btnContinue;
    UIImageButton *btnExit;
    UIButton *btnSettings;
    
    SubmitScoreView *sbView;
    UIScoreboard *viwScoreboard;
}

@property (nonatomic, weak) id <StatusViewDelegate> delegate;
@property (nonatomic, assign) BOOL hasSubmittedScore;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) short int lives;

-(void)exit;
-(void)submit;
-(void)setPaused;
-(void)resetHearts;
-(void)continueGame;
-(void)showSettings;
-(void)setPoints:(NSUInteger)points;
-(void)setLives:(short int)lives withCompletion:(void (^)())completion;

@end
