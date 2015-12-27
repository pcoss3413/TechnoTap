//
//  ColorTapGameView.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/13/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {  //I may add more modes in the future...
    colorTapGameTypeNormal
} ColorTapGameType;

@protocol ColorTapGameViewDelegate <NSObject>
-(void)didEndGame;
@end

@interface ColorTapGameView : UIView

-(void)fail;
-(void)cycle;
-(void)redout;
-(void)redraw;
-(void)timeout;
-(void)greenout;
-(void)startLevel;
-(void)restoreColor;
-(float)timeForLevel;
-(void)updateTileCount;
-(void)setTilesHidden:(BOOL)hidden;
-(void)setBorderColor:(UIColor*)color;

@property (nonatomic, assign) BOOL SFX;
@property (nonatomic, assign) BOOL Music;
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) short int hearts;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) BOOL isInterrupted;
@property (nonatomic, assign) BOOL gameInProgress;
@property (nonatomic, weak) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) ColorTapGameType colorTapGameType;
@property (nonatomic, weak) id <ColorTapGameViewDelegate> delegate;

@end
