//
//  LWMyLykkeBuyBitcoinPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeBuyAssetPresenter.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"

#import "LWNumbersKeyboardView.h"
#import "LWCommonButton.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "LWAssetPairRateModel.h"
#import "LWPacketAllAssetPairsRates.h"
#import "LWMyLykkeDepositBTCPresenter.h"
#import "LWAssetPairModel.h"
#import "LWMyLykkeDepositSwiftPresenter.h"
#import "LWMyLykkeCreditCardDepositPresenter.h"
#import "LWPacketOrderBook.h"

#define LKK_PREFIX @"LKK "


@interface LWMyLykkeBuyAssetPresenter () <UITextFieldDelegate, LWNumbersKeyboardViewDelegate>
{
    double price;
    BOOL lastChangedLKK;
    NSTimer *timer;
    int timerChangeCount;
    
    NSString *ASSET_PREFIX;
    
    LWOrderBookElementModel *buyOrders;
    
}


@property (weak, nonatomic) IBOutlet LWNumbersKeyboardView *keyboard;
@property (weak, nonatomic) IBOutlet LWCommonButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *lkkTextField;
@property (weak, nonatomic) IBOutlet UITextField *btcTextField;
@property (weak, nonatomic) IBOutlet UILabel *equityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableWidthConstraint;


@end

@implementation LWMyLykkeBuyAssetPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];

    
    ASSET_PREFIX=[self.assetId stringByAppendingString:@" "];
    
    self.keyboard.showDoneButton=NO;
    self.submitButton.enabled=NO;

    self.lkkTextField.delegate=self;
    self.btcTextField.delegate=self;
    self.keyboard.showDotButton=YES;
    self.lkkTextField.text=[LKK_PREFIX stringByAppendingString:@"0"];
    self.btcTextField.text=[ASSET_PREFIX stringByAppendingString:@"0"];
    self.keyboard.delegate=self;
    [self.submitButton addTarget:self action:@selector(submitPressed) forControlEvents:UIControlEventTouchUpInside];
    if([self.assetId isEqualToString:@"ETH"])
        self.titleLabel.text=@"Purchase LKK with ETH";
    else
        self.titleLabel.text=[NSString stringWithFormat:@"Purchase LKK with %@", self.assetId];
    
    UIFont *font=[UIFont fontWithName:@"ProximaNova-Regular" size:22];
    self.lkkTextField.font=font;
    self.btcTextField.font=font;
    
    self.equityLabel.text=@"<0.001%";
    
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        self.keyboardHeightConstraint.constant=189;
        self.submitBottomConstraint.constant=13;
    }
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:_lkkTextField action:@selector(becomeFirstResponder)];
    [_lkkTextField.superview addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:_btcTextField action:@selector(becomeFirstResponder)];
    [_btcTextField.superview addGestureRecognizer:gesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        self.keyboard.showSeparators=YES;
        [self setBackButton];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES];
        self.keyboard.showSeparators=NO;
        if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            self.tableWidthConstraint.constant=400;
        }
        else
            self.tableWidthConstraint.constant=516;
    }
    
    NSString *assetPair;
    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
        assetPair=[self.assetId stringByAppendingString:@"LKK"];
    else
        assetPair=[@"LKK" stringByAppendingString:self.assetId];
    
    buyOrders=[LWCache instance].cachedBuyOrders[assetPair];
    
    
    [self updatePrice];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        self.title=@"BUY LYKKE";
    else
    {
        if([self.assetId isEqualToString:@"ETH"])
            self.navigationController.title=@"PURCHASE LKK WITH ETH";
        else
            self.navigationController.title=[NSString stringWithFormat:@"PURCHASE LKK WITH %@", [LWCache nameForAsset:self.assetId]];
    }
    [_lkkTextField becomeFirstResponder];

    timer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(refreshPrice) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self refreshPrice];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

