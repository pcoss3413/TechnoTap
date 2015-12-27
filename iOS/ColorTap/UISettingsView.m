//
//  UISettingsView.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/17/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "UISettingsView.h"
#import "UIMotionUtil.h"

@implementation UISettingsView

-(id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.alpha = 0.f;
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.75f];
        
        btnCancel = [[UIButton alloc] initWithFrame:self.bounds];
        [btnCancel setBackgroundColor:[UIColor clearColor]];
        [btnCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCancel];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 300.f) / 2.f, (self.frame.size.height - 150.f) / 2.f, 300.f, 150.f)];
        contentView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        contentView.layer.cornerRadius = 15.f;
        contentView.clipsToBounds = YES;
        contentView.alpha = 0.f;
        contentView.layer.borderColor = [[UIColor blackColor] CGColor];
        contentView.layer.borderWidth = 2.f / [[UIScreen mainScreen] scale];
        [contentView addMotionEffect:[UIMotionUtil centeredMotionGroupWithMaxValues:CGPointMake(20.f, 20.f)]];
        [self addSubview:contentView];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, contentView.frame.size.width, 50.f)];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        [lblTitle setText:@"Settings"];
        [lblTitle setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:20.f]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setTextColor:[UIColor blackColor]];
        [contentView addSubview:lblTitle];
        
        lblMusic = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.f, 75.f, 50.f)];
        [lblMusic setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        lblMusic.textAlignment = NSTextAlignmentRight;
        lblMusic.text = @"Music: ";
        [contentView addSubview:lblMusic];
        
        lblSFX = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2.f, 40, 75.f, 50.f)];
        [lblSFX setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        lblSFX.textAlignment = NSTextAlignmentRight;
        lblSFX.text = @"SFX: ";
        [contentView addSubview:lblSFX];
        
        swtMusic = [[UISwitch alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2.f - 60.f, 50.f, 50.f, 30.f)];
        [swtMusic addTarget:self action:@selector(settingsDidChange:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:swtMusic];
        
        swtSFX = [[UISwitch alloc] initWithFrame:CGRectMake(contentView.frame.size.width - 60.f, 50.f, 50.f, 30.f)];
        [swtSFX addTarget:self action:@selector(settingsDidChange:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:swtSFX];
        
        btnDone = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, contentView.frame.size.height - 50.f, contentView.frame.size.width, 50.f)];
        [btnDone addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [btnDone.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnDone setTitle:@"Save" forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor colorWithRed:0.2f green:0.8f blue:0.2f alpha:1.f] forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor colorWithRed:0.2f green:0.8f blue:0.2f alpha:0.25f] forState:UIControlStateHighlighted];
        [contentView addSubview:btnDone];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, btnDone.frame.origin.y, contentView.frame.size.width, 1.f)];
        line.backgroundColor = [UIColor grayColor];
        [contentView addSubview:line];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        swtMusic.on = [[[defaults objectForKey:@"settings"] objectForKey:@"music"] boolValue];
        swtSFX.on = [[[defaults objectForKey:@"settings"] objectForKey:@"SFX"] boolValue];
        
        contentView.layer.transform =  CATransform3DMakeScale(0.2f, 0.2f, 0.2f);
        
    }
    
    return self;
}

-(void)settingsDidChange:(UISwitch*)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{@"music":@(swtMusic.isOn), @"SFX":@(swtSFX.isOn)} forKey:@"settings"];
    [defaults synchronize];
    
    if (sender == swtMusic) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(musicSettingDidChange:)]) {
            [self.delegate musicSettingDidChange:swtMusic.isOn];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MucicSettingsDidChangeNotification" object:nil];
        }
    }
    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(SFXSettingDidChange:)]) {
            [self.delegate SFXSettingDidChange:swtSFX.isOn];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SFXSettingsDidChangeNotification" object:nil];
        }
    }
}

-(void)dismiss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSaveSettings:)]) {
        [self.delegate didSaveSettings:self];
    }
}

-(void)show{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
        contentView.alpha = 1.f;
        contentView.layer.transform =  CATransform3DMakeScale(1.1f, 1.1, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.1 animations:^{
            contentView.layer.transform =  CATransform3DMakeScale(1.0f, 1.0, 1.0f);
        }];
    }];
}

-(void)hideWithCompletion:(void(^)())completion{
    [UIView animateWithDuration:0.1f animations:^{
        contentView.layer.transform =  CATransform3DMakeScale(1.1f, 1.1, 1.1f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            contentView.layer.transform =  CATransform3DMakeScale(0.2f, 0.2, 0.2f);
            self.alpha = 0.f;
        } completion:^(BOOL finished){
            if (finished && completion)
                completion();
        }];
    }];
    
}

@end
