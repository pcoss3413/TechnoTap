//
//  UIScoreboard.m
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "ScoreboardManager.h"
#import "UIScoreboard.h"

@implementation UIScoreboard

-(id)initWithFrame:(CGRect)frame timePeriod:(TimePeriod)period{  //forever, last hour
    if ((self = [super initWithFrame:frame])) {
        
        self.alpha = 0.f;
        self.loadingRecentScores = NO;
        self.loadingTopScores = NO;
        self.userScoreId = 0;
        self.introHasCompleted = NO;
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 15.f, self.frame.size.width-30.f, self.frame.size.height-30.f)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.borderWidth = 2.f / [[UIScreen mainScreen] scale];
        contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        contentView.layer.cornerRadius = 15.f;
        
        lblScores = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, contentView.frame.size.width, 35.f)];
        lblScores.textAlignment = NSTextAlignmentCenter;
        [lblScores setText:@"--Scoreboard--"];
        [lblScores setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:22.f]];
        [lblScores setBackgroundColor:[UIColor clearColor]];
        [lblScores setTextColor:[UIColor blackColor]];
        [contentView addSubview:lblScores];
        
        segPeriodSelection = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10.f, 35.f, contentView.frame.size.width - 20.f, 30.f)];
        [segPeriodSelection setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"GoodTimesRg-Regular" size:14.f]} forState:UIControlStateNormal];
        [segPeriodSelection addTarget:self action:@selector(periodSelectionDidChange) forControlEvents:UIControlEventValueChanged];
        [segPeriodSelection insertSegmentWithTitle:@"Most Recent" atIndex:0 animated:NO];
        [segPeriodSelection insertSegmentWithTitle:@"All-Time Best" atIndex:0 animated:NO];
        [segPeriodSelection setSelectedSegmentIndex:period];
        [contentView addSubview:segPeriodSelection];
        
        
        btnDone = [[UIImageButton alloc] initWithFrame:CGRectMake((contentView.frame.size.width - 205.f) / 2.f, contentView.frame.size.height - 40.f - 10.f, 205.f, 40.f)];
        [btnDone addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] forState:UIControlStateHighlighted];
        [btnDone.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnDone setBackgroundImage:[UIImage imageNamed:@"Images/help.png"]];
        [btnDone setTitle:@"Exit" forState:UIControlStateNormal];
        [btnDone setCornerRadius:10.f];
        [contentView addSubview:btnDone];
        
        
        CGFloat tableAdjustment = ([ScoreboardManager alltimeBest]) ? 20.f : 0.f;
        
        if ([ScoreboardManager alltimeBest]) {
            lblPersonalBest = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, segPeriodSelection.frame.origin.y + segPeriodSelection.frame.size.height + 5.f, contentView.frame.size.width, 18.f)];
            lblPersonalBest.textAlignment = NSTextAlignmentCenter;
            [lblPersonalBest setText:[NSString stringWithFormat:@"Personal Best: %lu", (unsigned long)[ScoreboardManager alltimeBest]]];
            [lblPersonalBest setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:14.f]];
            [lblPersonalBest setBackgroundColor:[UIColor clearColor]];
            [lblPersonalBest setTextColor:[UIColor blackColor]];
            [contentView addSubview:lblPersonalBest];
        }
        
        tblScores = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, segPeriodSelection.frame.origin.y + segPeriodSelection.frame.size.height + 5.f + tableAdjustment, contentView.frame.size.width, contentView.frame.size.height - (segPeriodSelection.frame.origin.y + segPeriodSelection.frame.size.height) - (contentView.frame.size.height - btnDone.frame.origin.y) - tableAdjustment - 10.f) style:UITableViewStylePlain];
        tblScores.delegate = self;
        tblScores.dataSource = self;
        tblScores.alpha = 0.2f;
        [contentView addSubview:tblScores];
        
        tblScores.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        if ([tblScores respondsToSelector:@selector(setLayoutMargins:)])
            [tblScores setLayoutMargins:UIEdgeInsetsZero];
        
        [tblScores setSeparatorColor:[UIColor blackColor]];
        
        [self addSubview:contentView];
        
        
        actLoadingScores = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width - 25.f) / 2.f, (tblScores.frame.size.height - 25.f) / 2.f + tblScores.frame.origin.y, 25.f, 25.f)];
        [actLoadingScores setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [actLoadingScores setHidesWhenStopped:YES];
		
        tblScores.userInteractionEnabled = NO;
        [self addSubview:actLoadingScores];
        
        imgError = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.frame.size.width - 100.f) / 2.f, (contentView.frame.size.height - 100.f) / 2.f - 25.f, 100.f, 100.f)];
        imgError.backgroundColor = [UIColor clearColor];
        [imgError setImage:[UIImage imageNamed:@"Images/error.png"]];
        imgError.hidden = YES;
        [contentView addSubview:imgError];
        
        lblError = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, imgError.frame.origin.y + 110.f, contentView.frame.size.width, 100.f)];
        lblError.hidden = YES;
        lblError.numberOfLines = 0;
        lblError.textAlignment = NSTextAlignmentCenter;
        [lblError setText:@"Network Error!\nTry again later"];
        [lblError setBackgroundColor:[UIColor clearColor]];
        [lblError setTextColor:[UIColor darkGrayColor]];
        [lblError setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:18.f]];
        [contentView addSubview:lblError];
        
        contentView.layer.transform = CATransform3DMakeScale(0.4f, 0.4f, 0.4f);
    }
    
    return self;
}

