
//
//  LWExchangePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangePresenter.h"
#import "LWExchangeFormPresenter.h"
#import "LWTradingGraphPresenter.h"
#import "LWAssetTableViewCell.h"
#import "LWAssetLykkeTableViewCell.h"
#import "LWAssetEmptyTableViewCell.h"
#import "LWAssetPairModel.h"
#import "LWAssetPairRateModel.h"
#import "LWPacketLastBaseAssets.h"
#import "LWCache.h"
#import "UIViewController+Loading.h"

#import "LWTradingLinearGraphPresenter.h"

#import "LWIPadModalNavigationControllerViewController.h"

#import "UINavigationItem+Kerning.h"
#import "LWExchangeBaseAssetsView.h"


#define emptyCellIdentifier @"LWAssetEmptyTableViewCellIdentifier"


@interface LWExchangePresenter () <LWAssetLykkeTableViewCellDelegate, LWExchangeBaseAssetsViewDelegate> {
    NSMutableIndexSet   *expandedSections;
    NSMutableDictionary *pairRates;
    NSTimer *timer;
    BOOL isLoadingRatesNow;
    NSString *lastBaseAsset;
    
}


#pragma mark - Properties

// array of LWAssetPairModel
@property (readonly, nonatomic) NSArray *assetPairs;


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView      *headerView;
@property (weak, nonatomic) IBOutlet UILabel     *selectAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel     *assetHeaderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *assetHeaderPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel     *assetHeaderChangeLabel;

@property (weak, nonatomic) IBOutlet LWExchangeBaseAssetsView *baseAssetsView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerBottomLineHeight;


@end


@implementation LWExchangePresenter


#ifdef PROJECT_IATA
static NSInteger const kNumberOfSections = 1;
static NSInteger const kSectionLykkeAssets = 0;

static NSString *cellIdentifier = @"LWAssetTableViewCellIdentifier";

static NSString *const AssetIdentifiers[kNumberOfSections] = {
    @"LWAssetLykkeTableViewCellIdentifier"
};

static NSString *const AssetNames[kNumberOfSections] = {
    @"IATA"
};

static NSString *const AssetIcons[kNumberOfSections] = {
    @"IATAWallet"
};
#else
static NSInteger const kNumberOfSections = 1;
static NSInteger const kSectionLykkeAssets = 0;

static NSString *cellIdentifier = @"LWAssetTableViewCellIdentifier";

static NSString *const AssetIdentifiers[kNumberOfSections] = {
    @"LWAssetLykkeTableViewCellIdentifier"
};

static NSString *const AssetNames[kNumberOfSections] = {
    @"LYKKE"
};

static NSString *const AssetIcons[kNumberOfSections] = {
    @"WalletLykke"
};
#endif

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerTopLineHeight.constant=0.5f;
    self.headerBottomLineHeight.constant=0.5f;
    
    isLoadingRatesNow=NO;

//    self.title = Localize(@"tab.trading");
    
    [self setTitle:Localize(@"tab.trading")];
    
    expandedSections = [NSMutableIndexSet new];
    pairRates = [NSMutableDictionary new];
    
    [self registerCellWithIdentifier:cellIdentifier
                                name:@"LWAssetTableViewCell"];
    
    [self registerCellWithIdentifier:AssetIdentifiers[0]
                                name:@"LWAssetLykkeTableViewCell"];
    
    [self registerCellWithIdentifier:emptyCellIdentifier
                             name:@"LWAssetEmptyTableViewCell"];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    // Expand cells if needed
    if (![expandedSections containsIndex:0]) {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    self.baseAssetsView.delegate=self;
    
    UIColor *headersColor=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
    self.assetHeaderNameLabel.textColor=headersColor;
    self.assetHeaderPriceLabel.textColor=headersColor;
    self.assetHeaderChangeLabel.textColor=headersColor;
    
//    NSNumber *nnn=[LWCache instance].refreshTimer;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:Localize(@"tab.trading")];

    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
    
#ifdef PROJECT_IATA
    self.headerView.backgroundColor = self.navigationController.navigationBar.barTintColor;
#endif
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle:Localize(@"tab.trading")];
    [self.baseAssetsView checkCurrentBaseAsset];
    

    isLoadingRatesNow=NO;
    timer=[NSTimer timerWithTimeInterval:[LWCache instance].refreshTimer.integerValue/1000 target:self selector:@selector(loadRates) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    if([lastBaseAsset isEqualToString:[LWCache instance].baseAssetId]==NO)
        [pairRates removeAllObjects];
    if(!self.assetPairs || [lastBaseAsset isEqualToString:[LWCache instance].baseAssetId]==NO)
    {
        [self setLoading:YES];
    }
    [[LWAuthManager instance] requestAssetPairs];
    [[LWAuthManager instance] requestLastBaseAssets];

    

}

