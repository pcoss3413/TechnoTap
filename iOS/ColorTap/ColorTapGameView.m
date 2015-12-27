//
//  ColorTapGameView.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/13/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "ColorTapGameView.h"
#import "FISoundEngine.h"
#import "StatusView.h"


#define DARK_ALPHA 0.2f
#define MAX_DIFFICULTY 20
#define MUSIC_SAMPLES 12

typedef struct { //I'd use CGPoint, but these coordinates are used in modulos operations that don't require floats (fmod is more expensive than %)
    int x;
    int y;
} tileCoordinate;

@interface ColorTapGameView () <StatusViewDelegate> {
    NSMutableArray *aryColors;
    NSMutableArray *tilePaths; //Accessed as Y, X!
    
    tileCoordinate *points;
    NSUInteger tileCount;
    
    NSUInteger correctTiles;
    UIView *viwTileView;
    
    UILabel *lblLevel;
    StatusView *viwStatus;
    
    NSTimer *timeoutTimer;
    UIImageView *timerIndicatorView;
    
    UILabel *lblGo;
    
    //sounds
    FISound	*sounds[MUSIC_SAMPLES];
    FISound *soundPattern[MUSIC_SAMPLES];
    
    FISound *scratch;
    FISound *buzzer;
}

@property (nonatomic, assign) NSUInteger xTiles;
@property (nonatomic, assign) NSUInteger yTiles;
@property (nonatomic, strong) FISoundEngine *engine;

tileCoordinate tileCoordinateMake(int x, int y);

@end

@implementation ColorTapGameView

/*
 * 16 Levels of dificulty. The difficulty curve was changed a lot during development, I've found it impossible to
 * find a single difficulty curve that works well with all players. A difficulty curve that is adaptive to the player's
 * skill was considered, but ultimately I decided agains this as I think skilled players will trick the system in to
 * giving them a better score than they've actually earned.
 */

int levelTiles[] =     {   2,    3,    3,     3,        3,      3,     4,      4,        4,     4,     5,      5,    5,     5,     6,        6,    6,        6,       6,        6,     6};
CGFloat levelSpeed[] = {0.2f, 0.25f, 0.225, 0.2f,  0.175f,  0.17f, 0.25f,  0.25f,    0.225,   0.2,  0.25,  0.225,  0.2,  0.15,  0.25,    0.225,  0.2,    0.175,    0.15,    0.125,    0.1};
tileCoordinate squares[] = {{2, 2}, {3, 3}, {3, 4}, {4, 4}, {4, 5}}; //I've decided to skip the initial 2x2 mode, its too easy..

tileCoordinate tileCoordinateMake(int x, int y){
    tileCoordinate z;
    z.x = x;
    z.y = y;
    
    return z;
}

-(void)setTilesHidden:(BOOL)hidden{
    viwTileView.alpha = hidden ? 0.f : 1.f;
}


-(void)loadAudio{
    
    self.Music = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue];
    if (!self.Music)
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    if (self.SFX && !self.engine) {
        
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
        if (error) NSLog(@"set to ambient error: %@", error);
        
        self.engine = [FISoundEngine sharedEngine];
        
        for(int i = 0; i < MUSIC_SAMPLES+1; i++){
            sounds[i] = [self.engine soundNamed:[NSString stringWithFormat:@"Audio/tap%d.wav", i] maxPolyphony:6 error:&error];
  
            if(error)
                NSLog(@"Load Error: %@", error);
        }
        
        scratch = [self.engine soundNamed:@"Audio/scratch.wav" maxPolyphony:1 error:nil];
        buzzer = [self.engine soundNamed:@"Audio/buzzer.wav" maxPolyphony:1 error:nil];
    }
    
}

