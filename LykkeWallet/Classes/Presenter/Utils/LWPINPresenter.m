//
//  LWPINPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPINPresenter.h"
#import "LWPINButtonView.h"
#import "LWPINEnterProgressView.h"
#import "LWFingerprintHelper.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Navigation.h"

@interface LWPINPresenter () <LWPINButtonViewDelegate>
{
    NSString *pin;
    int numberOfTries;
    BOOL flagRepeat;
    NSString *firstPINEnter;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LWPINEnterProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *fingerprintContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ipadTopConstraint;

@end

@implementation LWPINPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkSubviews:self.view];
    
    if([LWFingerprintHelper isFingerprintAvailable]==NO)
        _fingerprintContainerView.hidden=YES;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}


-(void) checkSubviews:(UIView *) view
{
    for(UIView *v in view.subviews)
    {
        if([v isKindOfClass:[LWPINButtonView class]])
        {
            [(LWPINButtonView *)v setDelegate:self];
        }
        if(v.tag==2 && [v isKindOfClass:[UILabel class]])
        {
            NSDictionary *attributes=@{NSKernAttributeName:@(2), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:12]};
            [(UILabel *)v setAttributedText:[[NSAttributedString alloc] initWithString:[(UILabel *)v text] attributes:attributes]];
            continue;
        }
        [self checkSubviews:v];
    }
}

-(void) deselectButtons:(UIView *) view
{
    for(UIView *v in view.subviews)
    {
        if([v isKindOfClass:[LWPINButtonView class]])
        {
            v.backgroundColor=[UIColor whiteColor];
            continue;
        }
        [self deselectButtons:v];
    }

}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if([LWFingerprintHelper isFingerprintAvailable])
        [self pinButtonPressedFingerPrint];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void) pinButtonViewPressedButtonWithSymbol:(NSString *)symbol
{
    pin=[pin stringByAppendingString:symbol];
    [self.progressView setNumberOfSymbols:(int)pin.length];
    if(pin.length==4)
    {
        if(self.pinType==PIN_TYPE_ENTER)
        {
            if(flagRepeat==NO)
            {
                flagRepeat=YES;
                firstPINEnter=pin;
                pin=@"";
                [self.progressView setNumberOfSymbols:(int)pin.length];
                [self adjustTitle];
                return;
            }
            else
            {

                if([pin isEqualToString:firstPINEnter]==NO)
                {
                    flagRepeat=NO;

                    pin=@"";
                    [self.progressView setNumberOfSymbols:(int)pin.length];

                    [self animateFailureNotificationDirection:-35];
                    [self adjustTitle];

                }
                else
                {
                    self.pinEnteredBlock(pin);
                }
            }
            
            return;
        }
        
        if(_checkBlock(pin))
        {
            _successBlock();
            return;
        }
        else
        {
            numberOfTries++;
            if(numberOfTries==3)
            {
                id navigationController=self.navigationController;
                if(navigationController)
                    [(LWAuthNavigationController *)self.navigationController logout];
                else
                    [(LWAuthNavigationController *)self.presentingViewController logout];
                return;
            }
            pin=@"";
            [self.progressView setNumberOfSymbols:(int)pin.length];
            
            [self animateFailureNotificationDirection:-35];
        }
        
    }

}

-(void) pinButtonPressedFingerPrint
{
    if(self.pinType==PIN_TYPE_ENTER || [LWFingerprintHelper isFingerprintAvailable]==NO)
        return;
    [LWFingerprintHelper validateFingerprintTitle:Localize(@"auth.validation.fingerpring") ok:^{
        _successBlock();
    
    } bad:^{} unavailable:nil];
}

-(void) pinButtonViewPressedDelete
{
    if(pin.length>0)
        pin=[pin substringToIndex:pin.length-1];
    [self.progressView setNumberOfSymbols:(int)pin.length];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    pin=@"";
    flagRepeat=NO;
    numberOfTries=0;
    [self adjustTitle];


    if(self.pinType==PIN_TYPE_ENTER)
        self.fingerprintContainerView.hidden=YES;
    
    [self.progressView setNumberOfSymbols:(int)pin.length];
    [self deselectButtons:self.view];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [self orientationChanged];

}

-(void) viewDidLayoutSubviews
{
    CGRect rrr=self.titleLabel.frame;
    
    rrr=self.titleLabel.frame;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) animateFailureNotificationDirection:(CGFloat)direction
{
    
    [UIView animateWithDuration:0.08 animations:^{
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(direction, 0);
        
        self.progressView.layer.affineTransform = transform;
        
        
    } completion:^(BOOL finished) {
        if(fabs(direction) < 1) {
            self.progressView.layer.affineTransform = CGAffineTransformIdentity;
            return;
        }
        [self animateFailureNotificationDirection:-1 * direction / 2];
    }];
}

-(void) adjustTitle
{
    if(self.pinType==PIN_TYPE_ENTER)
    {
        if(flagRepeat==NO)
            self.titleLabel.text=@"Create a new PIN to secure your transactions";
        else
            self.titleLabel.text=@"Verify your PIN";
    }
    else
        self.titleLabel.text=@"Enter PIN";

}


-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWPINPresenter_iphone5";
    else if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad && _flagIPadPopup.boolValue==NO)
        return @"LWPINPresenter_ipad";
    else
        return @"LWPINPresenter";
}

-(void) orientationChanged
{
    if(_flagIPadPopup.boolValue)
        return;
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        _ipadTopConstraint.constant=250;
    }
    else
        _ipadTopConstraint.constant=68;
}




@end
