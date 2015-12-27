//
//  ScoreboardView.m
//  ColorTap
//
//  Created by Patrick Cossette on 5/3/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "SubmitScoreView.h"

@implementation SubmitScoreView

-(id)initWithFrame:(CGRect)frame score:(NSUInteger)s{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f];
        
        blocker = [[UIView alloc] initWithFrame:self.bounds];
        [blocker setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f]];
        [self addSubview:blocker];
        
        self.alpha = 0.f;
        
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 300.f) / 2.f, (frame.size.height - 150.f) / 2.f, 300.f, 150)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        contentView.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:0.98f];
        contentView.layer.cornerRadius = 15.f;
        contentView.clipsToBounds = YES;
        contentView.layer.borderColor = [[UIColor blackColor] CGColor];
        contentView.layer.borderWidth = 2.f / [[UIScreen mainScreen] scale];
        [contentView addMotionEffect:[UIMotionUtil centeredMotionGroupWithMaxValues:CGPointMake(10.f, 10.f)]];
        [blocker addSubview:contentView];
        
        txtName = [[UITextField alloc] initWithFrame:CGRectMake(15.f, 5, contentView.frame.size.width - 30.f, 30.f)];
        [txtName setPlaceholder:@"Name"];
        [txtName setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:20.f]];
        [txtName setBorderStyle:UITextBorderStyleRoundedRect];
        [txtName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [txtName setAutocorrectionType:UITextAutocorrectionTypeNo];
        [txtName setReturnKeyType:UIReturnKeySend];
        
        txtName.delegate = self;
        
        if (name)
            [txtName setText:name];
        
        [contentView addSubview:txtName];
        
        lblScore = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 42.f, contentView.frame.size.width - 20.f, 40.f)];
        lblScore.textAlignment = NSTextAlignmentCenter;
        [lblScore setText:[NSString stringWithFormat:@"Score: %lu", (unsigned long)s]];
        [lblScore setAdjustsFontSizeToFitWidth:YES];
        [lblScore setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:30.f]];
        [lblScore setBackgroundColor:[UIColor clearColor]];
        [lblScore setTextColor:[UIColor blackColor]];
        [contentView addSubview:lblScore];
        
        actSubmitting = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((contentView.frame.size.width - 25.f) / 2.f, (contentView.frame.size.height - 25.f) / 2.f, 25.f, 25.f)];
        [actSubmitting setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [actSubmitting setHidesWhenStopped:YES];
        [actSubmitting stopAnimating];
        [contentView addSubview:actSubmitting];
        
        
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2.f, contentView.frame.size.height - 50.f, contentView.frame.size.width / 2.f, 50.f)];
        btnCancel.backgroundColor = [UIColor clearColor];
        [btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:0.25f] forState:UIControlStateHighlighted];
        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [contentView addSubview:btnCancel];
        
        btnSubmit = [[UIButton alloc] initWithFrame:CGRectMake(0.f, contentView.frame.size.height - 50.f, contentView.frame.size.width / 2.f, 50.f)];
        btnSubmit.backgroundColor = [UIColor clearColor];
        [btnSubmit setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        [btnSubmit setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:1.f alpha:0.25f] forState:UIControlStateHighlighted];
        [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
        [btnSubmit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [btnSubmit.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [contentView addSubview:btnSubmit];
        
        UIView *sep1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, contentView.frame.size.height - 50.f, contentView.frame.size.width, 1.f)];
        [sep1 setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        [contentView addSubview:sep1];
        
        UIView *sep2 = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2.f, contentView.frame.size.height - 49.f, 1.f, 49.f)];
        [sep2 setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        [contentView addSubview:sep2];
        
        contentView.layer.transform = CATransform3DMakeScale(0.2f, 0.2f, 0.2f);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

    }
    
    return self;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submit];
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    if ([[textField.text stringByReplacingCharactersInRange:range withString:string] length] > 11 ||
        [string rangeOfCharacterFromSet:charactersToRemove options:0].location != NSNotFound) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UI Stuff

-(void)setScore:(NSUInteger)score{
    _score = score;
    [lblScore setText:[NSString stringWithFormat:@"Score: %lu", (unsigned long)self.score]];
}

-(void)show{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
        contentView.layer.transform = CATransform3DMakeScale(1.1f, 1.1f, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1f animations:^{
            contentView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
        } completion:^(BOOL finished){
            [txtName becomeFirstResponder];
        }];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [txtName becomeFirstResponder];
}

