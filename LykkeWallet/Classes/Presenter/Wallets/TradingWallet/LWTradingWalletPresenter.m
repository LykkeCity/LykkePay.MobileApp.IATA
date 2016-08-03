//
//  LWTradingWalletPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradingWalletPresenter.h"
#import "LWBitcoinDepositPresenter.h"
#import "LWWithdrawFundsPresenter.h"
#import "TKButton.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWCurrencyDepositPresenter.h"
#import "LWCache.h"
#import "LWWithdrawInputPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWValidator.h"
#import "LWKYCManager.h"
#import "LWCreditCardDepositPresenter.h"


@interface LWTradingWalletPresenter () {
    
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet TKButton *withdrawButton;
@property (weak, nonatomic) IBOutlet TKButton *depositButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@end


@implementation LWTradingWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.withdrawButton setTitle:Localize(@"wallets.trading.withdraw") forState:UIControlStateNormal];
//    [self.depositButton setTitle:Localize(@"wallets.trading.deposit") forState:UIControlStateNormal];
    
#ifdef PROJECT_IATA
#else
    [self.withdrawButton setGrayPalette];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setBackButton];
    
    if ([self isMovingToParentViewController]) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestTransactions:self.assetId];
    }
    
//    [LWValidator setButton:self.depositButton enabled:YES];
//    [LWValidator setButton:self.withdrawButton enabled:NO];
//    self.withdrawButton.enabled=YES;
//
//    
//    if([LWCache isAssetDepositAvailableForAssetID:self.assetId]==NO)
//    {
//        self.depositButton.hidden=YES;
//        self.withdrawButton.hidden=YES;
//    }
    
    [LWValidator setButtonWithClearBackground:self.withdrawButton enabled:![LWCache shouldHideWithdrawForAssetId:self.assetId]];

    [LWValidator setButton:self.depositButton enabled:!([LWCache shouldHideDepositForAssetId:self.assetId] && ([self.assetId isEqualToString:@"USD"]==NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"CanCashInViaBankCard"]==NO))];

    NSDictionary *attributesWithdraw = @{NSKernAttributeName:@(1), NSFontAttributeName:self.withdrawButton.titleLabel.font, NSForegroundColorAttributeName:self.withdrawButton.currentTitleColor};
    NSDictionary *attributesDeposit = @{NSKernAttributeName:@(1), NSFontAttributeName:self.depositButton.titleLabel.font, NSForegroundColorAttributeName:self.depositButton.currentTitleColor};
    
    [self.withdrawButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"wallets.trading.withdraw") attributes:attributesWithdraw] forState:UIControlStateNormal];
    [self.depositButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"wallets.trading.deposit") attributes:attributesDeposit] forState:UIControlStateNormal];

    self.withdrawButton.hidden=[LWCache shouldHideWithdrawForAssetId:self.assetId];
    self.depositButton.hidden=[LWCache shouldHideDepositForAssetId:self.assetId] && ([self.assetId isEqualToString:@"USD"]==NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"CanCashInViaBankCard"]==NO) ;
    if(self.withdrawButton.hidden && self.depositButton.hidden)
        [self.tableViewBottomConstraint setConstant:0];
    
    if(self.withdrawButton.hidden && self.depositButton.hidden==NO)
    {
        
        [self createConstraintsForButton:self.depositButton];
    }
    else if(self.withdrawButton.hidden==NO && self.depositButton.hidden)
            [self createConstraintsForButton:self.withdrawButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"wallets.trading.title");

}

#pragma mark - Actions

- (IBAction)withdrawClicked:(id)sender {
    
    
    [LWKYCManager sharedInstance].viewController=self;;
    
    [[LWKYCManager sharedInstance] manageKYCStatusForAsset:self.assetId successBlock:^{

    LWWithdrawFundsPresenter *presenter;

    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"LKK"])
    {
        presenter = [LWWithdrawFundsPresenter new];
        presenter.assetId = self.assetId;
        presenter.assetSymbol=self.currencySymbol;
        
    }
    else
    {
        presenter=(LWWithdrawFundsPresenter *)[LWWithdrawInputPresenter new];
        presenter.assetId=self.assetId;
        presenter.assetSymbol=self.currencySymbol;
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationCustom;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
    }
    }];

    
    
    
}

- (IBAction)depositClicked:(id)sender {
    
    NSDictionary *depositTypes=@{@"EUR":@"currency",
                                 @"USD":@"currency",
                                 @"CHF":@"currency",
                                 @"GBP":@"currency",
                                 @"BTC":@"bitcoin",
                                 @"LKK":@"bitcoin"};
    
    [LWKYCManager sharedInstance].viewController=self;;
    
    [[LWKYCManager sharedInstance] manageKYCStatusForAsset:self.assetId successBlock:^{

    
    
    UIViewController *presenter;
    
    if([depositTypes[self.assetId] isEqualToString:@"bitcoin"])
    {
        presenter = [LWBitcoinDepositPresenter new];
    }
//    else if([self.assetId isEqualToString:@"USD"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"CanCashInViaBankCard"])
//    {
//        presenter=[LWCreditCardDepositPresenter new];
//    }
    else
    {
        presenter=[LWCurrencyDepositPresenter new];
    }
    
    ((LWCurrencyDepositPresenter *)presenter).assetName=self.assetName;
    ((LWCurrencyDepositPresenter *)presenter).issuerId=self.issuerId;
    ((LWCurrencyDepositPresenter *)presenter).assetID=self.assetId;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }

    }];
    
}

-(void) createConstraintsForButton:(UIButton *) button
{
    NSArray *prev=button.superview.constraints;
    for(NSLayoutConstraint *c in prev)
    {
        if(c.firstItem==button)
            [button.superview removeConstraint:c];
    }

    
    NSLayoutConstraint *left=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:30];
    [button.superview addConstraint:left];
    
    NSLayoutConstraint *right=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:30];
    
    [button.superview addConstraint:right];
//    NSLayoutConstraint *height=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45];
    NSLayoutConstraint *center=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [button.superview addConstraint:center];
//    [button addConstraints:@[left, right, height, center]];
    
}


@end
