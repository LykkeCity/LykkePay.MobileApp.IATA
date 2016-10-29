//
//  LWWalletsPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 08.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWWalletsPresenter.h"
#import "LWHistoryPresenter.h"
#import "LWWalletFormPresenter.h"
#import "LWExchangeDealFormPresenter.h"
#import "LWWalletDepositPresenter.h"
#import "LWBitcoinDepositPresenter.h"
#import "LWTradingWalletPresenter.h"
#import "LWAuthManager.h"
#import "LWLykkeWalletsData.h"
#import "LWLykkeData.h"
#import "LWLykkeAssetsData.h"
#import "LWBankCardsData.h"
#import "LWWalletTableViewCell.h"
#import "LWLykkeTableViewCell.h"
#import "LWBanksTableViewCell.h"
#import "LWBitcoinTableViewCell.h"
#import "LWWalletsLoadingTableViewCell.h"
#import "LWWalletEmptyTableViewCell.h"
#import "LWLykkeEmptyTableViewCell.h"
#import "LWAuthNavigationController.h"
#import "LWAssetsDictionaryItem.h"
#import "LWKeychainManager.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "LWMath.h"
#import "UIViewController+Loading.h"
#import "LWCurrencyDepositPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWRegisterCameraPresenter.h"
#import "LWAuthSteps.h"
#import "UIViewController+Navigation.h"
#import "LWKYCManager.h"
#import "LWCreditCardDepositPresenter.h"
#import "LWRefreshControlView.h"
#import "LWMyLykkeBuyPresenter.h"
#import "LWMyLykkeIpadController.h"
#import "LWEtheriumDepositPresenter.h"
#import "LWLykkeBuyTransferContainer.h"
#import "LWPacketCategories.h"
#import "LWAssetCategoryModel.h"
#import "LWImageDownloader.h"


static NSInteger const kSectionBankCards      = 0;
static NSInteger const kSectionLykkeWallets   = 1;
static NSInteger const kSectionBitcoinWallets = 2;


@interface LWWalletsPresenter ()<UITableViewDelegate, UITableViewDataSource, LWWalletTableViewCellDelegate, LWLykkeEmptyTableViewCellDelegate, LWLykkeTableViewCellDelegate, LWBitcoinTableViewCellDelegate, SWTableViewCellDelegate> {
    
    NSMutableIndexSet *expandedSections;
    UIRefreshControl  *refreshControl;
    
    BOOL               shouldShowError;
    
    UIImageView *screenshot;
    NSNumber *balanceToSellCompletely;
    NSArray *categories;
    
    
}


#pragma mark - Properties

@property (readonly, nonatomic) LWLykkeWalletsData *data;



#pragma mark - Utils

- (void)expandTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (NSString *)assetIdentifyForIndexPath:(NSIndexPath *)indexPath;

- (void)showDealFormForIndexPath:(NSIndexPath *)indexPath;
- (void)setRefreshControl;
- (void)reloadWallets;
- (void)showDepositPage:(NSIndexPath *)indexPath;
- (void)showTradingWallet:(NSIndexPath *)indexPath;
- (UIButton *)createUtilsButton;

@end


@implementation LWWalletsPresenter




#pragma mark - Lifecycle

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"tab.wallets");
    

}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [screenshot removeFromSuperview];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(screenshot)
    {
        if(screenshot.image.size.width/screenshot.image.size.height!=self.view.bounds.size.width/self.view.bounds.size.height)
        {
            [screenshot removeFromSuperview];
            screenshot=nil;
            [self setLoading:YES];
        }
        else
            screenshot.frame=self.view.bounds;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"tab.wallets");
    [self registerCellWithIdentifier:kWalletTableViewCellIdentifier
                             name:kWalletTableViewCell];
    [self registerCellWithIdentifier:kLykkeTableViewCellIdentifier
                             name:kLykkeTableViewCell];
    
    [self registerCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier
                             name:kLykkeEmptyTableViewCell];

    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    shouldShowError = NO;
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    [self setRefreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWallets) name:@"ApplicationDidBecomeActiveNotification" object:nil];
    
    if(!categories)
    {
        [LWAuthManager instance].caller=self;
        [[LWAuthManager instance] requestAssetCategories];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
    [self requestWallets];
    
    
    
    UIImage *image=[self screenshotImage];
    if(image && self.data==nil)
    {
        screenshot=[[UIImageView alloc] initWithFrame:self.view.bounds];
        screenshot.image=image;
        [self.view addSubview:screenshot];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(screenshot && self.data==nil)
                [self setLoading:YES];
        });

    }
    
    
}

-(void) requestWallets
{
    if(![LWCache instance].allAssets || !categories)
        [self performSelector:@selector(requestWallets) withObject:nil afterDelay:1];
    else
    {
        [LWAuthManager instance].caller=self;
        [[LWAuthManager instance] requestLykkeWallets];
        
    }
    
}

