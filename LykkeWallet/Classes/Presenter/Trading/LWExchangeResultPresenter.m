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
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                            self.purchase.assetPair,
                            Localize(@"exchange.assets.result.title")];
    
    [self.closeButton setTitle:Localize(@"exchange.assets.result.close")
                      forState:UIControlStateNormal];
    
    [self.shareButton setTitle:Localize(@"exchange.assets.result.share")
                      forState:UIControlStateNormal];
    
#ifdef PROJECT_IATA
#else
    [self.closeButton setGrayPalette];
#endif
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion

    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    NSString *const values[kNumberOfRows] = {
        self.purchase.assetPair,
        [LWMath makeStringByNumber:self.purchase.volume withPrecision:self.purchase.accuracy.integerValue],
        [LWMath makeStringByNumber:self.purchase.price withPrecision:self.purchase.accuracy.integerValue],
        //[LWMath makeStringByNumber:self.purchase.commission withPrecision:2],
        [LWMath makeStringByNumber:self.purchase.totalCost withPrecision:2],
        self.purchase.blockchainSettled ? self.purchase.blockchainId : Localize(@"exchange.assets.result.blockchain.progress")
        //[LWMath makeStringByNumber:self.purchase.position withPrecision:0]
    };
    
    return values[row];
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
