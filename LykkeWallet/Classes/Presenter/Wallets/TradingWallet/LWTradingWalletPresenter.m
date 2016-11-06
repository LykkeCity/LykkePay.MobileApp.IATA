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


@interface LWTradingWalletPresenter () {
    
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet TKButton *withdrawButton;
@property (weak, nonatomic) IBOutlet TKButton *depositButton;

@end


@implementation LWTradingWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localize(@"wallets.trading.title");
    [self.withdrawButton setTitle:Localize(@"wallets.trading.withdraw") forState:UIControlStateNormal];
    [self.depositButton setTitle:Localize(@"wallets.trading.deposit") forState:UIControlStateNormal];
    
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
}

#pragma mark - Actions

- (IBAction)withdrawClicked:(id)sender {
    LWWithdrawFundsPresenter *presenter = [LWWithdrawFundsPresenter new];
    presenter.assetId = self.assetId;
    presenter.assetPairId = self.assetPairId;
    
    [self.navigationController pushViewController:presenter animated:YES];
}

- (IBAction)depositClicked:(id)sender {
    LWBitcoinDepositPresenter *presenter = [LWBitcoinDepositPresenter new];
    
    presenter.assetName = self.assetName;
    presenter.issuerId = self.issuerId;
    
    [self.navigationController pushViewController:presenter animated:YES];
}

@end