-(void) authManager:(LWAuthManager *)manager didGetAssetCategories:(LWPacketCategories *)packet
{
    categories=packet.categories;
    
    expandedSections = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < categories.count; i++)
        [expandedSections addIndex:i];

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([expandedSections containsIndex:section])
    {
        if (self.data) {
            return [[categories[section] assets] count]+1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    // Show category row
    if (!indexPath.row) {
        cell = [tableView dequeueReusableCellWithIdentifier:kWalletTableViewCellIdentifier];
        LWWalletTableViewCell *wallet = (LWWalletTableViewCell *)cell;
        
        
        
        
        if (wallet == nil)
        {
            wallet = (LWWalletTableViewCell *)[[UITableViewCell alloc]
                                    initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kWalletTableViewCellIdentifier];
        }
        
        wallet.delegate = self;
        

        NSDictionary *attributes = @{NSKernAttributeName:@(1.9)};

        
        LWAssetCategoryModel *cat=categories[indexPath.section];
        
        wallet.walletLabel.attributedText = [[NSAttributedString alloc] initWithString:cat.name attributes:attributes];
       if(!cat.iconImage)
       {
           [[LWImageDownloader shared] downloadImageFromURLString:cat.iconUrl shouldAuthenticate:NO withCompletion:^(UIImage *image){
               if(image)
               {
                   cat.iconImage=image;
                   wallet.walletImageView.image=image;
               }
           }];
       }
        else
            wallet.walletImageView.image = cat.iconImage;
        
        
        wallet.addWalletButton.hidden=YES;

    }
    // Show wallets for category
    else {
        NSString *identifier = kLykkeTableViewCellIdentifier;
            if (self.data) {
                // Show Lykke Wallets
 
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWLykkeTableViewCell *lykke = (LWLykkeTableViewCell *)cell;
                    lykke.cellDelegate = self;
                    
                    LWLykkeAssetsData *asset = [[categories[indexPath.section] assets] objectAtIndex:indexPath.row-1];
                    NSInteger const accuracy = [LWAssetsDictionaryItem assetAccuracyById:asset.identity];
                    NSString *balance = [LWMath historyPriceString:asset.balance
                                                              precision:accuracy
                                                             withPrefix:@""];
                    lykke.walletNameLabel.text = asset.name;
                    lykke.walletBalanceLabel.text = [NSString stringWithFormat:@"%@ %@",
                                                     asset.symbol, balance];
                    
                    lykke.addWalletButton.hidden=[LWCache shouldHideDepositForAssetId:asset.identity];
                    
                    
                    // validate for base asset and balance
                    if ((![asset.identity isEqualToString:[LWCache instance].baseAssetId] && asset.balance.doubleValue > 0.0)) {
                        CGFloat const buttonWidth = 120.0;
                        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                        [rightUtilityButtons sw_addUtilityButton:[self createUtilsButton]];
                        [lykke setRightUtilityButtons:rightUtilityButtons WithButtonWidth:buttonWidth];

                        lykke.delegate = self;
                    }
                    else
                        lykke.rightUtilityButtons=nil;
            }
            else {
                // loading indicator cell
                             cell=[[LWWalletsLoadingTableViewCell alloc] init];
          
            }
        }

    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // show history for selected asset
    if (indexPath.row != 0) {
        
        
        [self showTradingWallet:indexPath];

    }
    // expand / close wallet
    else {
        [self expandTable:tableView indexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0 && [[categories[indexPath.section] assets] count]==0)
        return 0;
        
    CGFloat const kStandardHeight = 50.0;
    return kStandardHeight;
}


#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self showDealFormForIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data {
    [refreshControl endRefreshing];
    [self setLoading:NO];

    shouldShowError = NO;

    _data = data;
    
    for(LWAssetCategoryModel *m in categories)
    {
        m.assets=[[NSMutableArray alloc] init];
    }
    
    for(LWLykkeAssetsData *asset in data.lykkeData.assets)
    {
        if (asset.hideIfZero && asset.balance.doubleValue <= 0.0) {
            continue;
        }

        for(LWAssetCategoryModel *m in categories)
        {
            if([m.identity isEqualToString:asset.categoryId])
            {
                [m.assets addObject:asset];
                break;
            }
        }
    }
    
    
    
    [self.tableView reloadData];
    
    [screenshot removeFromSuperview];
    screenshot=nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self makeScreenshot];
    });

    
}



