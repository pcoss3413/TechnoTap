//
//  StatusView.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/30/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView


-(id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.85f];
        
        self.hasSubmittedScore = NO;
        
        CGFloat heartWidth = 100.f;
        for(int i = 0; i < 3; i++){
            hearts[i] = [[UIHeart alloc] initWithFrame:CGRectMake((frame.size.width - (heartWidth*3.f)) / 2.f + (heartWidth*i), 30.f, 100.f, 95.f)];
            [hearts[i] setFilled:YES animated:NO completion:nil];
            [self addSubview:hearts[i]];
        }
        
        lblGameover = [[UILabel alloc] initWithFrame:CGRectMake([hearts[0] frame].origin.x, [hearts[0] frame].origin.y, 300.f, 95.f)];
        [lblGameover setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:30.f]];
        [lblGameover setBackgroundColor:[UIColor clearColor]];
        [lblGameover setTextAlignment:NSTextAlignmentCenter];
        [lblGameover setTextColor:[UIColor redColor]];
        [lblGameover setText:@"Game Over!"];
        lblGameover.hidden = YES;
        [self addSubview:lblGameover];
        
        btnExit = [[UIImageButton alloc] initWithFrame:CGRectMake((frame.size.width - 205.f) / 2.f, frame.size.height - 40.f - 38.f, 205.f, 40.f)];
        [btnExit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [btnExit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnExit setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f] forState:UIControlStateHighlighted];
        [btnExit.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnExit setBackgroundImage:[UIImage imageNamed:@"Images/help.png"]];
        [btnExit setTitle:@"Exit" forState:UIControlStateNormal];
        [btnExit setCornerRadius:10.f];
        [self addSubview:btnExit];
        
        btnContinue = [[UIImageButton alloc] initWithFrame:CGRectMake((frame.size.width - 205.f) / 2.f, btnExit.frame.origin.y - 15.f - 40.f, 205.f, 40.f)];
        [btnContinue addTarget:self action:@selector(continueGame) forControlEvents:UIControlEventTouchUpInside];
        [btnContinue.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnContinue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnContinue setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f] forState:UIControlStateHighlighted];
        [btnContinue setBackgroundImage:[UIImage imageNamed:@"Images/start.png"]];
        [btnContinue setTitle:@"Continue" forState:UIControlStateNormal];
        [btnContinue setCornerRadius:10.f];
        [self addSubview:btnContinue];
        
        btnSubmitScore = [[UIImageButton alloc] initWithFrame:CGRectMake((frame.size.width - 205.f) / 2.f, btnContinue.frame.origin.y - 15.f - 40.f, 205.f, 40.f)];
        [btnSubmitScore addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [btnSubmitScore.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnSubmitScore setBackgroundImage:[UIImage imageNamed:@"Images/score.png"]];
        [btnSubmitScore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnSubmitScore setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f] forState:UIControlStateHighlighted];
        [btnSubmitScore setTitle:@"Submit Score" forState:UIControlStateNormal];
        [btnSubmitScore setCornerRadius:10.f];
        btnSubmitScore.hidden = YES;
        [self addSubview:btnSubmitScore];
        
        lblPoints = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 145.f, frame.size.width, 150.f)];
        [lblPoints setTextColor:[UIColor whiteColor]];
        [lblPoints setNumberOfLines:0];
        [lblPoints setText:@""];
        [lblPoints setTextAlignment:NSTextAlignmentCenter];
        [lblPoints setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:60.f]];
        [lblPoints setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:lblPoints];
        
        btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 16.f - 30.f, frame.size.height - 27.f - 30.f, 30.f, 30.f)];
        [btnSettings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
        [btnSettings setImage:[UIImage imageNamed:@"Images/gear.png"] forState:UIControlStateNormal];
        btnSettings.backgroundColor = [UIColor clearColor];
        [self addSubview:btnSettings];
    }
    
    return self;
}

-(void)didSaveSettings:(id)settingsView{
    if (settingsView) {
        [settingsView hideWithCompletion:^{
            [settingsView removeFromSuperview];
        }];
        
        [UIView animateWithDuration:1.0f animations:^(void){
            btnSettings.transform = CGAffineTransformMakeRotation(0.f);
        }];
    }
}

-(void)showSettings{
    UISettingsView *viwSettings = [[UISettingsView alloc] initWithFrame:self.bounds];
    viwSettings.delegate = self;
    [self addSubview:viwSettings];
    
    [viwSettings show];
    
    [UIView animateWithDuration:1.0f animations:^(void){
        btnSettings.transform = CGAffineTransformMakeRotation(3.14159f);
    }];
}