-(void) refreshPrice
{
    if(timerChangeCount%10==0)
    {
        NSString *assetPair;
        if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
            assetPair=[self.assetId stringByAppendingString:@"LKK"];
        else
            assetPair=[@"LKK" stringByAppendingString:self.assetId];
        
//        [[LWAuthManager instance] requestAllAssetPairsRates:assetPair];
        
        [[LWAuthManager instance] requestOrderBook:assetPair];
    }
    timerChangeCount++;
    [self updatePrice];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==_lkkTextField)
    {
        _keyboard.prefix=LKK_PREFIX;
        _keyboard.accuracy=[LWCache accuracyForAssetId:@"LKK"];
        lastChangedLKK=YES;
        
    }
    else
    {
        
        lastChangedLKK=NO;
        _keyboard.prefix=ASSET_PREFIX;
        _keyboard.accuracy=[LWCache accuracyForAssetId:self.assetId];
    }
    _keyboard.textField=textField;

    
    return NO;
}


-(void) numbersKeyboardChangedText:(LWNumbersKeyboardView *) keyboard
{
    NSString *sss=keyboard.textField.text;
    if(!price)
        return;
    if(keyboard.textField==_lkkTextField)
    {
        NSString *string=[self removePrefix:keyboard.textField.text];
        double equity=string.doubleValue/12500000.0;
        if(equity>99.999)
        {
            _lkkTextField.text=[_lkkTextField.text substringToIndex:_lkkTextField.text.length-1];
            return;
        }
        
        lastChangedLKK=YES;

//        [self calcBTC];
    }
    else
    {
        NSString *currentLkk=_lkkTextField.text;
        NSString *prevBtc=[_btcTextField.text substringToIndex:_btcTextField.text.length-1];
        [self calcLKK];
        NSString *string=[self removePrefix:_lkkTextField.text];
        double equity=string.doubleValue/12500000.0;
        if(equity>99.999)
        {
            _btcTextField.text=prevBtc;
            _lkkTextField.text=currentLkk;
            price=[buyOrders priceForResult:_btcTextField.text.doubleValue];
            [self formatPrice];
            return;
        }
        
        
        lastChangedLKK=NO;

     }
    
    [self updatePrice];
    
    if([[self removePrefix:_btcTextField.text] doubleValue]>0 && [buyOrders isResultOK:[[self removePrefix:_btcTextField.text] doubleValue]])
        _submitButton.enabled=YES;
    else
        _submitButton.enabled=NO;
    
    [self calcEquity];
}

-(void) calcEquity
{
    NSString *string=[self removePrefix:_lkkTextField.text];
    double equity=string.doubleValue/12500000.0;
    if(equity<0.001)
    {
        self.equityLabel.text=@"<0.001%";
    }
    else
    {
        self.equityLabel.text=[[LWUtils formatVolumeString:@(equity).stringValue currencySign:@"" accuracy:3 removeExtraZeroes:YES] stringByAppendingString:@"%"];
    }
  
}

-(void) calcBTC
{
    NSString *text=[self removePrefix:_lkkTextField.text];
    self.lkkTextField.text=[LKK_PREFIX stringByAppendingString:[self formatVolume:text]];
    price=[buyOrders priceForVolume:text.doubleValue];
    [self formatPrice];
    NSString *result=[LWUtils formatFairVolume:text.doubleValue*price accuracy:[LWCache accuracyForAssetId:self.assetId] roundToHigher:YES];
    result=[result stringByReplacingOccurrencesOfString:@" " withString:@","];
    result=[ASSET_PREFIX stringByAppendingString:result];
    _btcTextField.text=result;
}

-(void) calcLKK
{
    
    
    NSString *text=[self removePrefix:_btcTextField.text];
    self.btcTextField.text=[ASSET_PREFIX stringByAppendingString:[self formatVolume:text]];
    
    price=[buyOrders priceForResult:text.doubleValue];
    [self formatPrice];

    
    NSString *result=[LWUtils formatFairVolume:text.doubleValue/price accuracy:[LWCache accuracyForAssetId:@"LKK"] roundToHigher:NO];
    result=[result stringByReplacingOccurrencesOfString:@" " withString:@","];
    result=[LKK_PREFIX stringByAppendingString:result];
    _lkkTextField.text=result;

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
    
    return volume;
}



