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
#import "LWProgressView.h"
#import "LWRefreshControlView.h"
#import "LWPacketGetHistory.h"
#import "LWEmptyHistoryPresenter.h"
#import "LWHistoryPresenter.h"


@interface LWBaseHistoryPresenter () {
    UIRefreshControl *refreshControl;
}

#pragma mark - Properties

@property (strong,   nonatomic) NSIndexPath  *loadedElement;

//@property (strong, nonatomic) LWEmptyHistoryPresenter *emptyHistoryPresenter;

//@property (strong, nonatomic) LWEmptyHistoryPresenter *emptyHistoryPresenter;


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
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistory) name:@"ApplicationDidBecomeActiveNotification" object:nil];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(refreshControl.isRefreshing==NO)
    {
        [self setLoading:YES];
//        [[LWAuthManager instance] requestTransactions:self.assetId];
        [[LWAuthManager instance] requestGetHistory:self.assetId];

    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [refreshControl endRefreshing];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.emptyHistoryPresenter removeFromParentViewController];
    [_emptyHistoryPresenter.view removeFromSuperview];
}


#pragma mark - UITableViewDataSource

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_operations.count==0)
        return 0;
        return 35;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_operations.count==0)
    {
        return self.view.bounds.size.height-90;
    }
    return 60;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    view.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, tableView.frame.size.width-60, 35)];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    
    [view addSubview:label];
    
    id item=[_operations[section] lastObject];
    if([item isKindOfClass:[LWTradeHistoryItemType class]])
        label.text=@"Trading";
    else if([item isKindOfClass:[LWCashInOutHistoryItemType class]])
        label.text=@"Deposit & Withdraw";
    else if([item isKindOfClass:[LWTransferHistoryItemType class]])
        label.text=@"Transfers";
    
    
    UIView *lineTop=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
    lineTop.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [view addSubview:lineTop];
    
    UIView *lineBottom=[[UIView alloc] initWithFrame:CGRectMake(0, 34.5, 1024, 0.5)];
    lineBottom.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [view addSubview:lineBottom];

    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_operations.count==0)
        return 1;
    
    return _operations.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_operations.count==0)
        return 1;
    return [_operations[section] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_operations.count==0)
    {
        CGRect rrr=self.emptyHistoryPresenter.view.frame;

        UITableViewCell *cell=[[UITableViewCell alloc] init];
//        cell.autoresizesSubviews=NO;
        [cell addSubview:_emptyHistoryPresenter.view];
        _emptyHistoryPresenter.view.frame=cell.bounds;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    LWHistoryTableViewCell *cell = (LWHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kHistoryTableViewCellIdentifier];
    [self updateCell:cell indexPath:indexPath];
    
    if([_operations[indexPath.section] count]-1==indexPath.row && indexPath.section<_operations.count-1)
        cell.showBottomLine=NO;
    else
        cell.showBottomLine=YES;
    
    return cell;
}


#pragma mark - LWAuthManagerDelegate

-(void) authManager:(LWAuthManager *)manager didGetHistory:(LWPacketGetHistory *)packet
{
    _operations=[LWHistoryManager convertHistoryToArrayOfArrays:packet.historyArray];
    
    [refreshControl endRefreshing];
    
    [self setLoading:NO];
    
    if(_operations.count)
        self.tableView.showsVerticalScrollIndicator=YES;
    else
        self.tableView.showsVerticalScrollIndicator=NO;
    
    if(!_operations.count && [self isKindOfClass:[LWHistoryPresenter class]])
    {
        if(!_emptyHistoryPresenter)
        {
            _emptyHistoryPresenter=[[LWEmptyHistoryPresenter alloc] init];
            _emptyHistoryPresenter.buttonText=@"MAKE FIRST TRANSACTION";
            _emptyHistoryPresenter.depositAction=^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowExchangeViewControllerNotification" object:nil];
            };
            _emptyHistoryPresenter.view.frame=self.view.bounds;
            
            //        [self.view addSubview:emptyHistoryPresenter.view];
            [self addChildViewController:_emptyHistoryPresenter];
        }
    }
    else
    {
        [self.emptyHistoryPresenter.view removeFromSuperview];
        [self.emptyHistoryPresenter removeFromParentViewController];
        self.emptyHistoryPresenter=nil;
    }
    
    
    
    [self.tableView reloadData];


}