-(void)resetHearts{
    lblGameover.hidden = YES;
    
    for(int i = 0; i < 3; i++){
        [hearts[i] setHidden:NO];
        [hearts[i] setFilled:YES animated:NO completion:nil];
    }
}

-(void)exit{
    self.hasSubmittedScore = NO;
    [btnSubmitScore setTitle:@"Submit Score" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusViewDidExitToMenu)]) {
        [self.delegate statusViewDidExitToMenu];
    }
}

-(void)submit{
    if (self.hasSubmittedScore) {
        if (viwScoreboard) {
            [viwScoreboard removeFromSuperview];
            viwScoreboard = nil;
        }
        
        viwScoreboard = [[UIScoreboard alloc] initWithFrame:self.bounds timePeriod:timePeriodRecent];
        viwScoreboard.autoUpdate = YES;
        viwScoreboard.delegate = self;
        [self addSubview:viwScoreboard];
        
        [viwScoreboard show];
    }
    else{
        if (!sbView) {
            sbView = [[SubmitScoreView alloc] initWithFrame:self.bounds score:self.score];
            sbView.delegate = self;
            [self addSubview:sbView];
        }
        
        [sbView setScore:self.score];
        [sbView show];
    }
}

-(void)scoreboardDidCancel:(id)scoreboardView{
    if (sbView) {
        [sbView hideWithCompletion:^{
            //[sbView removeFromSuperview];
            //sbView = nil;
        }];
    }
}

-(void)scoreboardDidSubmitScoreWithResponse:(NSDictionary*)response{
    if (sbView) {
        
        self.hasSubmittedScore = YES;
        [btnSubmitScore setTitle:@"Scoreboard" forState:UIControlStateNormal];
        
        [sbView hideWithCompletion:^{
            
            if (viwScoreboard) {
                [viwScoreboard removeFromSuperview];
                viwScoreboard = nil;
            }
            
            viwScoreboard = [[UIScoreboard alloc] initWithFrame:self.bounds timePeriod:timePeriodRecent];
            viwScoreboard.userScoreId = [[response objectForKey:@"scoreId"] unsignedIntegerValue];
            [viwScoreboard setAryRecentScores:[response objectForKey:@"recent"]];
            viwScoreboard.autoUpdate = NO;
            viwScoreboard.delegate = self;
            [self addSubview:viwScoreboard];
            
            [viwScoreboard show];
        }];
    }
}

-(void)scoreboardDidDismiss{
    if (viwScoreboard) {
        [viwScoreboard removeFromSuperview];
        viwScoreboard = nil;
    }
}

-(void)continueGame{
    self.hasSubmittedScore = NO;
    [btnSubmitScore setTitle:@"Submit Score" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusViewDidContinue)]) {
        [self.delegate statusViewDidContinue];
    }
}

-(void)setPoints:(NSUInteger)points{
    
    if (points > [ScoreboardManager alltimeBest])
        [ScoreboardManager setAlltimeBest:points];
    
    if (!points) { //No need to submit a score of zero...
        self.hasSubmittedScore = YES;
        [btnSubmitScore setTitle:@"Scoreboard" forState:UIControlStateNormal];
    }
    
    self.score = points;
    lblPoints.text = [NSString stringWithFormat:@"Score:\n%@", points ? [NSString stringWithFormat:@"%lu", (unsigned long)points] : @"zero"];
}

-(void)setPaused{
    btnSubmitScore.hidden = YES;
    lblGameover.hidden = YES;
    [btnContinue setTitle:@"Resume" forState:UIControlStateNormal];
    
    for(int i = 0;i < 3;i++){
        [hearts[i] setFilled:(i < MAX(self.lives, 0)) ? YES : NO animated:NO completion:nil];
        [hearts[i] setHidden:NO];
    }
}

-(void)setLives:(short int)lives withCompletion:(void (^)())completion{
    _lives = lives;
	
    if (!(self.lives-1)) { //Some weirdness here
        lblGameover.hidden = NO;
        for(int i = 0;i < 3;[hearts[i++] setHidden:YES]);
        btnSubmitScore.hidden = NO;
        [btnContinue setTitle:@"Restart" forState:UIControlStateNormal];
    }
    else{
        btnSubmitScore.hidden = YES;
        [btnContinue setTitle:@"Continue" forState:UIControlStateNormal];
    }
    
    [hearts[MAX(self.lives-1, 0)] setFilled:NO animated:YES completion:^{ //Theres that weirdness again.. hmm.
        if (completion) completion();
    }];
}


@end
