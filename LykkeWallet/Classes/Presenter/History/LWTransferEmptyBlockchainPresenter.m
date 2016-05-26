//
//  LWTransferEmptyBlockchainPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransferEmptyBlockchainPresenter.h"
#import "LWExchangeBlockchainPresenter.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWTransferHistoryItemType.h"
#import "LWAssetPairModel.h"
#import "LWAssetDealModel.h"
#import "LWAssetModel.h"
#import "LWAssetBlockchainModel.h"
#import "LWAssetsDictionaryItem.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "LWMath.h"
#import "LWAuthManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"


@interface LWTransferEmptyBlockchainPresenter () {
    
}


#pragma mark - Utils
- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;

@end


@implementation LWTransferEmptyBlockchainPresenter

static int const kNumberOfRows = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    NSString *type = (self.model.volume.doubleValue >= 0
                      ? Localize(@"history.transfer.in")
                      : Localize(@"history.transfer.out"));
    
    NSString *base = [LWAssetModel
                      assetByIdentity:self.model.asset
                      fromList:[LWCache instance].baseAssets];
    
    self.title = [NSString stringWithFormat:@"%@ %@", base, type];
    
    [self setBackButton];
    [self setRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWLeftDetailTableViewCell *cell = (LWLeftDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLeftDetailTableViewCellIdentifier];
    
    [self updateTitleCell:cell row:indexPath.row];
    [self updateValueCell:cell row:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
}


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    NSString *const titles[kNumberOfRows] = {
        Localize(@"history.cash.asset"),
        Localize(@"history.transfer.volume"),
        Localize(@"history.cash.blockchain")
    };
    cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    
    NSInteger const precision = [LWAssetsDictionaryItem assetAccuracyById:self.model.asset];
    NSString *volumeString = [LWMath historyPriceString:self.model.volume
                                              precision:precision
                                             withPrefix:@""];
    
    NSString *const values[kNumberOfRows] = {
        self.model.asset,
        volumeString,
        Localize(@"history.cash.progress")
    };
    
    cell.detailLabel.text = values[row];
    [cell.detailLabel setTextColor:[UIColor colorWithHexString:kMainDarkElementsColor]];
}

- (void)startRefreshControl {
    [super startRefreshControl];
    
    [[LWAuthManager instance] requestBlockchainTransferTrnasaction:self.model.identity];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self stopRefreshControl];
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransferTransaction:(LWAssetBlockchainModel *)blockchain {
    [self stopRefreshControl];
    
    if (blockchain) {
        LWExchangeBlockchainPresenter *controller = [LWExchangeBlockchainPresenter new];
        controller.blockchainModel = blockchain;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