-(id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.SFX = [[[defaults objectForKey:@"settings"] objectForKey:@"SFX"] boolValue];
        
        self.gameInProgress = NO;
        correctTiles = 0;
        self.score = 0;

        aryColors = [NSMutableArray new];
        tilePaths = [NSMutableArray new];
        
        points = NULL;
        
        self.multipleTouchEnabled = YES;
        tileCount = 1; //[[defaults objectForKey:@"hasPassedTutorial"] boolValue] ? 1 : 0;
        
        self.yTiles = squares[tileCount].y;
        self.xTiles = squares[tileCount].x;
       
        [self updateTileCount];
		
		//No longer used
//        if (![defaults objectForKey:@"hasPassedTutorial"]){
//            [defaults setObject:@(NO) forKey:@"hasPassedTutorial"];
//            [defaults synchronize];
//        }
		
        self.hearts = 3;
        self.level = 1;
        
        timerIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, self.frame.size.width, 10.f)];
        timerIndicatorView.backgroundColor = [UIColor redColor];
        timerIndicatorView.alpha = 0.7f;
        [timerIndicatorView setImage:[UIImage imageNamed:@"Images/tile.png"]];
        timerIndicatorView.layer.borderWidth = 2 / [[UIScreen mainScreen] scale];
        timerIndicatorView.layer.borderColor = [[UIColor blackColor] CGColor];
        [self addSubview:timerIndicatorView];
        
        lblLevel = [[UILabel alloc] initWithFrame:self.bounds];
        [lblLevel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f]];
        [lblLevel setTextAlignment:NSTextAlignmentCenter];
        [lblLevel setNumberOfLines:0];
        [lblLevel setTextColor:[UIColor whiteColor]];
        [lblLevel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:60.f]];
        [lblLevel setText:@"1"];
        lblLevel.alpha = 0.f;
        [self addSubview:lblLevel];
        
        lblGo = [[UILabel alloc] initWithFrame:self.bounds];
        [lblGo setBackgroundColor:[UIColor clearColor]];
        [lblGo setTextAlignment:NSTextAlignmentCenter];
        [lblGo setTextColor:[UIColor whiteColor]];
        [lblGo setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:60.f]];
        [lblGo setText:@"GO!"];
        lblGo.userInteractionEnabled = NO;
        lblGo.alpha = 0.f;
        lblGo.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
        [self addSubview:lblGo];
        
        viwStatus = [[StatusView alloc] initWithFrame:self.bounds];
        [viwStatus setLives:self.hearts withCompletion:nil];
        viwStatus.delegate = self;
        viwStatus.alpha = 0.f;
        [self addSubview:viwStatus];
        
        self.isInterrupted = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SFXSettingsDidChange) name:@"SFXSettingsDidChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption) name:UIApplicationWillResignActiveNotification object:nil];

        self.userInteractionEnabled = NO;
    }
    
    return self;
}

-(float)timeForLevel{
    return levelTiles[self.level] * (levelSpeed[self.level] * 3.5f);
}

-(void)handleInterruption{
    if (self.alpha && !viwStatus.alpha){
        self.isInterrupted = YES;
        if (timeoutTimer) {
            [timeoutTimer invalidate];
            timeoutTimer = nil;
        }
        
        self.gameInProgress = NO;
        
        //reset this level, basically, but don't give the user points for the tiles they've gotten right so far, so someone doesn't use this functionality to cheat
        [self greenout];
        viwTileView.userInteractionEnabled = NO;
        self.score -= correctTiles;
        correctTiles = 0;
        [viwStatus setPoints:self.score];
        [viwStatus setLives:self.hearts];
        [viwStatus setPaused];
        viwStatus.alpha = 1.f;
    }
}

-(void)SFXSettingsDidChange{
    self.SFX = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"SFX"] boolValue];
}

-(void)updateTileCount{
    if (viwTileView) {
        [viwTileView removeFromSuperview];
        viwTileView = nil;
    }

    viwTileView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.f, self.frame.size.width, self.frame.size.height-10.f)];
    [self insertSubview:viwTileView belowSubview:lblLevel];
    viwTileView.userInteractionEnabled = NO;
    
    [tilePaths removeAllObjects];
    
    self.yTiles = squares[tileCount].y;
    self.xTiles = squares[tileCount].x;
    
    CGFloat tileWidth = self.frame.size.width / self.xTiles;
    CGFloat tileHeight = viwTileView.frame.size.height / self.yTiles;
    
    for(int y = 0; y < self.yTiles; y++){
        for (int x = 0; x < self.xTiles; x++) {
            UIImageView *tile = [[UIImageView alloc] init];
            tile.frame = CGRectMake(x * tileWidth, y * tileHeight, tileWidth, tileHeight);
            [tile setImage:[UIImage imageNamed:@"Images/tile.png"]];
            
            tile.layer.borderWidth = 4 / [[UIScreen mainScreen] scale];
            tile.layer.borderColor = [[UIColor blackColor] CGColor];
            
            [viwTileView addSubview:tile];
            [tilePaths addObject:tile];
        }
    }
    
    [self redraw]; //fix the colors
}