-(void) authManager:(LWAuthManager *) manager didGetBlockchainTransaction:(LWAssetBlockchainModel *)blockchain
{
    [self setLoading:NO];
    
    if (blockchain) {
        [self showBlockchainView:blockchain];
    }
}

//
//
//- (void)authManager:(LWAuthManager *)manager didReceiveTransactions:(LWTransactionsModel *)transactions {
//    _operations = [LWHistoryManager convertNetworkModel:transactions];
//    _sortedKeys = [LWHistoryManager sortKeys:_operations];
//    
//    [refreshControl endRefreshing];
//    
//    [self setLoading:NO];
//    [self.tableView reloadData];
//}
//
//- (void)authManager:(LWAuthManager *)manager didGetBlockchainCashTransaction:(LWAssetBlockchainModel *)blockchain {
//    [self setLoading:NO];
//    
//    if (blockchain) {
//        [self showBlockchainView:blockchain];
//    }
//    else {
//        // need extra data - request
//        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
//        if (item) {
//            LWCashEmptyBlockchainPresenter *emptyPresenter = [LWCashEmptyBlockchainPresenter new];
//            LWCashInOutHistoryItemType *model = (LWCashInOutHistoryItemType *)item;
//            emptyPresenter.model = [model copy];
//            [self.navigationController pushViewController:emptyPresenter animated:YES];
//        }
//    }
//}
//
//- (void)authManager:(LWAuthManager *)manager didGetBlockchainExchangeTransaction:(LWAssetBlockchainModel *)blockchain {
//    if (blockchain) {
//        [self setLoading:NO];
//        [self showBlockchainView:blockchain];
//    }
//    else {
//        // need extra data - request
//        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
//        if (!item) {
//            [self setLoading:NO];
//        }
//        else {
//            [[LWAuthManager instance] requestExchangeInfo:item.identity];
//        }
//    }
//}
//
//- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransferTransaction:(LWAssetBlockchainModel *)blockchain {
//    [self setLoading:NO];
//    
//    if (blockchain) {
//        [self showBlockchainView:blockchain];
//    }
//    else {
//        // need extra data - request
//        LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
//        if (item) {
//            LWTransferEmptyBlockchainPresenter *emptyPresenter = [LWTransferEmptyBlockchainPresenter new];
//            LWTransferHistoryItemType *model = (LWTransferHistoryItemType *)item;
//            emptyPresenter.model = [model copy];
//            [self.navigationController pushViewController:emptyPresenter animated:YES];
//        }
//    }
//}
//
//- (void)authManager:(LWAuthManager *)manager didReceiveExchangeInfo:(LWExchangeInfoModel *)exchangeInfo {
//    [self setLoading:NO];
//    
//    // need extra data - request
//    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:self.loadedElement];
//    if (item) {
//        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
//        LWExchangeEmptyBlockchainPresenter *presenter = [LWExchangeEmptyBlockchainPresenter new];
//        presenter.model = [exchangeInfo copy];
//        presenter.asset = trade.asset;
//        [self.navigationController pushViewController:presenter animated:YES];
//    }
//}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [refreshControl endRefreshing];
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_operations.count==0)
    {
        return;
    }
    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:indexPath];
    if (!item) {
        return;
    }
    [refreshControl endRefreshing];
    
    if(item.blockchainHash && item.blockchainHash.length)
    {
        [self setLoading:YES];
 //       [[LWAuthManager instance] requestBlockchainOrderTransaction:item.blockchainHash];
        [[LWAuthManager instance] requestBlockchainOrderTransaction:item.identity];
        return;
    }
    
    if (item && item.historyType == LWHistoryItemTypeTrade) {
        
        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
        LWExchangeEmptyBlockchainPresenter *presenter = [LWExchangeEmptyBlockchainPresenter new];
        presenter.model = [trade.marketOrder copy];
        presenter.asset = trade.asset;
        [self.navigationController pushViewController:presenter animated:YES];

        
        
        
//        [self setLoading:YES];
//        self.loadedElement = indexPath;
//        [[LWAuthManager instance] requestBlockchainExchangeTransaction:item.identity];
    }
    else if (item && item.historyType == LWHistoryItemTypeCashInOut) {
        LWCashEmptyBlockchainPresenter *emptyPresenter = [LWCashEmptyBlockchainPresenter new];
        LWCashInOutHistoryItemType *model = (LWCashInOutHistoryItemType *)item;
        emptyPresenter.model = [model copy];
        [self.navigationController pushViewController:emptyPresenter animated:YES];

//        
//        
//        
//        [self setLoading:YES];
//        self.loadedElement = indexPath;
//        [[LWAuthManager instance] requestBlockchainCashTransaction:item.identity];
    }
    else if (item && item.historyType == LWHistoryItemTypeTransfer) {
        
        LWTransferEmptyBlockchainPresenter *emptyPresenter = [LWTransferEmptyBlockchainPresenter new];
        LWTransferHistoryItemType *model = (LWTransferHistoryItemType *)item;
        emptyPresenter.model = [model copy];
        [self.navigationController pushViewController:emptyPresenter animated:YES];

//        [self setLoading:YES];
//        self.loadedElement = indexPath;
//        [[LWAuthManager instance] requestBlockchainTransferTrnasaction:item.identity];
    }
}


