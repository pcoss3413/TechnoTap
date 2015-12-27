//
//  ViewController.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/13/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "RootViewController.h"
#import "ColorTapGameView.h"
#import "UIImageButton.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

@interface RootViewController () <ColorTapGameViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) ColorTapGameView *gameView;

@property (nonatomic, weak) IBOutlet UIImageButton *btnStart;
@property (nonatomic, weak) IBOutlet UIImageButton *btnScoreboard;
@property (nonatomic, weak) IBOutlet UIImageButton *btnHelp;
@property (nonatomic, weak) IBOutlet UIButton *btnSettings;
@property (nonatomic, weak) IBOutlet UILabel *lblCopyright;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UIImageView *introImage;
@property (nonatomic, strong) NSTimer *colorTimer;
@property (nonatomic, strong) NSTimer *musicTimer;

@property (nonatomic, assign) BOOL isFirstRun;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstRun = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"settings"]) {
        self.isFirstRun = YES;
        [defaults setObject:@{@"music":@(NO), @"SFX":@(YES)} forKey:@"settings"];
        [defaults synchronize];
        [ScoreboardManager setAlltimeBest:0];
    }
	
    self.gameView = [[ColorTapGameView alloc] initWithFrame:self.view.bounds];
    self.gameView.backgroundColor = [UIColor blackColor];
    self.gameView.userInteractionEnabled = NO;
    self.gameView.delegate = self;
    [self.gameView redraw];
    [self.view addSubview:self.gameView];
    
    self.gameView.alpha = 0.f;
    [self.gameView setTilesHidden:YES];
    
    CGFloat height = MAX(self.view.frame.size.height, self.view.frame.size.width);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    self.introImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.introImage.backgroundColor = [UIColor greenColor];
    
    //I don't like doing it like this, but this is a rush project and I've spent too much time trying to figure the 'right' way to do this
    if (scale == 2 && height == 568)
        [self.introImage setImage:[UIImage imageNamed:@"Images/intro-568h@2x.png"]];
    else if (scale == 2 && height == 667)
        [self.introImage setImage:[UIImage imageNamed:@"Images/intro-667h@2x.png"]];
    else if (scale == 3 && height == 736)
        [self.introImage setImage:[UIImage imageNamed:@"Images/intro@3x.png"]];
    else
        [self.introImage setImage:[UIImage imageNamed:@"Images/intro.png"]];
    
    [self.view insertSubview:self.introImage atIndex:0];
    
    [self.btnStart setBackgroundImage:[UIImage imageNamed:@"Images/start.png"]];
    [self.btnScoreboard setBackgroundImage:[UIImage imageNamed:@"Images/score.png"]];
    [self.btnHelp setBackgroundImage:[UIImage imageNamed:@"Images/help.png"]];
    
    [self.btnStart setCornerRadius:10.f];
    [self.btnScoreboard setCornerRadius:10.f];
    [self.btnHelp setCornerRadius:10.f];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange) name:@"MucicSettingsDidChangeNotification" object:nil];
    
    if ([[[defaults objectForKey:@"settings"] objectForKey:@"music"] boolValue]){
        [self createMusicPlayer];
        [self.audioPlayer play];
    }
}

-(void)helpviewDidDismiss{
    if (viwHelp) {
        [viwHelp removeFromSuperview];
        viwHelp = nil;
    }
}

-(void)showEmailController{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setToRecipients:[NSArray arrayWithObject:@"<email address here>"]];
    [picker setSubject:@"About Techno Tap"];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.btnHelp.alpha = 1.f;
        self.btnScoreboard.alpha = 1.f;
        self.btnSettings.alpha = 1.f;
        self.btnStart.alpha = 1.f;
        self.lblCopyright.alpha = 1.f;
    } completion:^(BOOL finished){
        if (self.isFirstRun) {
            [self helpPressed:nil];
        }
    }];
}