-(void)setBorderColor:(UIColor*)color{ //deprecated
    for(UIView *view in viwTileView.subviews){
        [view.layer setBorderColor:color.CGColor];
    }
}

-(void)startLevel{
    
    correctTiles = 0;
    
    if (timeoutTimer) { //User must have missed immediately
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        [timerIndicatorView setFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, self.frame.size.width, 10.f)];
    }
    
    self.Music = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue];
    
    if(self.Music && !self.audioPlayer.playing){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.audioPlayer play];
    }
    
    [UIView animateWithDuration:0.4f animations:^{
        for(int i = 0; i < self.xTiles*self.yTiles; i++){
            [[tilePaths objectAtIndex:i] setAlpha:DARK_ALPHA];
        }
        [self restoreColor];
    } completion:^(BOOL finished){
		
        if (points) {
            free(points);
        }
        
        points = (tileCoordinate*)malloc(sizeof(tileCoordinate)*levelTiles[self.level]);
        int onT = 0;
        
        //Generate a list of random tile coordinates, but make sure no two adjacent tiles are the same
        while(onT < levelTiles[self.level]){
            int x = arc4random_uniform((int)self.xTiles);
            int y = arc4random_uniform((int)self.yTiles);
            
            //NSLog(@"Generated %d, %d", x, y);
            
            if(onT && points[onT-1].x == x && points[onT-1].y == y){
                continue;
            }
            else{
                points[onT] = tileCoordinateMake(x, y);
                onT++;
            }
        }
        
        onT = 0;
        int s = 0;
        if(self.SFX){
            [self loadAudio];
            while(onT < MUSIC_SAMPLES){
                s = arc4random() % MUSIC_SAMPLES;
                
                if(onT && soundPattern[onT-1] == sounds[s]){
                    continue;
                }
                else{
                    soundPattern[onT] = sounds[s];
                    onT++;
                }
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for(int i = 0; i < levelTiles[self.level]; i++){
                tileCoordinate coord = points[i];
                UIView *tile = [tilePaths objectAtIndex:coord.y * self.xTiles + coord.x]; //BREAKING HERE
                
                int second = 1000000; //useconds in a second
                
                if(viwStatus.alpha)   //app was interrupted, this is checked here as well to prevent audio from playing
                    break;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    tile.alpha = 1.f;
                    
                    if (self.SFX)
                        [soundPattern[i] play];
					
                    [UIView animateWithDuration:levelSpeed[self.level] * 2 animations:^{
                        tile.alpha = DARK_ALPHA;
                    }];
                });
                
                usleep(levelSpeed[self.level] * second);
            }
            
            if (viwStatus.alpha) //The app has been interrupted.
                return;
        
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gameInProgress = YES;
               
                //If the user does not tap the correct tiles within twice the amount of time it took to display them, they fail the level
                //Ironically, when there is only a 2x2 board, we give the user *more* time, this is because they flash so fast with little
                //warning that the average user will repeatedly miss the deadline
                
                float time = [self timeForLevel];
                
                timerIndicatorView.backgroundColor = [UIColor greenColor];
                
                [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    timerIndicatorView.alpha = 1.f;
                } completion:^(BOOL finished){
                    timerIndicatorView.alpha = 1.f;
                    [UIView animateWithDuration:0.15f delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        timerIndicatorView.alpha = 0.7f;
                    } completion:^(BOOL finished){
                        
                        if (!viwStatus.alpha && self.gameInProgress){  //It is (intentionally) possible to fail before the timer begins
                            
                            viwTileView.userInteractionEnabled = YES;
                            self.userInteractionEnabled = YES;
                            
                            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                                [timerIndicatorView setFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, self.frame.size.width, 10.f)];
                            } completion:nil];
                            
                            timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timeout) userInfo:nil repeats:NO];
                            [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                                [timerIndicatorView setFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, 0.f, 10.f)];
                            } completion:nil];
                        }
                    }];
                }];
            });
        });
    }];
}