-(void)submit{
    
    if (!txtName.text || !txtName.text.length) {
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"Invalid name" message:@"Please enter a display name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alt show];
    }
    else{
        
        NSString *name = [txtName.text lowercaseString]; //This font doesn't support case anyway, and this makes it easier to filter
        
        NSString *curses = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cursedb" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
        NSArray *lcurses = [curses componentsSeparatedByString:@"\n"];

        for(NSString *curse in lcurses){
            if ([name rangeOfString:curse].location != NSNotFound) {
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"Inappropriate Name" message:@"Please choose a different name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alt show];
                
                [txtName becomeFirstResponder];
                btnSubmit.enabled = YES;
                btnCancel.enabled = YES;
                txtName.enabled = YES;
                lblScore.alpha = 1.f;
                txtName.alpha = 1.f;
                btnCancel.alpha = 1.f;
                btnSubmit.alpha = 1.f;
                [actSubmitting stopAnimating];
                return;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        btnSubmit.enabled = NO;
        btnCancel.enabled = NO;
        txtName.enabled = NO;
        lblScore.alpha = 0.0f;
        txtName.alpha = 0.25f;
        btnCancel.alpha = 0.25f;
        btnSubmit.alpha = 0.25f;
        
        [actSubmitting setHidden:NO];
        [actSubmitting startAnimating];
        
        [[ScoreboardManager sharedManager] submitScore:self.score forUser:name completion:^(NSDictionary *response, NSError *error){
            if (error) {
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alt show];
                
                //Something went wrong, re-enable the user's controls
                btnSubmit.enabled = YES;
                btnCancel.enabled = YES;
                txtName.enabled = YES;
                lblScore.alpha = 1.f;
                txtName.alpha = 1.f;
                btnCancel.alpha = 1.f;
                btnSubmit.alpha = 1.f;
                [actSubmitting stopAnimating];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(scoreboardDidSubmitScoreWithResponse:)]) {
                    //It is *possible* that if we're REALLY FLOODED with traffic, the server may not return the user's own result that they *just* submitted.
                    //So just in case that happens, we'll take the recent scores, and add our score to it to make *sure* it shows up!
                    
                    NSMutableArray *aryScores = [[response objectForKey:@"recent"] mutableCopy];
                    BOOL hasScore = NO;
                    for(NSArray *array in aryScores){
                        if (array.count > 3 && [[array objectAtIndex:3] isEqualToString:response[@"scoreId"]]) {
                            hasScore = YES;
                            break;
                        }
                    }
                    
                    if (!hasScore) {
                        if(aryScores.count) [aryScores removeObjectAtIndex:0];
                        
                        [aryScores addObject:  //We don't display the timestamp, so its not used at all here
                         @[name,
                           [ScoreboardManager getISOCountryCode],
                           [NSString stringWithFormat:@"%lu", (unsigned long)self.score],
                           [response objectForKey:@"scoreId"]]];
                    }
                    
                    aryScores =[[aryScores sortedArrayUsingComparator:^NSComparisonResult(NSArray* obj1, NSArray* obj2) {
                        if (obj1.count < 3 || obj2.count < 3)
                            return [@1 compare:@1];
                        
                        return [[NSNumber numberWithInt:[obj2[2] intValue]] compare:[NSNumber numberWithInt:[obj1[2] intValue]]];
                    }] mutableCopy];
                    
                    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] initWithDictionary:response];
                    [responseDict setObject:aryScores forKey:@"recent"];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
                    
                    [self.delegate scoreboardDidSubmitScoreWithResponse:responseDict];
                }
            }
        }];
    }
}

-(void)cancel{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoreboardDidCancel:)]) {
        [self.delegate scoreboardDidCancel:self];
    }
}

-(void)hideWithCompletion:(void (^)())completion{
    [txtName resignFirstResponder];
    [UIView animateWithDuration:0.1f animations:^{
        contentView.layer.transform = CATransform3DMakeScale(1.1f, 1.1f, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.f;
            contentView.layer.transform = CATransform3DMakeScale(0.2f, 0.2f, 0.2f);
        } completion:^(BOOL finished){
            btnSubmit.enabled = YES;
            btnCancel.enabled = YES;
            txtName.enabled = YES;
            lblScore.alpha = 1.f;
            txtName.alpha = 1.f;
            btnCancel.alpha = 1.;
            btnSubmit.alpha = 1.;
            [actSubmitting stopAnimating];
            
            if (completion) completion();
        }];
    }];
}

#pragma mark - Keyboard Management

-(void)keyboardWasHidden:(NSNotification *)nsNotification {
    NSDictionary *userInfo = nsNotification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [blocker setFrame:self.superview.frame];
    } completion:nil];
}

-(void)keyboardWasShown:(NSNotification *)nsNotification {
    NSDictionary *userInfo = nsNotification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = MIN(keyboardRect.size.height, keyboardRect.size.width);

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [blocker setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.superview.frame.size.height-keyboardHeight)];
    } completion:nil];
}

@end
