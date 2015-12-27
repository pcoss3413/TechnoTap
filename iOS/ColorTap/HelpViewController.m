//
//  HelpViewController.m
//  ColorTap
//
//  Created by Patrick Cossette on 5/2/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(IBAction)cancelPressed:(id)sender{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)contactUsPressed:(id)sender{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setToRecipients:[NSArray arrayWithObject:@"patrick@digitaldiscrepancy.com"]];
    [picker setSubject:@"About Techno Tap"];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