- (void)authManager:(LWAuthManager *)manager didGetAssetPair:(LWAssetPairModel *)assetPair {
    [self setLoading:NO];
    

    shouldShowError = NO;
    
    LWExchangeDealFormPresenter *controller = [LWExchangeDealFormPresenter new];
    controller.assetPair = assetPair;
    controller.assetDealType = LWAssetDealTypeSell;
    controller.balanceToSell=balanceToSellCompletely;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:controller animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:controller];

        navigationController.modalPresentationStyle=UIModalPresentationCustom;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [refreshControl endRefreshing];
    [self setLoading:NO];
    [screenshot removeFromSuperview];
    screenshot=nil;
    shouldShowError = NO;
    
    [self showReject:reject response:context.task.response code:context.error.code willNotify:shouldShowError];
    [self.tableView reloadData];
}


#pragma mark - LWBanksTableViewCellDelegate

- (void)addWalletClicked:(LWBanksTableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (path && path.section == kSectionBankCards) {
        LWWalletFormPresenter *form = [LWWalletFormPresenter new];
        form.bankCards = self.data.bankCards;
        [self.navigationController pushViewController:form animated:YES];
    }
    else if (path && path.section == kSectionLykkeWallets) {
        NSInteger const tradingTabIndex = 1;
        self.tabBarController.selectedIndex = tradingTabIndex;
    }
}


#pragma mark - LWLykkeTableViewCellDelegate

