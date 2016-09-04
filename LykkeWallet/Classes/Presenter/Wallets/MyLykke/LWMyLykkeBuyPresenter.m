//
//  LWMyLykkeBuyPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeBuyPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWMyLykkeBuyAssetPresenter.h"
#import "LWPacketAllAssetPairsRates.h"
#import "LWAssetPairRateModel.h"
#import "LWAssetPairModel.h"
#import "LWUtils.h"
#import "LWCache.h"
#import "LWMyLykkeBuyAssetPresenter.h"

@interface LWMyLykkeBuyPresenter ()

@property (weak, nonatomic) IBOutlet UILabel *creditCardPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitcoinPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *swiftPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ethereumPriceLabel;

@property (weak, nonatomic) IBOutlet UIView *creditCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *bitcoinContainerView;
@property (weak, nonatomic) IBOutlet UIView *swiftContainerView;
@property (weak, nonatomic) IBOutlet UIView *ethereumContainerView;

@property (weak, nonatomic) IBOutlet UIView *subtitleContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleContainerHeightConstraint;




@end

@implementation LWMyLykkeBuyPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _bitcoinPriceLabel.text=@"฿ 0";
    _bitcoinPriceLabel.hidden=YES;
    _creditCardPriceLabel.hidden=YES;
    _swiftPriceLabel.hidden=YES;
//    _swiftPriceLabel.text=@"₣ 0";
    _swiftPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    _bitcoinPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    _creditCardPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];

    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_bitcoinContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_creditCardContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_swiftContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_ethereumContainerView addGestureRecognizer:gesture];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        self.subtitleContainerView.hidden=YES;
        self.subtitleContainerHeightConstraint.constant=0;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"BUY LYKKE";
    
    
    [[LWAuthManager instance] requestAllAssetPairsRates:@"BTCLKK"];
    [[LWAuthManager instance] requestAllAssetPairsRates:@"LKKUSD"];
    [[LWAuthManager instance] requestAllAssetPairsRates:@"LKKCHF"];
//    [[LWAuthManager instance] requestAllAssetPairsRates:@"ETHLKK"];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self setBackButton];
    else
        [self.navigationController setNavigationBarHidden:YES];
}


-(void) buyPressed:(UITapGestureRecognizer *) gesture
{
    NSString *assetId;
    UIView *container;
     if(gesture.view==_bitcoinContainerView)
     {
        assetId=@"BTC";
         container=self.bitcoinContainerView;
     }
    else if(gesture.view==_creditCardContainerView)
    {
        assetId=@"USD";
        container=_creditCardContainerView;
    }
    else if(gesture.view==_swiftContainerView)
    {
        assetId=@"CHF";
        container=_swiftContainerView;
    }
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        LWMyLykkeBuyAssetPresenter *presenter=[[LWMyLykkeBuyAssetPresenter alloc] init];
        presenter.assetId=assetId;
        [self.navigationController pushViewController:presenter animated:YES];
    }
    else
    {
        _bitcoinContainerView.backgroundColor=[UIColor whiteColor];
        _creditCardContainerView.backgroundColor=[UIColor whiteColor];
        _swiftContainerView.backgroundColor=[UIColor whiteColor];
        container.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
        [self.delegate buyPresenterChosenAsset:assetId];
    }
}

-(void) authManager:(LWAuthManager *)manager didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *)packet
{
    int accuracy=0;
    
    for(LWAssetPairModel *pair in [LWCache instance].allAssetPairs)
    {
        if([packet.rate.identity isEqualToString:pair.identity])
        {
            if([packet.rate.identity isEqualToString:@"BTCLKK"])
                accuracy=pair.invertedAccuracy.intValue;
            else
                accuracy=pair.accuracy.intValue;
            break;
        }
    }

    
    if([packet.rate.identity isEqualToString:@"BTCLKK"])
    {
        NSString *string=[LWUtils formatFairVolume:1.0/packet.rate.ask.doubleValue accuracy:accuracy roundToHigher:NO];
        [string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _bitcoinPriceLabel.text=[@"฿ " stringByAppendingString:string];
        _bitcoinPriceLabel.hidden=NO;
    }
    if([packet.rate.identity isEqualToString:@"LKKUSD"])
    {
        NSString *string=[LWUtils formatFairVolume:packet.rate.ask.doubleValue accuracy:accuracy roundToHigher:NO];
        [string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _creditCardPriceLabel.text=[@"$ " stringByAppendingString:string];
        _creditCardPriceLabel.hidden=NO;
    }
    if([packet.rate.identity isEqualToString:@"LKKCHF"])
    {
        NSString *string=[LWUtils formatFairVolume:packet.rate.ask.doubleValue accuracy:accuracy roundToHigher:NO];
        [string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _swiftPriceLabel.text=[@"₣ " stringByAppendingString:string];
        _swiftPriceLabel.hidden=NO;
    }
}


@end