-(void)timeout{
	
    if (viwStatus.alpha || !self.gameInProgress) { //Catch any "runaway timers" that may cause a user to unjustly lose a heart
        return;
    }
	
    [self fail];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (viwStatus.alpha) //Touches seem to have a bad habit of going right through the statusview...
        return;
    
    if (event.allTouches.count > 1) {
        [self handleInterruption];
    }
    else{
        UITouch *touch = touches.anyObject;
        CGPoint tapLocation = [touch locationInView:viwTileView];
    
        CGFloat tileWidth = self.frame.size.width / self.xTiles;
        CGFloat tileHeight = self.frame.size.height / self.yTiles;
        
        int x = tapLocation.x / tileWidth;
        int y = tapLocation.y / tileHeight;
        
        if (self.gameInProgress) {
            if (points[correctTiles].x == x && points[correctTiles].y == y) {
                
                if (self.SFX)
                    [soundPattern[correctTiles] play];
                
                if (self.level)
                    self.score++;
                
                correctTiles++;
                UIView *tile = [tilePaths objectAtIndex:y * self.xTiles + x];
                tile.alpha = 1.f;
                [UIView animateWithDuration:0.4f animations:^{
                    tile.alpha = DARK_ALPHA;
                }];
                
                if (correctTiles == levelTiles[self.level]) {
                    
                    if (timeoutTimer) {
                        [timeoutTimer invalidate];
                        timeoutTimer = nil;
                    }
                    
                    correctTiles = 0;
                    
                    if (self.level == MAX_DIFFICULTY-3 && tileCount < 4) {
                        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"hasPassedTutorial"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        self.level = 1;
                        tileCount++;
                        self.yTiles = squares[tileCount].y;
                        self.xTiles = squares[tileCount].x;
                        [self updateTileCount];
                    }
                    else{
                        if ((tileCount != 4 && self.level < MAX_DIFFICULTY) || self.level < MAX_DIFFICULTY) {
                            self.level++;
                        }
                    }
					
                    if (self.level == 1 || (self.level > 1 && levelTiles[self.level-1] != levelTiles[self.level])) {
                        lblLevel.text = [NSString stringWithFormat:@"%lu\nIn a row", (unsigned long)levelTiles[self.level]];
                        [UIView animateWithDuration:0.2f animations:^{
                            lblLevel.alpha = 1.f;
                        }];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            viwTileView.userInteractionEnabled = NO;
                            [self greenout];
                        });
                        
                        if (lblLevel.alpha)
                            usleep(1000000);
                        else
                            usleep(1000000 * (levelSpeed[self.level] * 2));
                        
                        correctTiles = 0;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (lblLevel.alpha) {
                                [UIView animateWithDuration:0.2f animations:^{
                                    lblLevel.alpha = 0.f;
                                } completion:^(BOOL finished){
                                    //[self restoreColor];
                                }];
                            }
                            //else
                            //[self restoreColor];
                        });
                        
                        usleep(500000);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self startLevel];
                        });
                    });
                }
            }
            else{ //Wrong square tapped
                if (self.SFX){
                    if (self.audioPlayer.playing){
                        [self.audioPlayer stop];
                        [scratch play];
                    }
                    else{
                        [buzzer play];
                    }
                }
                
                [self fail];
            }
        }
    }
}

-(void)fail{
    self.gameInProgress = NO;
    
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
    
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [timerIndicatorView setFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, self.frame.size.width, 10.f)];
        [timerIndicatorView setBackgroundColor:[UIColor redColor]];
    } completion:nil];
    
    if (!(self.hearts-1)){
        self.level = 1;
        tileCount = 1;//[[[NSUserDefaults standardUserDefaults] objectForKey:@"hasPassedTutorial"] boolValue] ? 1 : 0;
        [self updateTileCount];
    }
    
    viwTileView.userInteractionEnabled = NO;
    [self redout];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        usleep(400000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viwStatus setPoints:self.score];
            [viwStatus setLives:self.hearts withCompletion:nil];
            [UIView animateWithDuration:0.2f animations:^{
                viwStatus.alpha = 1.f;
            } completion:^(BOOL finished){
                self.hearts--;
            }];
        });
    });
}

-(void)statusViewDidExitToMenu{
    self.score = 0;
    self.level = 1;
    self.hearts = 3;
    correctTiles = 0;
    
    self.Music = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue];
    
    if(self.Music && !self.audioPlayer.playing){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.audioPlayer play];
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        viwStatus.alpha = 0.f;
        self.alpha = 0.f;
    } completion:^(BOOL finished){
        [viwStatus resetHearts];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGame)]) {
            self.score = 0;
            self.level = 1;
            self.hearts = 3;
            tileCount = 1;
            [self updateTileCount];
            [viwStatus resetHearts];
            [self.delegate didEndGame];
        }
    }];
}

