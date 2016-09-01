//
//  LWMyLykkeBuyBitcoinPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeBuyAssetPresenter.h"
#import "UIViewController+Navigation.h"
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

#define LKK_PREFIX @"LKK "


@interface LWMyLykkeBuyAssetPresenter () <UITextFieldDelegate, LWNumbersKeyboardViewDelegate>
{
    double price;
    BOOL lastChangedLKK;
    NSTimer *timer;
    
    NSString *ASSET_PREFIX;
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

@end

@implementation LWMyLykkeBuyAssetPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"BUY LYKKE";
    [_lkkTextField becomeFirstResponder];

    timer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(refreshPrice) userInfo:nil repeats:YES];
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
    NSString *assetPair;
    if([self.assetId isEqualToString:@"BTC"])
        assetPair=@"BTCLKK";
    else
        assetPair=[@"LKK" stringByAppendingString:self.assetId];

    [[LWAuthManager instance] requestAllAssetPairsRates:assetPair];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==_lkkTextField)
    {
        _keyboard.prefix=LKK_PREFIX;
        _keyboard.accuracy=[LWCache accuracyForAssetId:@"LKK"];
        
    }
    else
    {
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
        lastChangedLKK=YES;

        [self calcBTC];
    }
    else
    {
        lastChangedLKK=NO;

        [self calcLKK];
     }
    
    if([[self removePrefix:_btcTextField.text] doubleValue]>0)
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
    NSString *result=[LWUtils formatFairVolume:text.doubleValue*price accuracy:[LWCache accuracyForAssetId:self.assetId] roundToHigher:YES];
    result=[result stringByReplacingOccurrencesOfString:@" " withString:@","];
    result=[ASSET_PREFIX stringByAppendingString:result];
    _btcTextField.text=result;
}

-(void) calcLKK
{
    
    
    NSString *text=[self removePrefix:_btcTextField.text];
    self.btcTextField.text=[ASSET_PREFIX stringByAppendingString:[self formatVolume:text]];
    
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


-(void) authManager:(LWAuthManager *) manager didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *)packet
{
    NSString *assetPair;
    if([self.assetId isEqualToString:@"BTC"])
    {
        assetPair=@"BTCLKK";
        price=(double)1/packet.rate.bid.doubleValue;

    }
    else
    {
        assetPair=[@"LKK" stringByAppendingString:self.assetId];
        price=packet.rate.bid.doubleValue;

    }
    int accuracy=0;
    
    for(LWAssetPairModel *pair in [LWCache instance].allAssetPairs)
    {
        if([pair.identity isEqualToString:assetPair])
        {
            if([self.assetId isEqualToString:@"BTC"])
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

-(void) submitPressed
{
    LWMyLykkeDepositBTCPresenter *presenter;
    if([self.assetId isEqualToString:@"BTC"])
        presenter=[LWMyLykkeDepositBTCPresenter new];
    else if([self.assetId isEqualToString:@"CHF"])
        presenter=[LWMyLykkeDepositSwiftPresenter new];
    else if([self.assetId isEqualToString:@"USD"])
        presenter=[LWMyLykkeCreditCardDepositPresenter new];
    
    presenter.amount=[self removePrefix:_btcTextField.text].doubleValue;
    
    [self.navigationController pushViewController:presenter animated:YES];

}


-(void) dealloc
{
    [timer invalidate];
    
}



@end
