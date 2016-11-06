//
//  LWExchangeEmptyBlockchainPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeEmptyBlockchainPresenter.h"
#import "LWExchangeBlockchainPresenter.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWExchangeInfoModel.h"
#import "LWAssetModel.h"
#import "LWAssetBlockchainModel.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "LWMath.h"
#import "LWAuthManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"

@interface LWExchangeEmptyBlockchainPresenter () {

}

#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;

@end


#warning TODO: refactoring because of copying LWExchangeResultPresenter
@implementation LWExchangeEmptyBlockchainPresenter

static int const kNumberOfRows = 5;
static int const kBlockchainRow = 4;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *base = [LWAssetModel
                      assetByIdentity:self.asset
                      fromList:[LWCache instance].baseAssets];
    
    NSString *type = (self.model.volume.doubleValue >= 0
                      ? Localize(@"history.market.buy")
                      : Localize(@"history.market.sell"));
    self.title = [NSString stringWithFormat:@"%@ %@", base, type];
    

    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [self dataByCellRow:indexPath.row];
    if (text) {
        return kLeftDetailTableViewCellHeight;
    }
    return 0.0;
}


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    NSString *const titles[kNumberOfRows] = {
        Localize(@"exchange.assets.result.assetname"),
        Localize(@"exchange.assets.result.units"),
        Localize(@"exchange.assets.result.price"),
        //Localize(@"exchange.assets.result.commission"),
        Localize(@"exchange.assets.result.cost"),
        Localize(@"exchange.assets.result.blockchain")
        //Localize(@"exchange.assets.result.position")
    };
    cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    cell.detailLabel.text = [self dataByCellRow:row];
    if (kBlockchainRow == row) {
        UIColor *blockchainColor = self.model.blockchainSettled
        ? [UIColor colorWithHexString:kMainElementsColor]
        : [UIColor colorWithHexString:kMainDarkElementsColor];
        [cell.detailLabel setTextColor:blockchainColor];
    }
}

- (NSString *)dataByCellRow:(NSInteger)row {
    NSString *const values[kNumberOfRows] = {
        self.model.assetPair,
        [LWMath makeStringByNumber:self.model.volume withPrecision:0],
        [LWMath makeStringByNumber:self.model.price withPrecision:self.model.accuracy.integerValue],
        //[LWMath makeStringByNumber:self.model.commission withPrecision:2],
        [LWMath makeStringByNumber:self.model.totalCost withPrecision:2],
        self.model.blockchainSettled ? self.model.blockchainId : Localize(@"exchange.assets.result.blockchain.progress")
        //[LWMath makeStringByNumber:self.model.position withPrecision:0]
    };
    
    return values[row];
}

- (void)startRefreshControl {
    [super startRefreshControl];

    [[LWAuthManager instance] requestBlockchainExchangeTransaction:self.model.identity];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self stopRefreshControl];

    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainExchangeTransaction:(LWAssetBlockchainModel *)blockchain {
    [self stopRefreshControl];

    if (blockchain) {
        LWExchangeBlockchainPresenter *controller = [LWExchangeBlockchainPresenter new];
        controller.blockchainModel = blockchain;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
