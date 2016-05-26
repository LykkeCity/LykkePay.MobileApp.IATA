//
//  LWBaseHistoryPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryPresenter.h"
#import "LWCashEmptyBlockchainPresenter.h"
#import "LWExchangeEmptyBlockchainPresenter.h"
#import "LWTransferEmptyBlockchainPresenter.h"
#import "LWExchangeBlockchainPresenter.h"
#import "LWHistoryTableViewCell.h"
#import "LWAuthManager.h"
#import "LWTransactionsModel.h"
#import "LWAssetBlockchainModel.h"
#import "LWExchangeInfoModel.h"
#import "LWAssetsDictionaryItem.h"
#import "LWAssetModel.h"
#import "LWHistoryManager.h"
#import "LWBaseHistoryItemType.h"
#import "LWCashInOutHistoryItemType.h"
#import "LWTradeHistoryItemType.h"
#import "LWTransferHistoryItemType.h"
#import "LWConstants.h"
#import "LWMath.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "NSDate+String.h"

@interface LWBaseHistoryPresenter () {
    UIRefreshControl *refreshControl;
}

#pragma mark - Properties

@property (strong,   nonatomic) NSIndexPath  *loadedElement;
@property (readonly, nonatomic) NSDictionary *operations;
@property (readonly, nonatomic) NSArray      *sortedKeys;


#pragma mark - Utils

- (void)updateCell:(LWHistoryTableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)setRefreshControl;
- (void)reloadHistory;
- (LWBaseHistoryItemType *)getHistoryItemByIndexPath:(NSIndexPath *)indexPath;
- (void)showBlockchainView:(LWAssetBlockchainModel *)blockchain;
- (void)setImageType:(NSString *)imageType forImageView:(UIImageView *)imageView;
- (void)setImageTransfer:(NSString *)imageType forImageView:(UIImageView *)imageView;

@end


