//
//  ViewController.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/13/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScoreboard.h"
#import "UISettingsView.h"
#import "ScoreboardManager.h"
#import "UIHelpView.h"

@interface RootViewController : UIViewController <UISettingsViewDelegate, UIScoreboardDelegate, UIHelpViewDelegate> {
    UIScoreboard *viwScoreboard;
    UIHelpView *viwHelp;
}

-(void)createMusicPlayer;

@end