-(NSString *) removePrefix:(NSString *) string
{
    NSString *text=[string stringByReplacingOccurrencesOfString:LKK_PREFIX withString:@""];
    text=[text stringByReplacingOccurrencesOfString:ASSET_PREFIX withString:@""];
    text=[text stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return text;
}

-(void) updatePrice
{
    

    NSString *assetPair;
    
    
    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
        assetPair=[self.assetId stringByAppendingString:@"LKK"];
    else
        assetPair=[@"LKK" stringByAppendingString:self.assetId];
    
//    LWAssetPairRateModel *rate=[LWCache instance].cachedAssetPairsRates[assetPair];

    
    
    if(!buyOrders)
        return;
    
    if(lastChangedLKK)
        price=[buyOrders priceForVolume:[self removePrefix:_lkkTextField.text].doubleValue];
    else
        price=[buyOrders priceForResult:[self removePrefix:_btcTextField.text].doubleValue];

    [self formatPrice];
    
//    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
//    {
//        
//        price=(double)1.0/rate.bid.doubleValue;
//        
//    }
//    else
//    {
//        
//        price=rate.ask.doubleValue;
//        
//    }

    int accuracy=0;
    
    for(LWAssetPairModel *pair in [LWCache instance].allAssetPairs)
    {
        if([pair.identity isEqualToString:assetPair])
        {
            if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
                accuracy=pair.invertedAccuracy.intValue;
            else
                accuracy=pair.accuracy.intValue;
            break;
        }
    }
    
    self.priceLabel.text=[LWUtils formatFairVolume:price accuracy:accuracy roundToHigher:YES];
    if(lastChangedLKK)
        [self calcBTC];
    else
        [self calcLKK];

}

-(void) formatPrice
{
    int accuracy=0;
    
    NSString *assetPair;
    
    
    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
        assetPair=[self.assetId stringByAppendingString:@"LKK"];
    else
        assetPair=[@"LKK" stringByAppendingString:self.assetId];

    
    for(LWAssetPairModel *pair in [LWCache instance].allAssetPairs)
    {
        if([pair.identity isEqualToString:assetPair])
        {
            if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
                accuracy=pair.invertedAccuracy.intValue;
            else
                accuracy=pair.accuracy.intValue;
            break;
        }
    }

    price=[LWUtils fairVolume:price accuracy:accuracy roundToHigher:YES];
}


//-(void) authManager:(LWAuthManager *) manager didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *)packet
//{
//    [self updatePrice];
//}

-(void) authManager:(LWAuthManager *)manager didGetOrderBook:(LWPacketOrderBook *)packet
{
    
    buyOrders=packet.buyOrders;
       
    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"ETH"])
    {
        buyOrders=packet.sellOrders;
        [buyOrders invert];
    }
    [self updatePrice];
    
}

-(void) submitPressed
{
//    LWMyLykkeDepositBTCPresenter *presenter;
//    if([self.assetId isEqualToString:@"BTC"])
//    {
//        presenter=[LWMyLykkeDepositBTCPresenter new];
//        presenter.assetId=@"BTC";
//        presenter.lkkAmount=[self removePrefix:_lkkTextField.text].doubleValue;
//        presenter.price=_priceLabel.text.doubleValue;
//    }
//    else if([self.assetId isEqualToString:@"ETH"])
//    {
//        presenter=[LWMyLykkeDepositBTCPresenter new];
//        presenter.assetId=@"ETH";
//        presenter.lkkAmount=[self removePrefix:_lkkTextField.text].doubleValue;
//        presenter.price=_priceLabel.text.doubleValue;
//    }
//    else if([self.assetId isEqualToString:@"CHF"])
//    {
//        presenter=[LWMyLykkeDepositSwiftPresenter new];
//        
//    }
//    else if([self.assetId isEqualToString:@"USD"])
//    {
//        presenter=[LWMyLykkeCreditCardDepositPresenter new];
//        [(LWMyLykkeCreditCardDepositPresenter *)presenter setLkkAmountString:[self.lkkTextField.text stringByReplacingOccurrencesOfString:@"LKK" withString:@""]];
//    }
//    
//    presenter.amount=[self removePrefix:_btcTextField.text].doubleValue;
//    
//    [self.navigationController pushViewController:presenter animated:YES];

}



-(void) orientationChanged
{
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        self.tableWidthConstraint.constant=400;
    }
    else
        self.tableWidthConstraint.constant=516;

}


-(void) dealloc
{
    [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