-(void)createMusicPlayer{     //We have this in it's own function because if the audio is OFF and the user is playing music,
    if (!self.audioPlayer){   //initializing the player will silence the user's music (The same happens when using Finch for SFX)
        NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Audio/distance" ofType:@"wav"]];
        NSError *error;
        
        //Make sure our music doesn't overlap the user's music
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:&error];
        self.audioPlayer.numberOfLoops = -1;
        self.audioPlayer.volume = 0.35f;
        
        if (self.musicTimer){
            [self.musicTimer invalidate];
            self.musicTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(transitionMusic) userInfo:nil repeats:NO];
        }
        
        self.gameView.audioPlayer = self.audioPlayer;
    }
}

-(void)transitionMusic{
	
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while(self.audioPlayer.volume && self.audioPlayer){
            usleep(1000);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.audioPlayer.volume -= 0.05f;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Start new audio player with different song here!
            if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue]){
                
            }
        });
    });
}

-(void)didEndGame{
    [self.gameView redraw];
}

-(IBAction)helpPressed:(id)sender{

    if (viwHelp) { //This should never happen, but its here just incase!
        [viwHelp removeFromSuperview];
        viwHelp = nil;
    }
    
    viwHelp = [[UIHelpView alloc] initWithFrame:self.view.bounds];
    viwHelp.delegate = self;
    [self.view addSubview:viwHelp];
    
    [viwHelp show];
}

-(void)scoreboardDidDismiss{
    if (viwScoreboard) {
        [viwScoreboard removeFromSuperview];
        viwScoreboard = nil;
    }
}

-(IBAction)scoreboardPressed:(id)sender{
    
    if (viwScoreboard) { //This should never happen, but its here just incase!
        [viwScoreboard removeFromSuperview];
        viwScoreboard = nil;
    }
    
    viwScoreboard = [[UIScoreboard alloc] initWithFrame:self.view.bounds timePeriod:timePeriodForever];
    viwScoreboard.delegate = self;
    viwScoreboard.autoUpdate = YES;
    [self.view addSubview:viwScoreboard];
    
    [viwScoreboard show];
}

-(void)settingsDidChange{
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"] objectForKey:@"music"] boolValue]){
        [self createMusicPlayer];
        [self.audioPlayer play];
    }
    else{
        if (self.audioPlayer)
            [self.audioPlayer stop];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.colorTimer)
        self.colorTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.colorTimer invalidate];
    self.colorTimer = nil;
}

-(void)changeColor{
    
    static unsigned int onColor = 0;
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
    
    [UIView animateWithDuration:1.f animations:^{
        [self.introImage setBackgroundColor:[colorPool objectAtIndex:onColor % [colorPool count]]];
    }];
    
    onColor++;
}

-(IBAction)showSettings:(id)sender{
    UISettingsView *viwSettings = [[UISettingsView alloc] initWithFrame:self.view.bounds];
    viwSettings.delegate = self;
    [self.view addSubview:viwSettings];

    [viwSettings show];
    
    [UIView animateWithDuration:1.0f animations:^(void){
        self.btnSettings.transform = CGAffineTransformMakeRotation(3.14159f);
    }];
}

-(void)didSaveSettings:(id)settingsView{
    if (settingsView) {
        [settingsView hideWithCompletion:^{
            [settingsView removeFromSuperview];
        }];
        
        [UIView animateWithDuration:1.0f animations:^(void){
            self.btnSettings.transform = CGAffineTransformMakeRotation(0.f);
        }];
    }
}

-(void)musicSettingDidChange:(BOOL)musicIsEnabled{
    if (musicIsEnabled){
        [self createMusicPlayer];
        [self.audioPlayer play];
    }
    else if (self.audioPlayer)
        [self.audioPlayer stop];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
}

-(void)SFXSettingDidChange:(BOOL)SFXAreEnabled{
    self.gameView.SFX = SFXAreEnabled;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(IBAction)startGame:(id)sender{
    [UIView animateWithDuration:0.5f animations:^{
        self.gameView.alpha = 1.f;
        
        
    } completion:^(BOOL finished){
        [self.gameView updateTileCount];
        self.gameView.userInteractionEnabled = YES;
        [self.gameView redraw];
        [self.gameView startLevel];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