#pragma mark - Utils

- (void)updateCell:(LWHistoryTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    LWBaseHistoryItemType *item = [self getHistoryItemByIndexPath:indexPath];
    if (!item) {
        return;
    }
    
    cell.type=item.historyType;
    
    NSNumber *volume = [NSNumber numberWithDouble:0];
    NSString *operation = @"";
//    if (item.historyType == LWHistoryItemTypeTrade) {
//        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
//        [self setImageType:trade.iconId forImageView:cell.operationImageView];
//        
//        volume = trade.volume;
//        
//        NSString *base = [LWAssetModel
//                          assetByIdentity:trade.asset
//                          fromList:[LWCache instance].allAssets];
//        
//        NSString *type = (volume.doubleValue >= 0
//                          ? Localize(@"history.market.buy")
//                          : Localize(@"history.market.sell"));
//        
//        
//        operation = [NSString stringWithFormat:@"%@ %@", base, type];
//        
//        
//        
//    }
//    else if (item.historyType == LWHistoryItemTypeCashInOut) {
//        LWCashInOutHistoryItemType *cash = (LWCashInOutHistoryItemType *)item;
//        [self setImageType:cash.iconId forImageView:cell.operationImageView];
//        volume = cash.amount;
//        
//        NSString *base = [LWAssetModel
//                          assetByIdentity:cash.asset
//                          fromList:[LWCache instance].allAssets];
//        
//        NSString *type = (volume.doubleValue >= 0
//                          ? Localize(@"history.cash.in")
//                          : Localize(@"history.cash.out"));
//        if(cash.isRefund)
//            type=Localize(@"history.cash.refund");
//        operation = [NSString stringWithFormat:@"%@ %@", base, type];
//    }
//
//    else if (item.historyType == LWHistoryItemTypeTransfer) {
//        LWTransferHistoryItemType *transfer = (LWTransferHistoryItemType *)item;
////        [self setImageTransfer:transfer.iconId forImageView:cell.operationImageView];
//        [self setImageType:transfer.iconId forImageView:cell.operationImageView];
//        volume = transfer.volume;
//        
//        NSString *base = [LWAssetModel
//                          assetByIdentity:transfer.asset
//                          fromList:[LWCache instance].baseAssets];
//        
//        NSString *type = (volume.doubleValue >= 0
//                          ? Localize(@"history.transfer.in")
//                          : Localize(@"history.transfer.out"));
//        
//        operation = [NSString stringWithFormat:@"%@ %@", base, type];
//    }

    volume=item.volume;
    cell.volume=volume;
    [self setImageType:item.iconId forImageView:cell.operationImageView];
    
    NSString *walletName=@"";
    if([item.iconId isEqualToString:@"BTC"])
        walletName=@"BTC Wallet";
    else if([item.iconId isEqualToString:@"LKE"])
        walletName=@"My Lykke Wallet";
    
    cell.walletNameLabel.text=walletName;
    
    // prepare value label
    NSString *sign = (volume.doubleValue >= 0.0) ? @"+" : @"";
    NSInteger const precision = [LWAssetsDictionaryItem assetAccuracyById:item.asset];
    NSString *changeString = [LWMath historyPriceString:volume precision:precision withPrefix:sign];
    
    changeString=[changeString stringByAppendingFormat:@" %@", item.asset];
    
    UIColor *changeColor = (volume.doubleValue >= 0.0)
    ? [UIColor colorWithHexString:kAssetChangePlusColor]
    : [UIColor colorWithHexString:kAssetChangeMinusColor];
    cell.volumeLabel.textColor = changeColor;
    cell.volumeLabel.text = changeString;
    
//    cell.typeLabel.text = operation;
    cell.dateLabel.text = [item.dateTime toShortFormat];
    
    
    cell.contentView.alpha=1;
    if([item respondsToSelector:@selector(blockchainHash)])
    {
        LWTradeHistoryItemType *trade = (LWTradeHistoryItemType *)item;
        if(!trade.isSettled)
        {
            
            
            cell.contentView.alpha=0.20;
            cell.volumeLabel.textColor=[UIColor blackColor];
//            cell.valueLabel.textColor=[UIColor colorWithHexString:@"D3D6DB"];
//            cell.typeLabel.textColor=[UIColor colorWithHexString:@"D3D6DB"];
//            cell.dateLabel.textColor=[UIColor colorWithHexString:@"D3D6DB"];
        }
        else
        {
            NSLog(@"BlockchainHash is not empty");
        }
        
    }
    
    [cell update];
    
//    cell.valueLabel.textColor=[UIColor colorWithHe] //Andrey
    
#ifdef PROJECT_IATA
    cell.separatorInset = UIEdgeInsetsMake(0, 38, 0, 38);
#endif
}