- (void)addLykkeItemClicked:(LWLykkeTableViewCell *)cell {
    
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    LWLykkeAssetsData *data = [[categories[path.section] assets] objectAtIndex:path.row-1];

    [LWKYCManager sharedInstance].viewController=self;;
    
    [[LWKYCManager sharedInstance] manageKYCStatusForAsset:data.identity successBlock:^{
    
    
//        NSDictionary *depositTypes=@{@"EUR":@"currency",
//                                     @"USD":@"currency",
//                                     @"CHF":@"currency",
//                                     @"BTC":@"bitcoin",
//                                     @"LKK":@"bitcoin"};
        
        if (data) {
            
            
            UIViewController *presenter;
            

            if([data.identity isEqualToString:@"ETH"])
                presenter=[LWEtheriumDepositPresenter new];
            else if([data.identity isEqualToString:@"LKK"])
            {
                presenter=[LWLykkeBuyTransferContainer new];
                [self.navigationController pushViewController:presenter animated:YES];
                return;
            }
            else if([LWCache isBlockchainDepositEnabledForAssetId:data.identity])
            {
                presenter = [LWBitcoinDepositPresenter new];
            }
            else
            {
                if([LWCache isBankCardDepositEnabledForAssetId:data.identity])
                    presenter=[LWCreditCardDepositPresenter new];
                else if([LWCache isSwiftDepositEnabledForAssetId:data.identity])
                    presenter=[LWCurrencyDepositPresenter new];
            }
            
            if(!presenter)
                return;
            
            ((LWCurrencyDepositPresenter *)presenter).assetName=data.name;
            ((LWCurrencyDepositPresenter *)presenter).assetID=data.identity;
            ((LWCurrencyDepositPresenter *)presenter).issuerId=data.issuerId;
            
            
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
                [self.navigationController pushViewController:presenter animated:YES];
            else
            {
                LWIPadModalNavigationControllerViewController *navigationController =
                [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
                
                navigationController.modalPresentationStyle=UIModalPresentationCustom;
                navigationController.transitioningDelegate=navigationController;
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
            
            
        }
    
    
    }];
    

    return;
    
    
    
    
    
    
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    LWLykkeAssetsData *data = [self assetDataForIndexPath:path];
    

}


#pragma mark - LWLykkeEmptyTableViewCellDelegate

- (void)addLykkeClicked:(LWLykkeEmptyTableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    LWBitcoinDepositPresenter *presenter = [LWBitcoinDepositPresenter new];

    if (path.section == kSectionLykkeWallets) {
        presenter.assetName = @"LYKKE";
    }
    else if (path.section == kSectionBitcoinWallets) {
        presenter.assetName = @"BITCOIN";
    }

    
    //presenter.assetName = data.name;
    presenter.issuerId = cell.issuerId;

    [self.navigationController pushViewController:presenter animated:YES];
    
    
}


#pragma mark - LWBitcoinTableViewCellDelegate

- (void)addBitcoinClicked:(LWBitcoinTableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    LWLykkeAssetsData *data = [categories[path.section] assets][path.row-1];
    if (data) {
        [LWKYCManager sharedInstance].viewController=self;;
        
        [[LWKYCManager sharedInstance] manageKYCStatusForAsset:data.identity successBlock:^{

        LWBitcoinDepositPresenter *presenter = [LWBitcoinDepositPresenter new];
        presenter.assetName = data.name;
        presenter.issuerId = data.issuerId;
        presenter.assetID=@"BTC";
        
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            [self.navigationController pushViewController:presenter animated:YES];
        else
        {
            LWIPadModalNavigationControllerViewController *navigationController =
            [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
            
            navigationController.modalPresentationStyle=UIModalPresentationCustom;
            navigationController.transitioningDelegate=navigationController;
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
        }];

    }
}


#pragma mark - Utils

- (void)expandTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    // only first row toggles exapand/collapse
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    BOOL currentlyExpanded = [expandedSections containsIndex:section];
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

- (NSString *)assetIdentifyForIndexPath:(NSIndexPath *)indexPath {
    // Lykke cells
//    if (indexPath.section == kSectionLykkeWallets) {
        LWLykkeAssetsData *data = [categories[indexPath.section] assets][indexPath.row-1];
        return (data ? data.identity : nil);
//    }
//    // Banks cells
//    else if (indexPath.section == kSectionBankCards) {
//        if (self.data && self.data.bankCards) {
//            // Show Banks Wallets
//            if (self.data.bankCards.count > 0) {
//                LWBankCardsData *card = (LWBankCardsData *)self.data.bankCards[indexPath.row - 1];
//                return card.identity;
//            }
//            else {
//                return nil;
//            }
//        }
//    }

    return nil;
}

//- (LWLykkeAssetsData *)assetDataForIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == kSectionLykkeWallets) {
//        if (self.data) {
//            if (self.lkeWallets.count > 0 && indexPath.row > 0) {
//                LWLykkeAssetsData *asset = (LWLykkeAssetsData *)self.lkeWallets[indexPath.row - 1];
//                return asset;
//            }
//        }
//    }
//    else if (indexPath.section == kSectionBitcoinWallets) {
//        if (self.data) {
//            if (self.btcWallets.count > 0 && indexPath.row > 0) {
//                LWLykkeAssetsData *asset = (LWLykkeAssetsData *)self.btcWallets[indexPath.row - 1];
//                return asset;
//            }
//        }
//    }
//    return nil;
//}

- (void)showDealFormForIndexPath:(NSIndexPath *)indexPath {
    [self setLoading:YES];
    LWLykkeAssetsData *data = [categories[indexPath.section] assets][indexPath.row-1];
    balanceToSellCompletely=data.balance;
    [[LWAuthManager instance] requestAssetPair:data.assetPairId];
}

- (void)setRefreshControl
{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[LWRefreshControlView alloc] init];
//    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(reloadWallets)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];
}

- (void)reloadWallets
{
    shouldShowError = YES;
    [[LWAuthManager instance] requestLykkeWallets];
}

- (void)showDepositPage:(NSIndexPath *)indexPath {
    NSString *assetId = [self assetIdentifyForIndexPath:indexPath];
    LWWalletDepositPresenter *deposit = [LWWalletDepositPresenter new];
    NSString *depositUrl = [LWCache instance].depositUrl;
    NSString *email = [LWKeychainManager instance].login;
    deposit.assetId = assetId;
    deposit.url = [NSString stringWithFormat:@"%@?Email=%@&AssetId=%@", depositUrl, email, assetId];

    [self.navigationController pushViewController:deposit animated:YES];
}

- (void)showTradingWallet:(NSIndexPath *)indexPath {
    LWTradingWalletPresenter *presenter = [LWTradingWalletPresenter new];
    
    LWLykkeAssetsData *data = [categories[indexPath.section] assets][indexPath.row-1];
    if (data) {
        presenter.assetId = [NSString stringWithString:data.identity];
        presenter.assetName = data.name;
        presenter.issuerId = data.issuerId;
        presenter.currencySymbol=data.symbol;
        presenter.balance=data.balance;
        
        [self.navigationController pushViewController:presenter animated:YES];
        

    }
}

- (UIButton *)createUtilsButton {
    UIColor *color = [UIColor colorWithHexString:kSellAssetButtonColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:color];
    [button setTitle:Localize(@"wallets.general.sell") forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:kFontSemibold size:17.0];
    //[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button setImage:[UIImage imageNamed:@"SellWalletIcon"] forState:UIControlStateNormal];
    
    CGFloat const padding = 10.0f;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, padding, 0, 0)];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, padding, 0, 0)];
    [button sizeToFit];

    return button;
}

- (void) makeScreenshot
{
    CGSize sss=self.view.layer.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(self.view.layer.bounds.size, YES, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *data=UIImagePNGRepresentation(img);
    
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/wallets_screenshot.png", NSHomeDirectory()] atomically:YES];
    
    
    
    
    
//    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/Documents/wallets_screenshot.png", NSHomeDirectory()] contents:data attributes:nil];
}

-(UIImage *) screenshotImage
{
    NSData *data=[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/wallets_screenshot.png", NSHomeDirectory()]];
    
    if(!data)
        return nil;
    
    UIImage *image=[UIImage imageWithData:data];
    
    return image;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
