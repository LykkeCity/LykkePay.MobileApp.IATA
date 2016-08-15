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
#import "LWUtils.h"
#import "LWAuthManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWBaseHistoryItemType.h"

@interface LWExchangeEmptyBlockchainPresenter () <LWLeftDetailTableViewCellDelegate>{

    NSArray *titles;
    NSArray *values;
}

#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;

@end


#warning TODO: refactoring because of copying LWExchangeResultPresenter
@implementation LWExchangeEmptyBlockchainPresenter




- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    [self setBackButton];
//    [self setRefreshControl];
    
    titles= @[
        Localize(@"exchange.assets.result.assetname"),
        Localize(@"exchange.assets.result.units"),
        Localize(@"exchange.assets.result.price"),
        //Localize(@"exchange.assets.result.commission"),
        Localize(@"exchange.assets.result.cost"),
        Localize(@"exchange.assets.result.blockchain"),
        @"Address from",
        @"Address to"
        //Localize(@"exchange.assets.result.position")
    ];
    
    values= @[
        self.model.assetPair,
        [LWUtils stringFromNumber:self.model.volume],
        [LWUtils stringFromNumber:self.model.price],
        [LWUtils stringFromNumber:self.model.totalCost],
        self.model.blockchainId ? self.model.blockchainId : Localize(@"exchange.assets.result.blockchain.progress"),
        self.historyItem.addressFrom?self.historyItem.addressFrom:@"",
        self.historyItem.addressTo?self.historyItem.addressTo:@""
    ];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kLeftDetailTableViewCellHeight;


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *base = [LWAssetModel
                      assetByIdentity:self.asset
                      fromList:[LWCache instance].allAssets];
    
    NSString *type = (self.model.position.doubleValue >= 0
                      ? Localize(@"history.market.buy")
                      : Localize(@"history.market.sell"));
    self.title = [NSString stringWithFormat:@"%@ %@", base, type];

}

-(void) leftDetailCellCopyPressed:(LWLeftDetailTableViewCell *) cell
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:cell.detailLabel.text];
    [self showCopied];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWLeftDetailTableViewCell *cell = (LWLeftDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLeftDetailTableViewCellIdentifier];
    cell.delegate=self;
    if(indexPath.row>4)
        cell.showCopyButton=YES;
    [self updateTitleCell:cell row:indexPath.row];
    [self updateValueCell:cell row:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = values[indexPath.row];
    if (text.length) {
        
        return UITableViewAutomaticDimension;
//        LWLeftDetailTableViewCell *cell=(LWLeftDetailTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//        return [cell heightWithTableViewWidth:tableView.bounds.size.width];
    }
    return 0.0;
}


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    cell.detailLabel.text = values[row];
//    if (kBlockchainRow == row) {
//        UIColor *blockchainColor = self.model.blockchainSettled
//        ? [UIColor colorWithHexString:kMainElementsColor]
//        : [UIColor colorWithHexString:kMainDarkElementsColor];
//        [cell.detailLabel setTextColor:blockchainColor];
//    }
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