@implementation LWBaseHistoryPresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadedElement = nil;
    
    [self registerCellWithIdentifier:kHistoryTableViewCellIdentifier
                                name:kHistoryTableViewCell];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    [self setRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sortedKeys ? self.sortedKeys.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.sortedKeys objectAtIndex:section];
    NSInteger const result = [self.operations[key] count];
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWHistoryTableViewCell *cell = (LWHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kHistoryTableViewCellIdentifier];
    [self updateCell:cell indexPath:indexPath];
    
    return cell;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didReceiveTransactions:(LWTransactionsModel *)transactions {
    _operations = [LWHistoryManager convertNetworkModel:transactions];
    _sortedKeys = [LWHistoryManager sortKeys:_operations];
    
    [refreshControl endRefreshing];
    
    [self setLoading:NO];
    [self.tableView reloadData];
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainCashTransaction:(LWAssetBlockchainModel *)blockchain {
    [self setLoading:NO];
    
    if (blockchain) {
        [self showBlockchainView:blockchain];
    }
    else {
        // need extra data - request
        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
        if (item) {
            LWCashEmptyBlockchainPresenter *emptyPresenter = [LWCashEmptyBlockchainPresenter new];
            LWCashInOutHistoryItemType *model = (LWCashInOutHistoryItemType *)item;
            emptyPresenter.model = [model copy];
            [self.navigationController pushViewController:emptyPresenter animated:YES];
        }
    }
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainExchangeTransaction:(LWAssetBlockchainModel *)blockchain {
    if (blockchain) {
        [self setLoading:NO];
        [self showBlockchainView:blockchain];
    }
    else {
        // need extra data - request
        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
        if (!item) {
            [self setLoading:NO];
        }
        else {
            [[LWAuthManager instance] requestExchangeInfo:item.identity];
        }
    }
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransferTransaction:(LWAssetBlockchainModel *)blockchain {
    [self setLoading:NO];
    
    if (blockchain) {
        [self showBlockchainView:blockchain];
    }
    else {
        // need extra data - request
        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
        if (item) {
            LWTransferEmptyBlockchainPresenter *emptyPresenter = [LWTransferEmptyBlockchainPresenter new];
            LWTransferHistoryItemType *model = (LWTransferHistoryItemType *)item;
            emptyPresenter.model = [model copy];
            [self.navigationController pushViewController:emptyPresenter animated:YES];
        }
    }
}

- (void)authManager:(LWAuthManager *)manager didReceiveExchangeInfo:(LWExchangeInfoModel *)exchangeInfo {
    [self setLoading:NO];
    
    // need extra data - request
    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
    if (item) {
        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
        LWExchangeEmptyBlockchainPresenter *presenter = [LWExchangeEmptyBlockchainPresenter new];
        presenter.model = [exchangeInfo copy];
        presenter.asset = trade.asset;
        [self.navigationController pushViewController:presenter animated:YES];
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [refreshControl endRefreshing];
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:indexPath];
    if (!item) {
        return;
    }
    
    if (item && item.historyType == LWHistoryItemTypeTrade) {
        [self setLoading:YES];
        self.loadedElement = indexPath;
        [[LWAuthManager instance] requestBlockchainExchangeTransaction:item.identity];
    }
    else if (item && item.historyType == LWHistoryItemTypeCashInOut) {
        [self setLoading:YES];
        self.loadedElement = indexPath;
        [[LWAuthManager instance] requestBlockchainCashTransaction:item.identity];
    }
    else if (item && item.historyType == LWHistoryItemTypeTransfer) {
        [self setLoading:YES];
        self.loadedElement = indexPath;
        [[LWAuthManager instance] requestBlockchainTransferTrnasaction:item.identity];
    }
}


#pragma mark - Utils

- (void)updateCell:(LWHistoryTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:indexPath];
    if (!item) {
        return;
    }
    
    NSNumber *volume = [NSNumber numberWithDouble:0];
    NSString *operation = @"";
    if (item.historyType == LWHistoryItemTypeTrade) {
        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
        [self setImageType:trade.iconId forImageView:cell.operationImageView];
        
        volume = trade.volume;
        
        NSString *base = [LWAssetModel
                          assetByIdentity:trade.asset
                          fromList:[LWCache instance].baseAssets];
        
        NSString *type = (volume.doubleValue >= 0
                          ? Localize(@"history.market.buy")
                          : Localize(@"history.market.sell"));
        
        operation = [NSString stringWithFormat:@"%@ %@", base, type];
    }
    else if (item.historyType == LWHistoryItemTypeCashInOut) {
        LWCashInOutHistoryItemType *cash = (LWCashInOutHistoryItemType *)item;
        [self setImageType:cash.iconId forImageView:cell.operationImageView];
        volume = cash.amount;
        
        NSString *base = [LWAssetModel
                          assetByIdentity:cash.asset
                          fromList:[LWCache instance].baseAssets];
        
        NSString *type = (volume.doubleValue >= 0
                          ? Localize(@"history.cash.in")
                          : Localize(@"history.cash.out"));
        
        operation = [NSString stringWithFormat:@"%@ %@", base, type];
    }
#ifdef PROJECT_IATA
    else if (item.historyType == LWHistoryItemTypeTransfer) {
        LWTransferHistoryItemType *transfer = (LWTransferHistoryItemType *)item;
        [self setImageTransfer:transfer.iconId forImageView:cell.operationImageView];
        volume = transfer.volume;
        
        NSString *base = [LWAssetModel
                          assetByIdentity:transfer.asset
                          fromList:[LWCache instance].baseAssets];
        
        NSString *type = (volume.doubleValue >= 0
                          ? Localize(@"history.transfer.in")
                          : Localize(@"history.transfer.out"));
        
        operation = [NSString stringWithFormat:@"%@ %@", base, type];
    }
#endif
    
    // prepare value label
    NSString *sign = (volume.doubleValue >= 0.0) ? @"+" : @"";
    NSInteger const precision = [LWAssetsDictionaryItem assetAccuracyById:item.asset];
    NSString *changeString = [LWMath historyPriceString:volume precision:precision withPrefix:sign];
    
    UIColor *changeColor = (volume.doubleValue >= 0.0)
    ? [UIColor colorWithHexString:kAssetChangePlusColor]
    : [UIColor colorWithHexString:kAssetChangeMinusColor];
    cell.valueLabel.textColor = changeColor;
    cell.valueLabel.text = changeString;
    
    cell.typeLabel.text = operation;
    cell.dateLabel.text = [item.dateTime toShortFormat];
    
#ifdef PROJECT_IATA
    cell.separatorInset = UIEdgeInsetsMake(0, 38, 0, 38);
#endif
}

- (void)setRefreshControl {
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(reloadHistory)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];
}

- (void)reloadHistory {
    [[LWAuthManager instance] requestTransactions:self.assetId];
}

- (LWBaseHistoryItemType *)getHistoryItemByIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self.sortedKeys objectAtIndex:indexPath.section];
    if (key) {
        NSArray *items = self.operations[key];
        if (items) {
            LWBaseHistoryItemType *item = (LWBaseHistoryItemType *)([items objectAtIndex:indexPath.row]);
            return item;
        }
    }
    return nil;
}

- (void)showBlockchainView:(LWAssetBlockchainModel *)blockchain {
    LWExchangeBlockchainPresenter *controller = [LWExchangeBlockchainPresenter new];
    controller.blockchainModel = blockchain;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setImageType:(NSString *)imageType forImageView:(UIImageView *)imageView {
    imageView.image = [LWUtils imageForIssuerId:imageType];
}

- (void)setImageTransfer:(NSString *)imageType forImageView:(UIImageView *)imageView {
    imageView.image = [LWUtils imageForIATAId:imageType];
}

@end
