//
//  UISettingsView.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/17/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UISettingsViewDelegate <NSObject>
-(void)didSaveSettings:(id)settingsView;

@optional
-(void)SFXSettingDidChange:(BOOL)SFXAreEnabled;
-(void)musicSettingDidChange:(BOOL)musicIsEnabled;
@end

@interface UISettingsView : UIView {
    UIView *contentView;
    
    UILabel *lblTitle;

    UISwitch *swtMusic;
    UISwitch *swtSFX;
    
    UILabel *lblMusic;
    UILabel *lblSFX;
    
    UIButton *btnDone;
    UIButton *btnCancel;
}

@property (nonatomic, weak) id <UISettingsViewDelegate> delegate;

-(void)show;
-(void)dismiss;
-(void)hideWithCompletion:(void(^)())completion;

@end
