//
//  LWCashEmptyBlockchainPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCashEmptyBlockchainPresenter.h"
#import "LWExchangeBlockchainPresenter.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWCashInOutHistoryItemType.h"
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


@interface LWCashEmptyBlockchainPresenter () <LWLeftDetailTableViewCellDelegate> {

    NSArray *titles;
    NSArray *values;
    
    
}


#pragma mark - Utils
- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;

@end


@implementation LWCashEmptyBlockchainPresenter



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    
    [self setBackButton];
 //   [self setRefreshControl];
    
    
    NSInteger const precision = [LWAssetsDictionaryItem assetAccuracyById:self.model.asset];
    NSString *volumeString = [LWMath historyPriceString:self.model.volume
                                              precision:precision
                                             withPrefix:@""];

    titles = @[
        Localize(@"history.cash.asset"),
        Localize(@"history.cash.amount"),
        Localize(@"history.cash.blockchain"),
        @"Address from",
        @"Address to"
    ];

    values=@[
        self.model.asset,
        volumeString,
        Localize(@"history.cash.progress"),
        self.model.addressFrom?self.model.addressFrom:@"",
        self.model.addressTo?self.model.addressTo:@""
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
    NSString *type = (self.model.volume.doubleValue >= 0
                      ? Localize(@"history.cash.in")
                      : Localize(@"history.cash.out"));
    
    NSString *base = [LWAssetModel
                      assetByIdentity:self.model.asset
                      fromList:[LWCache instance].allAssets];
    
    self.title = [NSString stringWithFormat:@"%@ %@", base, type];

}

-(void) leftDetailCellCopyPressed:(LWLeftDetailTableViewCell *) cell
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:cell.detailLabel.text];
    [self showCopied];
}



#pragma mark - UITableViewDataSource


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([values[indexPath.row] length]==0)
        return 0;
    //    LWLeftDetailTableViewCell *cell=(LWLeftDetailTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    return [cell heightWithTableViewWidth:tableView.bounds.size.width];
    
    return UITableViewAutomaticDimension;
}


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
    [self updateTitleCell:cell row:indexPath.row];
    [self updateValueCell:cell row:indexPath.row];
    
    if(indexPath.row>2)
        cell.showCopyButton=YES;

    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
}


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
        cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    
    
    
    
    cell.detailLabel.text = values[row];
    [cell.detailLabel setTextColor:[UIColor colorWithHexString:kMainDarkElementsColor]];
}

- (void)startRefreshControl {
    [super startRefreshControl];
    
    [[LWAuthManager instance] requestBlockchainCashTransaction:self.model.identity];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self stopRefreshControl];
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainCashTransaction:(LWAssetBlockchainModel *)blockchain {
    [self stopRefreshControl];

    if (blockchain) {
        LWExchangeBlockchainPresenter *controller = [LWExchangeBlockchainPresenter new];
        controller.blockchainModel = blockchain;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
