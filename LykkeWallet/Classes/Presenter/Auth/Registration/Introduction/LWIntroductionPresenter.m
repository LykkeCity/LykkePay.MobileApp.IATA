//
//  LWIntroductionPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWIntroductionPresenter.h"
#import "LWIntroductionProgressView.h"
#import "LWAnimatedView.h"
#import "LWValidator.h"
#import "Macro.h"

@interface LWIntroductionPresenter ()
{
    NSArray *titles;
    
    NSArray *texts;
    
    NSArray *animations;
    int currentSlide;
    LWAnimatedView *currentAnimatedView;
    
    NSMutableArray *animationViews;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet LWIntroductionProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *animatedViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UIView *textsContainer;
@property (weak, nonatomic) IBOutlet UIButton *whyDoINeedItButton;

@end

@implementation LWIntroductionPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds=YES;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroductionShown"];
    
    titles=@[
            Localize(@"introduction.titles.deposit"),
            Localize(@"introduction.titles.trade"),
            Localize(@"introduction.titles.settle"),
            Localize(@"introduction.titles.withdraw"),
            Localize(@"introduction.titles.onboard")
    ];
    
    texts=@[
            Localize(@"introduction.texts.deposit"),
            Localize(@"introduction.texts.trade"),
            Localize(@"introduction.texts.settle"),
            Localize(@"introduction.texts.withdraw"),
            Localize(@"introduction.texts.onboard")
            
            ];
    
    animations=@[
                 @"1-deposit-2x",
                 @"2-trade-2x",
                 @"3-settle-2x",
                 @"4-withdraw-2x",
                 @"5-onboard-2x"
                 
                 ];
    
    animationViews=[[NSMutableArray alloc] init];
    for(NSString *s in animations)
    {
        LWAnimatedView *view=[[LWAnimatedView alloc] initWithFrame:self.animatedViewContainer.bounds name:s];
        [animationViews addObject:view];
    }
    
    [self.whyDoINeedItButton setTitle:Localize(@"introduction.buttons.whydoineedit") forState:UIControlStateNormal];
    
    NSDictionary *attributes = @{NSKernAttributeName:@(1), NSFontAttributeName:self.getStartedButton.titleLabel.font, NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSAttributedString *string=[[NSAttributedString alloc] initWithString:Localize(@"introduction.buttons.getstarted") attributes:attributes];
    [self.getStartedButton setAttributedTitle:string forState:UIControlStateNormal];
    
    [LWValidator setButton:self.getStartedButton enabled:YES];
    
    UISwipeGestureRecognizer *gesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
    gesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gesture];
    
    gesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
    gesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gesture];

    
    currentSlide=0;
    [self.progressView setActiveDot:currentSlide];
    self.view.userInteractionEnabled=YES;
    // Do any additional setup after loading the view from its nib.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setCurrentTitles];
    

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) setCurrentTitles
{
    NSDictionary *attributesTitle = @{NSKernAttributeName:@(1.5), NSFontAttributeName:self.titleLabel.font, NSForegroundColorAttributeName:self.titleLabel.textColor};

    NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc] init];
    style.lineSpacing=8;
    [style setAlignment:NSTextAlignmentCenter];
    
    self.titleLabel.attributedText=[[NSAttributedString alloc] initWithString:titles[currentSlide] attributes:attributesTitle];
    NSDictionary *attrText=@{NSParagraphStyleAttributeName:style, NSFontAttributeName:self.textLabel.font, NSForegroundColorAttributeName:self.textLabel.textColor};
//    self.textLabel.text=texts[currentSlide];
    self.textLabel.attributedText=[[NSAttributedString alloc] initWithString:texts[currentSlide] attributes:attrText];
 
}

-(void) viewDidLayoutSubviews
{
    if(currentAnimatedView)
        return;
    [currentAnimatedView removeFromSuperview];
    
    currentAnimatedView=animationViews[currentSlide];
    [self.animatedViewContainer addSubview:currentAnimatedView];
    [currentAnimatedView startAnimationIfNeeded];

}

-(void) swipedLeft
{
    if(currentSlide==4)
        return;
    currentSlide++;
    [self animateSwipeWithDirection:1];
}

-(void) swipedRight
{
    if(currentSlide==0)
        return;
    currentSlide--;

    [self animateSwipeWithDirection:-1];
}

-(void) animateSwipeWithDirection:(int) direction
{
    self.view.userInteractionEnabled=NO;
    [self.progressView setActiveDot:currentSlide];
    
    self.whyDoINeedItButton.hidden=YES;

    UIImage *prevImage=[self imageWithView:self.textsContainer];
    [self setCurrentTitles];
    UIImage *nextImage=[self imageWithView:self.textsContainer];
    
    UIImageView *prevImageView=[[UIImageView alloc] initWithFrame:self.textsContainer.bounds];
    prevImageView.image=prevImage;
    UIImageView *nextImageView=[[UIImageView alloc] initWithFrame:self.textsContainer.bounds];
    nextImageView.image=nextImage;
    nextImageView.center=CGPointMake(nextImageView.center.x+self.view.bounds.size.width*direction, nextImageView.center.y);
    
    [self.textsContainer addSubview:prevImageView];
    [self.textsContainer addSubview:nextImageView];
    
    LWAnimatedView *nextAnimatedView=animationViews[currentSlide];
    nextAnimatedView.frame=self.animatedViewContainer.bounds;
    nextAnimatedView.center=CGPointMake(nextAnimatedView.center.x+self.view.bounds.size.width*direction, nextAnimatedView.center.y);
    [self.animatedViewContainer addSubview:nextAnimatedView];

    
    self.titleLabel.hidden=YES;
    self.textLabel.hidden=YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        nextImageView.center=CGPointMake(nextImageView.center.x-self.view.bounds.size.width*direction, nextImageView.center.y);
        prevImageView.center=CGPointMake(prevImageView.center.x-self.view.bounds.size.width*direction, prevImageView.center.y);
        currentAnimatedView.center=CGPointMake(currentAnimatedView.center.x-self.view.bounds.size.width*direction, currentAnimatedView.center.y);
        nextAnimatedView.center=CGPointMake(nextAnimatedView.center.x-self.view.bounds.size.width*direction, nextAnimatedView.center.y);
        
        
        
    } completion:^(BOOL finished){
        
        [nextImageView removeFromSuperview];
        [prevImageView removeFromSuperview];
        [currentAnimatedView removeFromSuperview];

        [nextAnimatedView startAnimationIfNeeded];
        currentAnimatedView=nextAnimatedView;
        
        self.titleLabel.hidden=NO;
        self.textLabel.hidden=NO;
        
        self.view.userInteractionEnabled=YES;
        
//        if(currentSlide==4)
//            self.whyDoINeedItButton.hidden=NO;
        
    }];

}

-(IBAction) whyDoINeedItButtonPressed:(UIButton *) button
{
    
}

-(IBAction) getStartedButtonPressed:(id)sender
{
    [self.delegate introductionPresenterShouldDismiss:self];
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