- (void)setRefreshControl {
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[LWRefreshControlView alloc] init];
//    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(reloadHistory)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];
    

//    LWRefreshControlView *v=[[LWRefreshControlView alloc] initWithFrame:refreshControl.bounds];
//    refreshControl.autoresizesSubviews=YES;
//    [refreshControl addSubview:v];
    
    
}

- (void)reloadHistory {
//    [refreshControl endRefreshing];
//    [self setLoading:YES];
//    [[LWAuthManager instance] requestTransactions:self.assetId];
//    if([self isKindOfClass:[LWHistoryPresenter class]])
    if(self.isViewLoaded && self.view.window)
        [[LWAuthManager instance] requestGetHistory:self.assetId];
}

- (LWBaseHistoryItemType *)getHistoryItemByIndexPath:(NSIndexPath *)indexPath {
    return _operations[indexPath.section][indexPath.row];
    
//    NSString *key = [self.sortedKeys objectAtIndex:indexPath.section];
//    if (key) {
//        NSArray *items = self.operations[key];
//        if (items) {
//            LWBaseHistoryItemType *item = (LWBaseHistoryItemType *)([items objectAtIndex:indexPath.row]);
//            
//            return item;
//        }
//    }
//    return nil;
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



-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) orientationChanged
{
    [self.tableView reloadData];
}



@end
