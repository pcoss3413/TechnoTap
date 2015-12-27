//
//  UIHelpView
//  ColorTap
//
//  Created by Patrick Cossette on 5/4/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//
#import "UIHelpView.h"

@implementation UIHelpView

-(id)initWithFrame:(CGRect)frame{  //forever, last hour
    if ((self = [super initWithFrame:frame])) {
        
        self.alpha = 0.f;
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 15.f, self.frame.size.width-30.f, self.frame.size.height-30.f)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.borderWidth = 2.f / [[UIScreen mainScreen] scale];
        contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        contentView.layer.cornerRadius = 15.f;
        
        lblScores = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, contentView.frame.size.width, 35.f)];
        lblScores.textAlignment = NSTextAlignmentCenter;
        [lblScores setText:@"-- how to play --"];
        [lblScores setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:22.f]];
        [lblScores setBackgroundColor:[UIColor clearColor]];
        [lblScores setTextColor:[UIColor blackColor]];
        [contentView addSubview:lblScores];
        
        
        btnDone = [[UIImageButton alloc] initWithFrame:CGRectMake((contentView.frame.size.width - 205.f) / 2.f, contentView.frame.size.height - 40.f - 10.f, 205.f, 40.f)];
        [btnDone addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnDone setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] forState:UIControlStateHighlighted];
        [btnDone.titleLabel setFont:[UIFont fontWithName:@"GoodTimesRg-Regular" size:15.f]];
        [btnDone setBackgroundImage:[UIImage imageNamed:@"Images/help.png"]];
        [btnDone setTitle:@"Ok, Got it!" forState:UIControlStateNormal];
        [btnDone setCornerRadius:10.f];
        [contentView addSubview:btnDone];
        
        
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, lblScores.frame.origin.y + lblScores.frame.size.height + 5.f , contentView.frame.size.width, contentView.frame.size.height - (lblScores.frame.origin.y + lblScores.frame.size.height) - (contentView.frame.size.height - btnDone.frame.origin.y + 25))];
        scrollview.backgroundColor = [UIColor whiteColor];
        scrollview.pagingEnabled = YES;
        scrollview.delegate = self;
        scrollview.showsHorizontalScrollIndicator = NO;
        scrollview.contentSize = CGSizeMake(scrollview.frame.size.width * 5, scrollview.frame.size.height);
        [contentView addSubview:scrollview];
        
        for(int i = 0; i < 4; i++){
            UIImageView *helpImage = [[UIImageView alloc] initWithFrame:CGRectMake(i*scrollview.frame.size.width, 0, scrollview.frame.size.width, scrollview.frame.size.height)];
            helpImage.contentMode = UIViewContentModeScaleAspectFit;
            [helpImage setImage:[UIImage imageNamed:[self imageNameForDevice:[NSString stringWithFormat:@"Images/Help/help%d", i+1]]]];
            helpImage.layer.masksToBounds = YES;
            helpImage.layer.cornerRadius = 15.f;
            helpImage.clipsToBounds = YES;
            [scrollview addSubview:helpImage];
        }
        
        txtAbout = [[UITextView alloc] initWithFrame:CGRectMake(scrollview.frame.size.width*4, 0, scrollview.frame.size.width, scrollview.frame.size.height)];
        [txtAbout setEditable:NO];
        [txtAbout setContentInset:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)];
        [txtAbout setDataDetectorTypes:UIDataDetectorTypeLink];
        [txtAbout setScrollEnabled:NO];
        
        NSMutableAttributedString *aboutText = [NSMutableAttributedString new];
        [aboutText appendAttributedString:[[NSAttributedString alloc] initWithString:
                                           @"Created by Patrick Cossette of Digital Discrepancy.\n\nFlags by: www.icondrawer.com\n\nFind a bug? Have questions or comments? Feel free to " attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GoodTimesRg-Regular" size:16.f]}]];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:@"contact us." attributes:@{@"contactUsTag" : @(YES), NSFontAttributeName:[UIFont fontWithName:@"GoodTimesRg-Regular" size:16.f], NSForegroundColorAttributeName:[UIColor blueColor]}];
     
        [aboutText appendAttributedString:attributedString];
        
    
        [txtAbout setAttributedText:aboutText];
        
        UITapGestureRecognizer *textTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        [txtAbout addGestureRecognizer:textTapRecognizer];
        
        [scrollview addSubview:txtAbout];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(scrollview.frame.origin.x, scrollview.frame.origin.y + scrollview.frame.size.height + 4, scrollview.frame.size.width, 15.f)];
        [pageControl setNumberOfPages:5];
        [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
        pageControl.defersCurrentPageDisplay = NO;
        [pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:pageControl];

        
        [self addSubview:contentView];
        contentView.layer.transform = CATransform3DMakeScale(0.4f, 0.4f, 0.4f);
    }
    
    return self;
}

- (void)changePage{
    NSInteger page = pageControl.currentPage;
    CGRect frame = scrollview.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollview scrollRectToVisible:frame animated:YES];
}

- (void)textTapped:(UITapGestureRecognizer *)recognizer{
    UITextView *textView = (UITextView *)recognizer.view;
	
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        
        NSRange range;
        id value = [textView.attributedText attribute:@"contactUsTag" atIndex:characterIndex effectiveRange:&range];
        
        if (value && self.delegate && [self.delegate respondsToSelector:@selector(showEmailController)]) {
            [self.delegate showEmailController];
        }
    }
}

-(NSString*)imageNameForDevice:(NSString*)name{
    CGFloat height = MAX(self.frame.size.height, self.frame.size.width);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    //Because iOS can't seem to figure this out on it's own. Or maybe I'm doing something wrong? idk. This works.
    if (scale == 2 && height == 568)
        return [NSString stringWithFormat:@"%@-568h@2x.png", name];
    else if (scale == 2 && height == 667)
        return [NSString stringWithFormat:@"%@-667h@2x.png", name];
    else if (scale == 3 && height == 736)
        return [NSString stringWithFormat:@"%@@3x", name];
   
    return name;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //static int previousPage = 0;
    int page = scrollView.contentOffset.x / scrollview.frame.size.width;
    [pageControl setCurrentPage:page];
    
    if (page == 4)
         [lblScores setText:@"-- about --"];
    else
         [lblScores setText:@"-- how to play --"];
}

-(void)exit{
    [self hideWithCompletion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(helpviewDidDismiss)]){
            [self.delegate helpviewDidDismiss];
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
        }];
    }];
}


@end