-(void)setUserScoreId:(NSUInteger)userScoreId{
    _userScoreId = userScoreId;
    [segPeriodSelection setSelectedSegmentIndex:1];
    self.hasAutoscrolled = NO;
}

-(void)reload{
    if (!self.introHasCompleted)
        return;

    [tblScores beginUpdates];
    [tblScores reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tblScores endUpdates];
}

-(void)setLoading:(BOOL)loading{
    if (loading) {
        lblError.hidden = YES;
        imgError.hidden = YES;
        [actLoadingScores startAnimating];
        tblScores.userInteractionEnabled = NO;
        tblScores.alpha = 0.2f;
    }
    else{
        [actLoadingScores stopAnimating];
        tblScores.userInteractionEnabled = YES;
        tblScores.alpha = 1.f;
    }
}

-(void)exit{
    if (autoUpdateTime){
        [autoUpdateTime invalidate];
        autoUpdateTime = nil;
    }
    
    [self hideWithCompletion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(scoreboardDidDismiss)]){
            [self.delegate scoreboardDidDismiss];
        }
    }];
}

-(void)periodSelectionDidChange{
    
    lblError.hidden = YES;
    imgError.hidden = YES;
    
    if (segPeriodSelection.selectedSegmentIndex) {
        //Most Recent
        if (!self.aryRecentScores && !self.loadingRecentScores) {
            [self setLoading:YES];
            [self loadRecentScores];
        }
        else{
            [self setLoading:NO];
            
            [self reload];
            
            if (self.userScoreId && !self.hasAutoscrolled) {
                int onRow = 0;
                for(NSArray *scoreArray in self.aryRecentScores){
                    
                    if (scoreArray.count > 3 && [[scoreArray objectAtIndex:3] integerValue] == self.userScoreId) {
                        NSIndexPath* ipath = [NSIndexPath indexPathForRow:onRow inSection:0];
                        [tblScores scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionMiddle animated:YES];
                        
                        self.hasAutoscrolled = YES;
                        break;
                    }
                    
                    onRow++;
                }
            }
        }
    }
    else{
        [actLoadingScores stopAnimating];
        tblScores.userInteractionEnabled = YES;
        
        //Not most-recent...
        if (!self.aryTopScores && !self.loadingTopScores) {
            [self setLoading:YES];
            self.loadingTopScores = YES;
            [[ScoreboardManager sharedManager] getScoresInTimePeriod:timePeriodForever completion:^(NSArray *scores, NSError *error){
                self.loadingTopScores = NO;
                if (!error) {
                    tblScores.hidden = NO;
                    self.aryTopScores = scores;
                    if (!segPeriodSelection.selectedSegmentIndex) {
                        [self reload];
                        [self setLoading:NO];
                    }
                }
                else if (!self.aryTopScores || !self.aryTopScores.count){
                    self.aryTopScores = nil;
                    [self reload];
                    [self setLoading:NO];
                    
                    tblScores.hidden = YES;
                    lblError.hidden = NO;
                    imgError.hidden = NO;
                }
            }];
        }
        else{
            [self reload];
            [self setLoading:NO];
        }
    }
}