-(void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}


#pragma mark - TKPresenter

- (void)localize {
    self.selectAssetLabel.text = Localize(@"exchange.assets.selection");
    self.assetHeaderNameLabel.text = Localize(@"exchange.assets.header.issuer");
    self.assetHeaderPriceLabel.text = Localize(@"exchange.assets.header.price");
    self.assetHeaderChangeLabel.text = Localize(@"exchange.assets.header.change");
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([expandedSections containsIndex:section] && self.assetPairs)
    {
        int const rowCell = 1;
        if (section == kSectionLykkeAssets && self.assetPairs) {
            return MAX(1, self.assetPairs.count) + rowCell;
        }
        else {
            return 2; // general + empty
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat const kStandardHeight = 50.0;
    return kStandardHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    // Show category row
    if (!indexPath.row) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        LWAssetTableViewCell *asset = (LWAssetTableViewCell *)cell;
        if (asset == nil)
        {
            asset = (LWAssetTableViewCell *)[[UITableViewCell alloc]
                                             initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:cellIdentifier];
        }
        
        NSDictionary *attributes = @{NSKernAttributeName:@(1.9)};

        asset.assetLabel.attributedText = [[NSAttributedString alloc] initWithString:AssetNames[indexPath.section] attributes:attributes];
        asset.assetImageView.image = [UIImage imageNamed:AssetIcons[indexPath.section]];
    }
    // Show wallets for category
    else {
        NSString *identifier = AssetIdentifiers[indexPath.section];
        // Lykke cells
        if (indexPath.section == kSectionLykkeAssets) {
            if (self.assetPairs) {
                // Show Lykke Wallets
                if (self.assetPairs.count > 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWAssetLykkeTableViewCell *asset = (LWAssetLykkeTableViewCell *)cell;
                    LWAssetPairModel *assetPair = (LWAssetPairModel *)self.assetPairs[indexPath.row - 1];
                    asset.pair = assetPair;
                    asset.rate = pairRates[assetPair.identity];
                    asset.delegate = self;
                }
                // Show Empty
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
                }
            }
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger const row = indexPath.row;
    // react for assets
    if (row != 0) {
        // lykke assets
        if (indexPath.section == 0) {
            LWAssetPairModel *model = (LWAssetPairModel *)self.assetPairs[row - 1];
            // validate pair
            if (model) {
                LWAssetPairRateModel *rate = pairRates[model.identity];
                // validate rate
                if (rate) {
                    LWExchangeFormPresenter *form = [LWExchangeFormPresenter new];
                    form.assetPair = model;
                    form.assetRate = rate;
                    
                    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
                        [self.navigationController pushViewController:form animated:YES];
                    else
                    {
                        LWIPadModalNavigationControllerViewController *navigationController =
                        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:form];
                        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                        navigationController.transitioningDelegate=navigationController;
                        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                    }

                }
            }
        }
    }
    // react just for headers
    else //Do not collapse  when we have only one section
    {
        // only first row toggles exapand/collapse
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSInteger section = indexPath.section;
        BOOL currentlyExpanded = [expandedSections containsIndex:section];
        if(currentlyExpanded==NO || kNumberOfSections>1)
        {
            NSInteger rows = 0;
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSections removeIndex:section];
            }
            else
            {
                [expandedSections addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i = 1; i < rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                               inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            
            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
            }
            else
            {
                [tableView insertRowsAtIndexPaths:tmpArray
                                 withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    }
}

#ifdef PROJECT_IATA
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.separatorInset = UIEdgeInsetsMake(0, 38, 0, 38);
    }
    else {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#endif


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetAssetPairs:(NSArray *)assetPairs {
    _assetPairs = assetPairs;
    
    [[LWAuthManager instance] requestAssetPairRates];
    
    [self.tableView reloadData];
//    if(pairRates.allKeys.count)
//        [self setLoading:NO];
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    isLoadingRatesNow=NO;
    [self showReject:reject response:context.task.response code:context.error.code willNotify:NO];


}

- (void)authManager:(LWAuthManager *)manager didGetAssetPairRates:(NSArray *)assetPairRates {
    if(_assetPairs==nil)
        return;
    for (LWAssetPairRateModel *rate in assetPairRates) {
        if((pairRates[rate.identity] && [pairRates[rate.identity] inverted]==rate.inverted) || !pairRates[rate.identity])
            pairRates[rate.identity] = rate;
        else
        {
            NSLog(@"Tried to change reverse back");
        }
    }
    [self setLoading:NO];
    
    isLoadingRatesNow=NO;

    [self.tableView reloadData];

    NSInteger repeatSeconds = [LWCache instance].refreshTimer.integerValue / 1000;
    
//    repeatSeconds=1000;//Testing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    [self loadRates];
   });
    
    lastBaseAsset=[LWCache instance].baseAssetId;
}

-(void) authManager:(LWAuthManager *)manager didGetLastBaseAssets:(LWPacketLastBaseAssets *)lastAssets
{
    [_baseAssetsView createButtonsWithAssets:lastAssets.lastAssets];
}


-(void) loadRates
{
    if(self.isVisible && isLoadingRatesNow==NO)
    {
        isLoadingRatesNow=YES;
        [[LWAuthManager instance] requestAssetPairRates];
    }
}



-(void) authManagerDidSetAsset:(LWAuthManager *)manager
{
    _assetPairs=nil;
    [pairRates removeAllObjects];
    [self setLoading:YES];
    [[LWAuthManager instance] requestAssetPairs];
    [[LWAuthManager instance] requestLastBaseAssets];
}


#pragma mark - LWAssetLykkeTableViewCellDelegate

- (void)graphClicked:(LWAssetLykkeTableViewCell *)cell {
    
    LWTradingLinearGraphPresenter *presenter=[[LWTradingLinearGraphPresenter alloc] init];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    LWAssetPairModel *assetPair = (LWAssetPairModel *)self.assetPairs[indexPath.row - 1];
    if (assetPair) {
        
        assetPair.inverted=[pairRates[assetPair.identity] inverted];
        presenter.assetPair = assetPair;
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

    }

    
//
//    LWTradingGraphPresenter *presenter = [LWTradingGraphPresenter new];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    LWAssetPairModel *assetPair = (LWAssetPairModel *)self.assetPairs[indexPath.row - 1];
//    if (assetPair) {
//        presenter.assetPair = assetPair;
//        [self.navigationController pushViewController:presenter animated:YES];
//    }
}


#pragma mark - LWExchangeBaseAssetsViewDelegate

-(void) baseAssetsViewChangedBaseAsset:(NSString *)assetId
{
    [self setLoading:YES];
    _assetPairs=nil;
    [[LWAuthManager instance] requestBaseAssetSet:assetId];
    [LWCache instance].baseAssetId=assetId;
}

-(void) dealloc
{
    [timer invalidate];
}

@end
