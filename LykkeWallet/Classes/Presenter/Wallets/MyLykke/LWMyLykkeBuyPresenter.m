//
//  LWMyLykkeBuyPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeBuyPresenter.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWMyLykkeBuyAssetPresenter.h"
#import "LWPacketAllAssetPairsRates.h"
#import "LWAssetPairRateModel.h"
#import "LWAssetPairModel.h"
#import "LWUtils.h"
#import "LWCache.h"
#import "LWMyLykkeBuyAssetPresenter.h"
#import "LWMyLykkeTransferLKKPresenter.h"
#import "LWMyLykkeTransferLKKLeftPanelPresenter.h"

@interface LWMyLykkeBuyPresenter () <LWMyLykkeTransferLKKLeftPanelPresenterDelegate>
{
    NSTimer *timer;
    int timerChangeCount;
}

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

@property (weak, nonatomic) IBOutlet UIButton *buyTopButton;
@property (weak, nonatomic) IBOutlet UIButton *transferTopButton;




@end

@implementation LWMyLykkeBuyPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];
    timerChangeCount=0;
//    _bitcoinPriceLabel.text=@"฿ 0";
    _bitcoinPriceLabel.hidden=YES;
    _creditCardPriceLabel.hidden=YES;
    _swiftPriceLabel.hidden=YES;
//    _swiftPriceLabel.text=@"₣ 0";
    _swiftPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    _bitcoinPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    _creditCardPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    _ethereumPriceLabel.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];

    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_bitcoinContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_creditCardContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_swiftContainerView addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buyPressed:)];
    [_ethereumContainerView addGestureRecognizer:gesture];
    
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
//    {
//        self.subtitleContainerView.hidden=YES;
//        self.subtitleContainerHeightConstraint.constant=0;
//    }
    _buyTopButton.layer.cornerRadius=_buyTopButton.bounds.size.height/2;
    _buyTopButton.clipsToBounds=YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"DEPOSIT LYKKE";
    
    [self reloadRates];
    timer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(reloadRates) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

    
}

-(void) reloadRates
{
    if(timerChangeCount%10==0)
    {
        [[LWAuthManager instance] requestAllAssetPairsRates:@"BTCLKK"];
        [[LWAuthManager instance] requestAllAssetPairsRates:@"LKKUSD"];
        [[LWAuthManager instance] requestAllAssetPairsRates:@"LKKCHF"];
        [[LWAuthManager instance] requestAllAssetPairsRates:@"ETHLKK"];

    }
    timerChangeCount++;
    [self updateRates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self setBackButton];
    else
        [self.navigationController setNavigationBarHidden:YES];
    [self updateRates];
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
    else if(gesture.view==_ethereumContainerView)
    {
        assetId=@"ETH";
        container=_ethereumContainerView;
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
        _ethereumContainerView.backgroundColor=[UIColor whiteColor];
        container.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
        [self.delegate buyPresenterChosenAsset:assetId];
    }
}

-(void) updateRates
{
    
    if([LWCache instance].cachedAssetPairsRates[@"BTCLKK"])
    {
        int accuracy=[self accuraceForPair:@"BTCLKK"];
        double ask=[[LWCache instance].cachedAssetPairsRates[@"BTCLKK"] bid].doubleValue;
        NSString *string=[LWUtils formatFairVolume:1.0/ask accuracy:accuracy roundToHigher:YES];
        string=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _bitcoinPriceLabel.text=[@"฿ " stringByAppendingString:string];
        _bitcoinPriceLabel.hidden=NO;
    }
    if([LWCache instance].cachedAssetPairsRates[@"LKKUSD"])
    {
        int accuracy=[self accuraceForPair:@"LKKUSD"];
        double ask=[[LWCache instance].cachedAssetPairsRates[@"LKKUSD"] ask].doubleValue;
        NSString *string=[LWUtils formatFairVolume:ask accuracy:accuracy roundToHigher:YES];
        string=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _creditCardPriceLabel.text=[@"$ " stringByAppendingString:string];
        _creditCardPriceLabel.hidden=NO;
    }
    if([LWCache instance].cachedAssetPairsRates[@"LKKCHF"])
    {
        int accuracy=[self accuraceForPair:@"LKKCHF"];
        double ask=[[LWCache instance].cachedAssetPairsRates[@"LKKCHF"] ask].doubleValue;
        NSString *string=[LWUtils formatFairVolume:ask accuracy:accuracy roundToHigher:YES];
        string=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _swiftPriceLabel.text=[@"₣ " stringByAppendingString:string];
        _swiftPriceLabel.hidden=NO;
    }
    if([LWCache instance].cachedAssetPairsRates[@"ETHLKK"])
    {
        int accuracy=[self accuraceForPair:@"ETHLKK"];
        double ask=[[LWCache instance].cachedAssetPairsRates[@"ETHLKK"] bid].doubleValue;
        NSString *string=[LWUtils formatFairVolume:1.0/ask accuracy:accuracy roundToHigher:YES];
        string=[string stringByReplacingOccurrencesOfString:@" " withString:@","];
        _ethereumPriceLabel.text=[@"Ξ " stringByAppendingString:string];
        _ethereumPriceLabel.hidden=NO;
    }


}

-(int) accuraceForPair:(NSString *) pairr
{
    int accuracy=0;
    
    for(LWAssetPairModel *pair in [LWCache instance].allAssetPairs)
    {
        if([pairr isEqualToString:pair.identity])
        {
            if([pairr isEqualToString:@"BTCLKK"] || [pairr isEqualToString:@"ETHLKK"])
                accuracy=pair.invertedAccuracy.intValue;
            else
                accuracy=pair.accuracy.intValue;
            break;
        }
    }
    return accuracy;
 
}

-(void) authManager:(LWAuthManager *)manager didGetAllAssetPairsRate:(LWPacketAllAssetPairsRates *)packet
{
    [self updateRates];
}



-(IBAction) transferTopButtonPressed:(id)sender
{
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        LWMyLykkeTransferLKKPresenter *presenter=[LWMyLykkeTransferLKKPresenter new];
        NSMutableArray *arr=[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [arr removeLastObject];
        [arr addObject:presenter];
        [self.navigationController setViewControllers:arr];

    }
    else
    {
        [self.delegate buyPresenterSelectedTransfer];
    }
    

    
}




@end
