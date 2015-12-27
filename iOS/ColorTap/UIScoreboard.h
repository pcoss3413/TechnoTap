//
//  UIScoreboard.h
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScoreCell.h"
#import "UIImageButton.h"
#import "ScoreboardManager.h"

@protocol UIScoreboardDelegate <NSObject>
-(void)scoreboardDidDismiss;
@end

@interface UIScoreboard : UIView <UITableViewDelegate, UITableViewDataSource> {
    UILabel *lblScores;
    UIView *contentView;
    UITableView *tblScores;
    UISegmentedControl *segPeriodSelection;
    
    UILabel *lblDownloadFailed; //Also use this to indicate an empty table?
    UIImageButton *btnTryAgain;
    
    UIImageButton *btnDone;
    
    UILabel *lblPersonalBest;
    UIActivityIndicatorView *actLoadingScores;
    
    NSTimer *autoUpdateTime;
    
    
    UIImageView *imgError;
    UILabel *lblError;
}

-(void)show;
-(void)reload;
-(void)setLoading:(BOOL)loading;
-(void)hideWithCompletion:(void (^)())completion;
-(id)initWithFrame:(CGRect)frame timePeriod:(TimePeriod)period;

@property (nonatomic, assign) BOOL loadingTopScores;
@property (nonatomic, strong) NSArray *aryTopScores;

@property (nonatomic, assign) BOOL loadingRecentScores;
@property (nonatomic, strong) NSArray *aryRecentScores;

@property (nonatomic, assign) BOOL autoUpdate;
@property (nonatomic, assign) NSUInteger userScoreId;

@property (nonatomic, assign) BOOL introHasCompleted;
@property (nonatomic, assign) BOOL hasAutoscrolled;

@property (nonatomic, weak) id <UIScoreboardDelegate> delegate;

@end
