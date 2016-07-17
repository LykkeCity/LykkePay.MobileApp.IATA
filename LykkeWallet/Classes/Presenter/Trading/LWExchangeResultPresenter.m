//
//  LWExchangeResultPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeResultPresenter.h"
#import "LWExchangeBlockchainPresenter.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWAssetPairModel.h"
#import "LWAssetDealModel.h"
#import "LWAssetBlockchainModel.h"
#import "LWConstants.h"
#import "LWMath.h"
#import "LWAuthManager.h"
#import "TKButton.h"
#import "UIViewController+Loading.h"
#import "LWValidator.h"
#import "LWUtils.h"
#import "LWCache.h"
#import "LWAssetModel.h"


@interface LWExchangeResultPresenter () {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet TKButton *closeButton;
@property (weak, nonatomic) IBOutlet TKButton *shareButton;


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;

@end


@implementation LWExchangeResultPresenter


static int const kNumberOfRows = 5;
static int const kBlockchainRow = 4;


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    [self setRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *oper;

    if([self.purchase.orderType isEqualToString:@"Buy"])
        oper=Localize(@"exchange.assets.result.boughtfor");
    else
        oper=Localize(@"exchange.assets.result.soldfor");
    self.titleLabel.text=[NSString stringWithFormat:@"%@ %@ %@", self.purchase.baseAsset, oper, [self.purchase.assetPair stringByReplacingOccurrencesOfString:self.purchase.baseAsset withString:@""]];
    
//    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",
//                            self.purchase.assetPair,
//                            Localize(@"exchange.assets.result.title")];
    
    [self.closeButton setTitle:Localize(@"exchange.assets.result.close")
                      forState:UIControlStateNormal];
    
    [self.shareButton setTitle:Localize(@"exchange.assets.result.share")
                      forState:UIControlStateNormal];
    
    [LWValidator setButtonWithClearBackground:self.closeButton enabled:YES];
    [LWValidator setButton:self.shareButton enabled:YES];
    
#ifdef PROJECT_IATA
#else
    [self.closeButton setGrayPalette];
#endif
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion

    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#endif


#pragma mark - Actions

- (IBAction)closeClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        UIColor *blockchainColor = self.purchase.blockchainSettled
        ? [UIColor colorWithHexString:kMainElementsColor]
        : [UIColor colorWithHexString:kMainDarkElementsColor];
        [cell.detailLabel setTextColor:blockchainColor];
    }
}

- (NSString *)dataByCellRow:(NSInteger)row {
    
    
    NSString *assetName=self.assetPair.name;
    NSArray *arr=[assetName componentsSeparatedByString:@"/"];
    
    
    
    if(self.assetPair.inverted)
    if(!([self.assetPair.baseAssetId isEqualToString:_purchase.baseAsset] && self.assetPair.inverted))
    {
        if(arr.count==2)
        {
            assetName=[NSString stringWithFormat:@"%@/%@", arr[1], arr[0]];
        }
    }
    if(arr.count!=2)
        arr=@[@"",@""];
    
    
//    if((self.assetPair.inverted && [self.purchase.orderType isEqualToString:@"Buy"]) || (self.assetPair.inverted==NO && [self.purchase.orderType isEqualToString:@"Sell"]))
//    if(!([self.assetPair.baseAssetId isEqualToString:_purchase.baseAsset] && self.assetPair.inverted))
//    {
//        arr=@[arr[1], arr[0]];
//   
//    }
    
    NSString *buyAssetId=self.purchase.baseAsset;
    NSString *sellAssetId;
    if([buyAssetId isEqualToString:self.assetPair.baseAssetId])
    {
        sellAssetId=self.assetPair.quotingAssetId;
    }
    else
        sellAssetId=self.assetPair.baseAssetId;

    
//    if((self.assetPair.inverted && [self.purchase.orderType isEqualToString:@"Sell"]) || (self.assetPair.inverted==NO && [self.purchase.orderType isEqualToString:@"Sell"]))
    if([self.purchase.orderType isEqualToString:@"Sell"])
    {
        NSString *tmp=buyAssetId;
        buyAssetId=sellAssetId;
        sellAssetId=tmp;
    }
    
    
    
    
    NSString *const values[kNumberOfRows] = {
        assetName,
        
        
        [[LWUtils stringFromDouble:self.purchase.volume.doubleValue] stringByAppendingFormat:@" %@", [LWCache nameForAsset:buyAssetId]],
        [LWUtils stringFromDouble:self.purchase.price.doubleValue],
        [[LWUtils stringFromDouble:self.purchase.totalCost.doubleValue] stringByAppendingFormat:@" %@", [LWCache nameForAsset:sellAssetId]],

        self.purchase.blockchainSettled ? self.purchase.blockchainId : Localize(@"exchange.assets.result.blockchain.progress")
        
    };
    
    return values[row];
}

#pragma mark - Need to refactor (copied from LWExchangeDealFormPresenter

-(NSNumber *) accuracyForBaseAsset
{
    NSArray *assets=[LWCache instance].allAssets;
    NSString *identity=[LWCache instance].baseAssetId;
    NSNumber *accuracy=@(0);
    for(LWAssetModel *m in assets)
    {
        if([m.identity isEqualToString:identity])
        {
            accuracy=m.accuracy;
            break;
        }
    }
    
    return accuracy;
}

-(NSNumber *) accuracyForQuotingAsset
{
    NSArray *assets=[LWCache instance].allAssets;
    NSString *identity=[LWCache instance].baseAssetId;
    if([self.purchase.baseAsset isEqualToString:identity]==NO)
    {
        identity=self.purchase.baseAsset;
    }
    NSNumber *accuracy=@(0);
    for(LWAssetModel *m in assets)
    {
        if([m.identity isEqualToString:identity])
        {
            accuracy=m.accuracy;
            break;
        }
    }
    
    return accuracy;
    
}

- (void)startRefreshControl {
    if (!self.purchase || !self.purchase.blockchainSettled) {
        [super startRefreshControl];
        [[LWAuthManager instance] requestMarketOrder:self.purchase.identity];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == kBlockchainRow && self.purchase
        && self.purchase.blockchainSettled) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestBlockchainOrderTransaction:self.purchase.identity];
    }
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self stopRefreshControl];
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didReceiveMarketOrder:(LWAssetDealModel *)purchase {
    [self stopRefreshControl];
    [self setLoading:NO];
    
    self.purchase = purchase;
    [self.tableView reloadData];
}

- (void)authManager:(LWAuthManager *)manager didGetBlockchainTransaction:(LWAssetBlockchainModel *)blockchain {
    [self stopRefreshControl];
    [self setLoading:NO];

    LWExchangeBlockchainPresenter *controller = [LWExchangeBlockchainPresenter new];
    controller.blockchainModel = blockchain;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
