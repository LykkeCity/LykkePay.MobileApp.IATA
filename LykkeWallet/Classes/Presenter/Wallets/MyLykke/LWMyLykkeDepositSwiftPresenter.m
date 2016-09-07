//
//  LWMyLykkeDepositSwiftPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeDepositSwiftPresenter.h"

#import "LWCommonButton.h"
#import "UIViewController+Navigation.h"
#import "LWConstants.h"
#import "UIView+Toast.h"
#import "UIViewController+Loading.h"
#import "LWCache.h"
#import "LWKeychainManager.h"
#import "LWUtils.h"
#import "LWNumbersKeyboardView.h"
#import "LWCache.h"
#import "LWWebViewDocumentPresenter.h"
#import "LWSwiftCredentialsModel.h"


@interface LWMyLykkeDepositSwiftPresenter () <UITextFieldDelegate, LWMathKeyboardViewDelegate, LWNumbersKeyboardViewDelegate>
{
    LWNumbersKeyboardView *keyboard;
    BOOL keyboardIsVisible;
    NSArray *lineValues;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bicLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *emailButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *amountContainer;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewWidthConstraint;

@end

@implementation LWMyLykkeDepositSwiftPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];

    NSString *login=[[LWKeychainManager instance].login stringByReplacingOccurrencesOfString:@"@" withString:@"."];
    
    LWSwiftCredentialsModel *swiftCreds=[LWCache instance].swiftCredentialsDict[@"CHF"];
    self.bicLabel.text=swiftCreds.bic;
    self.accountNumberLabel.text=swiftCreds.accountNumber;
    self.accountNameLabel.text=swiftCreds.accountName;

    NSString *purposeTemp=[swiftCreds.purposeOfPayment stringByReplacingOccurrencesOfString:@"{0}" withString:@"%@"];
    purposeTemp=[purposeTemp stringByReplacingOccurrencesOfString:@"{1}" withString:@"%@"];

    
    self.purposeLabel.text=[NSString stringWithFormat:purposeTemp, @"CHF", login];
    self.emailButton.type=BUTTON_TYPE_COLORED;
    self.emailButton.enabled=YES;
    self.textField.delegate=self;
    self.textField.text=[self formatVolume:[@(self.amount) stringValue]];
    self.textField.font=[UIFont fontWithName:@"ProximaNova-Light" size:22];
    keyboardIsVisible=NO;
    
    
    lineValues=@[swiftCreds.bic, swiftCreds.accountNumber, swiftCreds.accountName, @"80-165 421-0", _purposeLabel.text];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIColor *color = [UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:color];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:YES];

    [self orientationChanged];
    [self setBackButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.title=@"BUY LYKKE";
    else
        self.navigationController.title=@"PURCHASE LKK WITH CHF";
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
    if(keyboardIsVisible)
        return NO;
    keyboard=[[LWNumbersKeyboardView alloc] init];
    keyboard.showDoneButton=YES;
    keyboard.showDotButton=YES;
    keyboard.showPredefinedSums=YES;
    keyboard.delegate=self;
    keyboard.accuracy=[LWCache accuracyForAssetId:@"CHF"];
    float coeff=0.776;
    if([UIScreen mainScreen].bounds.size.width==320)
        coeff=0.65;
    keyboard.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.width*coeff);
    [self.view addSubview:keyboard];
//    [self.view layoutSubviews];
    
    keyboard.textField=textField;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.buttonBottomConstraint.constant=self.view.bounds.size.height-(((_amountContainer.frame.origin.y+_amountContainer.bounds.size.height)+(self.view.bounds.size.height-keyboard.bounds.size.height))/2+22.5);
        
        [UIView animateWithDuration:0.3 animations:^{
            keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y-keyboard.bounds.size.height);
            [self.view layoutIfNeeded];
        }];
        
        keyboardIsVisible=YES;
        
        self.scrollView.hidden=YES;

    });
    
    
    return NO;
}

-(void) numbersKeyboardViewPressedDone
{
    [self hideCustomKeyboard];
}

-(void) hideCustomKeyboard
{
    self.buttonBottomConstraint.constant=30;
    
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y+keyboard.bounds.size.height);
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished){
        [keyboard removeFromSuperview];
        keyboard=nil;
        
    }];
    keyboardIsVisible=NO;
    self.scrollView.hidden=NO;

}


-(IBAction) copyPressed:(UIButton *)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:lineValues[sender.tag]];
//    [self showCopied];
    
    [self.view makeToast:@"Copied."];

}


-(void) numbersKeyboardChangedText:(LWNumbersKeyboardView *) keyboard
{
    
    
    if([[self removePrefix:self.textField.text] doubleValue]>0)
        _emailButton.enabled=YES;
    else
        _emailButton.enabled=NO;
    
    self.textField.text=[self formatVolume:[self removePrefix:_textField.text]];
}


-(NSString *) formatVolume:(NSString *) vol
{
    NSString *volume=[vol copy];
    NSString *leftPart;
    NSString *rightPart;
    NSArray *arr=[volume componentsSeparatedByString:@"."];
    if(arr.count!=2)
        leftPart=volume;
    else
    {
        leftPart=arr[0];
        rightPart=arr[1];
    }
    NSString *string=[LWUtils formatVolumeString:leftPart currencySign:@"" accuracy:0 removeExtraZeroes:NO];
    leftPart=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
    if(rightPart)
        volume=[NSString stringWithFormat:@"%@.%@", leftPart, rightPart];
    else
        volume=leftPart;
    
    volume=[@"₣ " stringByAppendingString:volume];
    
    return volume;
}


-(IBAction)emailButtonPressed:(id)sender
{
    NSString *sum=[self removePrefix:_textField.text];
    if(sum.doubleValue==0)
        return;
//    [self hideCustomKeyboard];
    [self setLoading:YES];
    
    [[LWAuthManager instance] requestCurrencyDepositForAsset:@"CHF" changeValue:@(sum.doubleValue)];
}

#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void) authManager:(LWAuthManager *) manager didGetCurrencyDeposit:(LWPacketCurrencyDeposit *) pack
{
    [self setLoading:NO];
    
    [self.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}


-(NSString *) removePrefix:(NSString *) string
{
    string=[string stringByReplacingOccurrencesOfString:@"₣ " withString:@""];
    string=[string stringByReplacingOccurrencesOfString:@"," withString:@""];
    string=[string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

-(void) orientationChanged
{
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        self.scrollViewWidthConstraint.constant=460;
    }
    else
        self.scrollViewWidthConstraint.constant=576;
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)termsOfUsePressed:(id)sender
{
    LWWebViewDocumentPresenter *presenter=[[LWWebViewDocumentPresenter alloc] init];
    presenter.urlString=[LWCache instance].termsOfUseUrl;
    presenter.documentTitle=@"TERMS OF USE";
    [self.navigationController pushViewController:presenter animated:YES];
}

-(IBAction)placementMemorandumPressed:(id)sender
{
    LWWebViewDocumentPresenter *presenter=[[LWWebViewDocumentPresenter alloc] init];
    presenter.urlString=[LWCache instance].informationBrochureUrl;
    presenter.documentTitle=@"INFORMATION BROCHURE";
    [self.navigationController pushViewController:presenter animated:YES];

}




@end
