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

@interface LWPINPresenter () <LWPINButtonViewDelegate>
{
    NSString *pin;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LWPINEnterProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *fingerprintContainerView;

@end

@implementation LWPINPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    pin=@"";
    [self checkSubviews:self.view];
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
        }
        [self checkSubviews:v];
    }

}

-(void) pinButtonViewPressedButtonWithSymbol:(NSString *)symbol
{
    pin=[pin stringByAppendingString:symbol];
    [self.progressView setNumberOfSymbols:(int)pin.length];
    if(pin.length==4)
    {
        if(self.pinType==PIN_TYPE_ENTER)
        {
            self.finishBlock(YES, pin);
            return;
        }
        
        
        
        pin=@"";
        [self.progressView setNumberOfSymbols:(int)pin.length];

        [self animateFailureNotificationDirection:-35];
        return;
    }

}

-(void) pinButtonPressedFingerPrint
{
    if(self.pinType==PIN_TYPE_ENTER || [LWFingerprintHelper isFingerprintAvailable]==NO)
        return;
    
}

-(void) pinButtonViewPressedDelete
{
    if(pin.length>0)
        pin=[pin substringToIndex:pin.length-1];
    [self.progressView setNumberOfSymbols:(int)pin.length];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(self.pinType==PIN_TYPE_ENTER)
        self.fingerprintContainerView.hidden=YES;
    pin=@"";
    [self deselectButtons:self.view];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