-(void)statusViewDidContinue{
    
    self.Music = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue];
    
    if(self.Music && !self.audioPlayer.playing){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.audioPlayer play];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        viwStatus.alpha = 0.f;
    } completion:^(BOOL finished){
        [self restoreColor];
        [self redraw];
        
        viwTileView.userInteractionEnabled = YES;
        
        if (!self.hearts) {
            self.score = 0;
            self.level = 1;
            self.hearts = 3;
            tileCount = 1;
            [self updateTileCount];
            [viwStatus resetHearts];
        }
        
        [self performSelector:@selector(startLevel) withObject:nil afterDelay:levelSpeed[self.level] * 2];
    }];
}

-(void)cycle{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (1) {
            usleep(200000);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self redraw];
            });
        }
    });
}

-(void)redout{  //No animation on this one, the onset of red is meant to be sudden
    for(int i = 0; i < self.xTiles*self.yTiles; i++){
        [(UIView*)[tilePaths objectAtIndex:i] setBackgroundColor:[UIColor redColor]];
        [[tilePaths objectAtIndex:i] setAlpha:1.f];
    }
}

-(void)greenout{
    [UIView animateWithDuration:levelSpeed[self.level] * 2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [timerIndicatorView setBackgroundColor:[UIColor greenColor]];
        [timerIndicatorView setFrame:CGRectMake(0.0f, self.frame.size.height - 10.f, self.frame.size.width, 10.f)];
        for(int i = 0; i < self.xTiles*self.yTiles; i++){
            [(UIView*)[tilePaths objectAtIndex:i] setBackgroundColor:[UIColor greenColor]]; //[UIColor colorWithRed:0.2f green:0.75f blue:0.2f alpha:1.0f]
            [[tilePaths objectAtIndex:i] setAlpha:1.f];
        }
    } completion:nil];
}

-(void)restoreColor{
    [UIView animateWithDuration:levelSpeed[self.level] * 2 animations:^{
        [timerIndicatorView setBackgroundColor:[UIColor redColor]];
        for(int i = 0; i < self.xTiles*self.yTiles; i++){
            [(UIView*)[tilePaths objectAtIndex:i] setBackgroundColor:[aryColors objectAtIndex:i]];
        }
    }];
}

-(void)redraw{
	
	//Quick n' dirty..
    NSMutableArray *colorPool = [[NSMutableArray alloc] init];
    [colorPool addObject:[UIColor colorWithRed:0xFF / 255.f green:0x00 / 255.f blue:0x00 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0xFF / 255.f green:0x80 / 255.f blue:0x00 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0xFF / 255.f green:0xFF / 255.f blue:0x00 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x80 / 255.f green:0xFF / 255.f blue:0x00 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x00 / 255.f green:0xFF / 255.f blue:0x00 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x00 / 255.f green:0xFF / 255.f blue:0x80 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x80 / 255.f green:0xFF / 255.f blue:0xFF / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x00 / 255.f green:0x80 / 255.f blue:0xFF / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x00 / 255.f green:0x00 / 255.f blue:0xFF / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0x80 / 255.f green:0x00 / 255.f blue:0xFF / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0xFF / 255.f green:0x00 / 255.f blue:0xFF / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0xFF / 255.f green:0x00 / 255.f blue:0x80 / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:43.f / 255.f green:0 blue:183.f / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:145.f / 255.f green:21.f / 255.f blue:0 alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:183.f / 255.f green:0 blue:183.f / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:0 green:208.f / 255.f blue:208.f / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:255.f / 255.f green:206.f / 255.f blue:73.f / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:85.f / 255.f green:175.f / 255.f blue:0 alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:75.f / 255.f green:0 blue:215.f / 255.f alpha:1.f]];
    [colorPool addObject:[UIColor colorWithRed:214.f / 255.f green:255.f / 255.f blue:48.f / 255.f alpha:1.f]];
    
    NSUInteger count = [colorPool count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [colorPool exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    [aryColors removeAllObjects];
    for(int i = 0; i < self.xTiles*self.yTiles; i++){
        
        [aryColors addObject:[colorPool objectAtIndex:i]];
        [(UIView*)[tilePaths objectAtIndex:i] setBackgroundColor:[aryColors objectAtIndex:i]];
        [[tilePaths objectAtIndex:i] setAlpha:1.f];
    }
}


@end
