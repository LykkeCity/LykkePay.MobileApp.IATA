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
#import "LWEmptyHistoryPresenter.h"
#import "LWLykkeAssetsData.h"
#import "LWLykkeWalletsData.h"
#import "LWMyLykkeBuyPresenter.h"
#import "LWMyLykkeIpadController.h"
#import "LWEtheriumDepositPresenter.h"


@interface LWTradingWalletPresenter()  {
    NSArray *originalButtonContainerConstraints;
    NSArray *originalWithdrawConstraints;
    NSArray *originalDepositConstraints;
    CGFloat originalTableViewBottomConstraintConstant;
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet TKButton *withdrawButton;
@property (weak, nonatomic) IBOutlet TKButton *depositButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;



@end


@implementation LWTradingWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    originalButtonContainerConstraints=self.withdrawButton.superview.constraints;
    originalWithdrawConstraints=self.withdrawButton.constraints;
    originalDepositConstraints=self.depositButton.constraints;
    originalTableViewBottomConstraintConstant=self.tableViewBottomConstraint.constant;
    
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
    
//    if ([self isMovingToParentViewController]) {
//        [self setLoading:YES];
//        [[LWAuthManager instance] requestTransactions:self.assetId];
//    }
    
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

    [LWValidator setButton:self.depositButton enabled:![LWCache shouldHideDepositForAssetId:self.assetId]];

    [[LWAuthManager instance] requestLykkeWallets];

    [self adjustButtons];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"wallets.trading.title");

}

-(void) adjustButtons
{
    
    for(NSLayoutConstraint *c in self.depositButton.superview.constraints)
        [self.depositButton.superview removeConstraint:c];
    [self.depositButton.superview addConstraints:originalButtonContainerConstraints];
    for(NSLayoutConstraint *c in self.depositButton.constraints)
        [self.depositButton removeConstraint:c];
    [self.depositButton addConstraints:originalDepositConstraints];
    for(NSLayoutConstraint *c in self.withdrawButton.constraints)
        [self.withdrawButton removeConstraint:c];
    [self.withdrawButton addConstraints:originalWithdrawConstraints];
    
    
    NSDictionary *attributesWithdraw = @{NSKernAttributeName:@(1), NSFontAttributeName:self.withdrawButton.titleLabel.font, NSForegroundColorAttributeName:self.withdrawButton.currentTitleColor};
    NSDictionary *attributesDeposit = @{NSKernAttributeName:@(1), NSFontAttributeName:self.depositButton.titleLabel.font, NSForegroundColorAttributeName:self.depositButton.currentTitleColor};
    
    [self.withdrawButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"wallets.trading.withdraw") attributes:attributesWithdraw] forState:UIControlStateNormal];
    [self.depositButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"wallets.trading.deposit") attributes:attributesDeposit] forState:UIControlStateNormal];
    
    self.withdrawButton.hidden=[LWCache shouldHideWithdrawForAssetId:self.assetId] || self.balance.doubleValue==0;
    self.depositButton.hidden=[LWCache shouldHideDepositForAssetId:self.assetId];
    if(self.withdrawButton.hidden && self.depositButton.hidden)
        [self.tableViewBottomConstraint setConstant:0];
    else
        self.tableViewBottomConstraint.constant=originalTableViewBottomConstraintConstant;
    
    if(self.withdrawButton.hidden && self.depositButton.hidden==NO)
    {
        
        [self createConstraintsForButton:self.depositButton];
    }
    else if(self.withdrawButton.hidden==NO && self.depositButton.hidden)
        [self createConstraintsForButton:self.withdrawButton];

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

        if([self.assetId isEqualToString:@"LKK"])
        {
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            {
                LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
                [self.navigationController pushViewController:presenter animated:YES];
            }
            else
            {
                LWMyLykkeIpadController *presenter=[LWMyLykkeIpadController new];
                [self.navigationController pushViewController:presenter animated:YES];
                
            }
            return;
        }

    
    UIViewController *presenter;
        
    if([self.assetId isEqualToString:@"ETH"])
    {
            presenter = [LWEtheriumDepositPresenter new];
    }
    else if([depositTypes[self.assetId] isEqualToString:@"bitcoin"])
    {
        presenter = [LWBitcoinDepositPresenter new];
    }
    else
    {
        if([LWCache isBankCardDepositEnabledForAssetId:self.assetId])
            presenter=[LWCreditCardDepositPresenter new];
        else
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

-(void) authManager:(LWAuthManager *)manager didGetHistory:(LWPacketGetHistory *)packet
{
    [super authManager:manager didGetHistory:packet];
    [[LWAuthManager instance] requestLykkeWallets];
    
    [self adjustButtons];
    
    if(!self.operations.count)
    {
        if(self.emptyHistoryPresenter)
            return;
        __weak LWTradingWalletPresenter *weakSelf=self;

        self.emptyHistoryPresenter=[[LWEmptyHistoryPresenter alloc] init];
        self.emptyHistoryPresenter.flagColoredButton=YES;
//        if(self.depositButton.hidden==NO)
//            self.emptyHistoryPresenter.depositAction=^{
//                [weakSelf depositClicked:weakSelf.depositButton];
//            };
        self.emptyHistoryPresenter.button.hidden=YES;
        self.emptyHistoryPresenter.buttonText=@"DEPOSIT";
        self.emptyHistoryPresenter.view.frame=self.view.bounds;
//        [self.view addSubview:self.emptyHistoryPresenter.view];
        [self addChildViewController:self.emptyHistoryPresenter];
    }
    else if(self.operations.count && self.emptyHistoryPresenter)
    {
        [self.emptyHistoryPresenter.view removeFromSuperview];
        [self.emptyHistoryPresenter removeFromParentViewController];
        self.emptyHistoryPresenter=nil;
    }
    
    [self.tableView reloadData];
    
    
}


-(void) createConstraintsForButton:(UIButton *) button
{
    NSArray *prev=button.superview.constraints;
    for(NSLayoutConstraint *c in prev)
    {
        if(c.firstItem==button || c.secondItem==button)
            [button.superview removeConstraint:c];
    }

    
    NSLayoutConstraint *center=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [button.superview addConstraint:center];

    NSLayoutConstraint *centerX=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [button.superview addConstraint:centerX];



    NSLayoutConstraint *width=[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:280];

    [button addConstraint:width];
    
    
}

-(void) authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data
{
    [self showBalanceFromLykkeData:data.lykkeData];
}

-(void) showBalanceFromLykkeData:(LWLykkeData *) data
{
    NSString *balanceAsset=self.assetId;
    
    
    for(LWLykkeAssetsData *d in data.assets)
    {
        if([d.identity isEqualToString:balanceAsset])
        {
            self.balance=d.balance;
            break;
        }
    }
    if(self.balance.floatValue>0)
        [self adjustButtons];
}



@end