-(void)loadRecentScores{
	
    self.loadingRecentScores = YES;
    lblError.hidden = YES;
    imgError.hidden = YES;
    [[ScoreboardManager sharedManager] getScoresInTimePeriod:timePeriodRecent completion:^(NSArray *scores, NSError *error){
        self.loadingRecentScores = NO;
        if (!error) {
            tblScores.hidden = NO;
            self.aryRecentScores = [scores sortedArrayUsingComparator:^NSComparisonResult(NSArray* obj1, NSArray* obj2) {
                if (obj1.count < 3 || obj2.count < 3)
                    return [@1 compare:@1];
    
                return [[NSNumber numberWithInt:[obj2[2] intValue]] compare:[NSNumber numberWithInt:[obj1[2] intValue]]];
            }];
            
            if (segPeriodSelection.selectedSegmentIndex) {
                [self reload];
                [self setLoading:NO];
            }
            
            if (self.autoUpdate) {
                if (autoUpdateTime) {
                    [autoUpdateTime invalidate];
                    autoUpdateTime = nil;
                }
                autoUpdateTime = [NSTimer scheduledTimerWithTimeInterval:15.f target:self selector:@selector(loadRecentScores) userInfo:nil repeats:NO];
            }
            
            if (self.userScoreId) {
                int onRow = 0;
                
                for(NSArray *scoreArray in self.aryRecentScores){
                    //Give the table a little time to refresh
                    if (scoreArray.count > 3 && [[scoreArray objectAtIndex:3] unsignedIntegerValue] == self.userScoreId) {
                        NSIndexPath* ipath = [NSIndexPath indexPathForRow:onRow inSection:0];
                        [tblScores scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionMiddle animated:YES];
                        
                        break;
                    }
                    
                    onRow++;
                }
            }
            
        }
        else if(!self.aryRecentScores || !self.aryRecentScores.count){
            if (self.aryRecentScores && ![self.aryRecentScores count]) {
                self.aryRecentScores = nil;
            }
            tblScores.hidden = YES;
            lblError.hidden = NO;
            imgError.hidden = NO;
            
            [self reload];
            [self setLoading:NO];
        }
    }];
}

-(void)show{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
        contentView.layer.transform = CATransform3DMakeScale(1.1f, 1.1f, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1f animations:^{
            contentView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
        } completion:^(BOOL finished){
            self.introHasCompleted = YES;
            [self periodSelectionDidChange];
        }];
    }];
}

-(void)hideWithCompletion:(void (^)())completion{
    [UIView animateWithDuration:0.1f animations:^{
        contentView.layer.transform = CATransform3DMakeScale(1.1f, 1.1f, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.f;
            contentView.layer.transform = CATransform3DMakeScale(0.4f, 0.4f, 0.4f);
        } completion:^(BOOL finished){
            [self periodSelectionDidChange];
        }];
    }];
}

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (segPeriodSelection.selectedSegmentIndex == timePeriodRecent)
        return self.aryRecentScores ? self.aryRecentScores.count : 0;
    else
        return self.aryTopScores ? self.aryTopScores.count : 0;

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIScoreCell *cell = (UIScoreCell*)[tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
    
    if (!cell) {
        cell = [[UIScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScoreCell" parentWidth:contentView.frame.size.width];
    }
    else{
        
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)])
        cell.preservesSuperviewLayoutMargins = NO;
    
    
    NSArray *array = (segPeriodSelection.selectedSegmentIndex ? self.aryRecentScores : self.aryTopScores);
    [cell setScore:[array objectAtIndex:indexPath.row]];
    [cell setRank:indexPath.row+1];
    if (self.userScoreId && [[array objectAtIndex:indexPath.row] count] > 3 && [[[array objectAtIndex:indexPath.row] objectAtIndex:3] integerValue] == self.userScoreId) {
        cell.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f];
    }
    else
        cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}



@end
