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


#ifdef PROJECT_IATA
static NSInteger const kSectionIATAWallets    = 0;
static NSInteger const kSectionSWIFTItems     = 1;
#else
static NSInteger const kSectionBankCards      = 0;
static NSInteger const kSectionLykkeWallets   = 1;
static NSInteger const kSectionBitcoinWallets = 2;
#endif

@interface LWWalletsPresenter ()<UITableViewDelegate, UITableViewDataSource, LWWalletTableViewCellDelegate, LWLykkeEmptyTableViewCellDelegate, LWLykkeTableViewCellDelegate, LWBitcoinTableViewCellDelegate, SWTableViewCellDelegate> {
    
    NSMutableIndexSet *expandedSections;
    UIRefreshControl  *refreshControl;
    
    BOOL               shouldShowError;
    
    UIImageView *screenshot;
    NSNumber *balanceToSellCompletely;
}


#pragma mark - Properties

@property (readonly, nonatomic) LWLykkeWalletsData *data;
#ifdef PROJECT_IATA
@property (readonly, nonatomic) NSMutableArray     *iataWallets;
#else
@property (readonly, nonatomic) NSMutableArray     *btcWallets;
@property (readonly, nonatomic) NSMutableArray     *lkeWallets;
#endif


#pragma mark - Utils

- (void)expandTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (NSString *)assetIdentifyForIndexPath:(NSIndexPath *)indexPath;
- (LWLykkeAssetsData *)assetDataForIndexPath:(NSIndexPath *)indexPath;
- (void)showDealFormForIndexPath:(NSIndexPath *)indexPath;
- (void)setRefreshControl;
- (void)reloadWallets;
- (void)showDepositPage:(NSIndexPath *)indexPath;
- (void)showTradingWallet:(NSIndexPath *)indexPath;
- (UIButton *)createUtilsButton;

@end


@implementation LWWalletsPresenter

#ifdef PROJECT_IATA

static NSInteger const kNumberOfSections = 2;
static NSString *cellIdentifier = @"LWWalletTableViewCellIdentifier";

static NSString *const WalletIdentifiers[kNumberOfSections] = {
    @"LWLykkeTableViewCellIdentifier",
    @"LWBanksTableViewCellIdentifier"
};
static NSString *const WalletNames[kNumberOfSections] = {
    @"IATA WALLET",
    @"SWIFT"
};
static NSString *const WalletIcons[kNumberOfSections] = {
    @"IATAWallet",
    @"SwiftWallet"
};

#else

static NSInteger const kNumberOfSections = 3;//6;

static NSString *const WalletIdentifiers[kNumberOfSections] = {
    kBanksTableViewCellIdentifier,
    kLykkeTableViewCellIdentifier,
    kBitcoinTableViewCellIdentifier

    /*, kWalletEmptyTableViewCell,
        kWalletEmptyTableViewCell,
        kWalletEmptyTableViewCell,
        kWalletEmptyTableViewCell */
};

static NSString *const WalletNames[kNumberOfSections] = {
    @"VISA/MASTERCARD",
    @"LYKKE",
    @"BITCOIN"
    /*, @"PAYPAL", @"WEBMONEY", @"MONETAS", @"QIWI"*/
};

static NSString *const WalletIcons[kNumberOfSections] = {
    @"WalletBanks",
    @"WalletLykke",
    @"WalletBitcoin"

    /*, @"WalletPaypal", @"WalletWebmoney", @"WalletMonetas", @"WalletQiwi"*/
};

#endif



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
    
#ifdef PROJECT_IATA
    _iataWallets = [NSMutableArray array];
#else
    _lkeWallets = [NSMutableArray array];
    _btcWallets = [NSMutableArray array];
#endif
    expandedSections = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < kNumberOfSections; ++i) {
        [expandedSections addIndex:i];
    }
    
    [self registerCellWithIdentifier:kWalletTableViewCellIdentifier
                             name:kWalletTableViewCell];
    
    [self registerCellWithIdentifier:kBanksTableViewCellIdentifier
                             name:kBanksTableViewCell];
    
    [self registerCellWithIdentifier:kLykkeTableViewCellIdentifier
                             name:kLykkeTableViewCell];
    
    [self registerCellWithIdentifier:kWalletEmptyTableViewCellIdentifier
                             name:kWalletEmptyTableViewCell];
    
    [self registerCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier
                             name:kLykkeEmptyTableViewCell];

#ifdef PROJECT_IATA
#else
    [self registerCellWithIdentifier:kBitcoinTableViewCellIdentifier
                             name:kBitcoinTableViewCell];
#endif
    
    [self registerCellWithIdentifier:kLoadingTableViewCellIdentifier
                             name:kLoadingTableViewCell];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    shouldShowError = NO;
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    [self setRefreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWallets) name:@"ApplicationDidBecomeActiveNotification" object:nil];
    
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
    if(![LWCache instance].allAssets)
        [self performSelector:@selector(requestWallets) withObject:nil afterDelay:1];
    else
    {
        [[LWAuthManager instance] requestLykkeWallets];
        
    }
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([expandedSections containsIndex:section])
    {
        if (self.data) {
            int const rowCell = 1;
#ifdef PROJECT_IATA
            if (section == kSectionIATAWallets) {
                return MAX(1, self.iataWallets.count) + rowCell;
            }
            else if (section == kSectionSWIFTItems) {
                return 2;//MAX(1, self.data.bankCards.count) + rowCell;
            }
            else {
                return 2; // general + empty
            }
#else
            if (section == kSectionLykkeWallets) {
                return MAX(1, self.lkeWallets.count) + rowCell;
            }
            else if (section == kSectionBitcoinWallets) {
                return MAX(1, self.btcWallets.count) + rowCell;
            }
            else if (section == kSectionBankCards && self.data.bankCards) {
                return MAX(1, self.data.bankCards.count) + rowCell;
            }
            else {
                return 2; // general + empty
            }
#endif
        }
        else {
#ifdef PROJECT_IATA
            // loading indicator cell
            if (section == kSectionIATAWallets
                || section == kSectionSWIFTItems) {
                return 2;
            }
#else
            // loading indicator cell
            if (section == kSectionLykkeWallets
                || section == kSectionBankCards
                || section == kSectionBitcoinWallets) {
                return 2;
            }
#endif
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

        int sss=indexPath.section;
        
//        wallet.walletLabel.text = WalletNames[indexPath.section];
        wallet.walletLabel.attributedText = [[NSAttributedString alloc] initWithString:WalletNames[indexPath.section] attributes:attributes];
       
        wallet.walletImageView.image = [UIImage imageNamed:WalletIcons[indexPath.section]];
        
#ifdef PROJECT_IATA
        // Hide plus button for bitcoin
        wallet.addWalletButton.hidden = (indexPath.section == kSectionIATAWallets
                                         || indexPath.section == kSectionSWIFTItems);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.separatorInset = UIEdgeInsetsMake(0, 42, 0, 42);
        }
#else
        // Hide plus button for bitcoin
        wallet.addWalletButton.hidden =
        (indexPath.section == kSectionBitcoinWallets
         || indexPath.section == kSectionLykkeWallets);
#endif
    }
    // Show wallets for category
    else {
        NSString *identifier = WalletIdentifiers[indexPath.section];
        // Lykke cells
#ifdef PROJECT_IATA
        if (indexPath.section == kSectionIATAWallets) {
            if (self.data) {
                // Show Lykke Wallets
                if (self.iataWallets.count > 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWLykkeTableViewCell *lykke = (LWLykkeTableViewCell *)cell;
                    lykke.cellDelegate = self;
                    
                    LWLykkeAssetsData *asset = [self assetDataForIndexPath:indexPath];
                    NSInteger const accuracy = [LWAssetsDictionaryItem assetAccuracyById:asset.identity];
                    NSString *balance = [LWMath historyPriceString:asset.balance
                                                         precision:accuracy
                                                        withPrefix:@""];
                    lykke.walletNameLabel.text = asset.name;
                    lykke.walletBalanceLabel.text = [NSString stringWithFormat:@"%@ %@",
                                                     asset.symbol, balance];
                    lykke.addWalletButton.hidden = ![[LWCache instance] isMultisigAvailable];
                    
                    // validate for base asset and balance
                    if (![asset.identity isEqualToString:[LWCache instance].baseAssetId] && asset.balance.doubleValue > 0.0) {
                        CGFloat const buttonWidth = 120.0;
                        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                        [rightUtilityButtons sw_addUtilityButton:[self createUtilsButton]];
                        [lykke setRightUtilityButtons:rightUtilityButtons WithButtonWidth:buttonWidth];
                        
                        lykke.delegate = self;
                    }
                    
#ifdef PROJECT_IATA
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 42);
                    }
#endif
                }
                // Show Empty
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier];
                    LWLykkeEmptyTableViewCell *emptyCell = (LWLykkeEmptyTableViewCell *)cell;
                    emptyCell.titleLabel.text = Localize(@"wallets.lykke.empty");
                    emptyCell.delegate = self;
                    emptyCell.addWalletButton.hidden = ![[LWCache instance] isMultisigAvailable];
                    emptyCell.issuerId = @"LKE";
                }
            }
            else {
                // loading indicator cell
                cell = [tableView dequeueReusableCellWithIdentifier:kLoadingTableViewCellIdentifier];
            }
        }
        else if (indexPath.section == kSectionSWIFTItems) {
            cell = [tableView dequeueReusableCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier];
            LWLykkeEmptyTableViewCell *emptyCell = (LWLykkeEmptyTableViewCell *)cell;
            emptyCell.titleLabel.text = Localize(@"wallets.swift.empty");
            emptyCell.addWalletButton.hidden = YES;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.separatorInset = UIEdgeInsetsMake(0, 68, 0, 42);
            }
        }
#else
        if (indexPath.section == kSectionLykkeWallets) {
            if (self.data) {
                // Show Lykke Wallets
                if (self.lkeWallets.count > 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWLykkeTableViewCell *lykke = (LWLykkeTableViewCell *)cell;
                    lykke.cellDelegate = self;
                    
                    LWLykkeAssetsData *asset = [self assetDataForIndexPath:indexPath];
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
                // Show Empty
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier];
                    LWLykkeEmptyTableViewCell *emptyCell = (LWLykkeEmptyTableViewCell *)cell;
                    emptyCell.titleLabel.text = Localize(@"wallets.lykke.empty");
                    emptyCell.delegate = self;
                    emptyCell.addWalletButton.hidden = ![[LWCache instance] isMultisigAvailable];
                    emptyCell.issuerId = @"LKE";
                }
            }
            else {
                // loading indicator cell
                             cell=[[LWWalletsLoadingTableViewCell alloc] init];
          //      cell = [tableView dequeueReusableCellWithIdentifier:kLoadingTableViewCellIdentifier];
            }
        }
        // Bitcoin cells
        else if (indexPath.section == kSectionBitcoinWallets) {
            if (self.data) {
                // Show Bitcoin Wallets
                if (self.btcWallets.count > 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWBitcoinTableViewCell *bitcoin = (LWBitcoinTableViewCell *)cell;
                    bitcoin.cellDelegate = self;
                    
                    LWLykkeAssetsData *asset = [self assetDataForIndexPath:indexPath];
                    NSInteger const accuracy = [LWAssetsDictionaryItem assetAccuracyById:asset.identity];
                    NSString *balance = [LWMath historyPriceString:asset.balance
                                                         precision:accuracy
                                                        withPrefix:@""];
                    bitcoin.bitcoinLabel.text = asset.name;
                    bitcoin.bitcoinBalance.text = [NSString stringWithFormat:@"%@ %@",
                                                   asset.symbol, balance];
                    bitcoin.bitcoinAddButton.hidden = ![[LWCache instance] isMultisigAvailable];
                    
                    bitcoin.bitcoinAddButton.hidden=[LWCache shouldHideDepositForAssetId:asset.identity];

                    
                    // validate for base asset and balance
                    if ((![asset.identity isEqualToString:[LWCache instance].baseAssetId] && asset.balance.doubleValue > 0.0)) {
                        CGFloat const buttonWidth = 120.0;
                        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
                        [rightUtilityButtons sw_addUtilityButton:[self createUtilsButton]];
                        [bitcoin setRightUtilityButtons:rightUtilityButtons WithButtonWidth:buttonWidth];
                        
                        bitcoin.delegate = self;
                    }
                    else
                    {
                        bitcoin.rightUtilityButtons=nil;
                    }
                }
                // Show Empty
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:kLykkeEmptyTableViewCellIdentifier];
                    LWLykkeEmptyTableViewCell *emptyCell = (LWLykkeEmptyTableViewCell *)cell;
                    emptyCell.titleLabel.text = Localize(@"wallets.lykke.empty");
                    emptyCell.delegate = self;
                    emptyCell.addWalletButton.hidden = ![[LWCache instance] isMultisigAvailable];
                    emptyCell.issuerId = @"BTC";
                }
            }
            else {
                // loading indicator cell
                cell=[[LWWalletsLoadingTableViewCell alloc] init];
//                cell = [tableView dequeueReusableCellWithIdentifier:kLoadingTableViewCellIdentifier];
            }
        }
        // Banks cells
        else if (indexPath.section == kSectionBankCards) {
            if (self.data && self.data.bankCards) {
                // Show Banks Wallets
                if (self.data.bankCards.count > 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                    LWBanksTableViewCell *lykke = (LWBanksTableViewCell *)cell;
                    LWBankCardsData *card = (LWBankCardsData *)self.data.bankCards[indexPath.row - 1];
                    lykke.cardNameLabel.text = @"Visa";
                    lykke.cardDigitsLabel.text = [NSString stringWithFormat:@".... %@", card.lastDigits];
                }
                // Show Empty
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:kWalletEmptyTableViewCellIdentifier];
                    LWWalletEmptyTableViewCell *emptyCell = (LWWalletEmptyTableViewCell *)cell;
                    emptyCell.titleLabel.text = Localize(@"wallets.cards.empty");
                }
            }
            else {
                // loading indicator cell
                cell = [tableView dequeueReusableCellWithIdentifier:kLoadingTableViewCellIdentifier];
            }
        }
#endif
        // Show empty cells
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:kWalletEmptyTableViewCellIdentifier];
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // show history for selected asset
    if (indexPath.row != 0) {
#ifdef PROJECT_IATA
        if (indexPath.section == kSectionSWIFTItems) {
            [self showTradingWallet:indexPath];
        }
        else if (indexPath.section == kSectionIATAWallets) {
            if (self.data && self.iataWallets.count > 0) {
                [self showTradingWallet:indexPath];
            }
        }
#else
        if (indexPath.section == kSectionBankCards) {
            if (self.data && self.data.bankCards) {
                if (self.data.bankCards.count > 0) {
                    LWBitcoinDepositPresenter *presenter = [LWBitcoinDepositPresenter new];
                    LWLykkeAssetsData *data = [self assetDataForIndexPath:indexPath];
                    if (data) {
                        
                        presenter.assetName = data.name;
                        presenter.issuerId = data.issuerId;
                        [self.navigationController pushViewController:presenter animated:YES];
                    }
                }
            }
        }
        else if (indexPath.section == kSectionLykkeWallets) {
            if (self.data && self.lkeWallets.count > 0) {
                [self showTradingWallet:indexPath];
            }
        }
        else if (indexPath.section == kSectionBitcoinWallets) {
            if (self.data && self.btcWallets.count > 0) {
                [self showTradingWallet:indexPath];
            }
        }
#endif
    }
    // expand / close wallet
    else {
        [self expandTable:tableView indexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat const kStandardHeight = 50.0;
#ifdef PROJECT_IATA
    return kStandardHeight;
#else
    if (indexPath.section == kSectionBankCards) {
        return 0.0;
    }
    return kStandardHeight;
#endif
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
#ifdef PROJECT_IATA
    _iataWallets = [NSMutableArray array];
#else
    _lkeWallets = [NSMutableArray array];
    _btcWallets = [NSMutableArray array];
#endif
    for (LWLykkeAssetsData *asset in data.lykkeData.assets) {
        // Hide if zero
        if (asset.hideIfZero && asset.balance.doubleValue <= 0.0) {
            continue;
        }
        
#ifdef PROJECT_IATA
        [_iataWallets addObject:asset];
#else
        
        if([asset.issuerId isKindOfClass:[NSString class]]==NO)
            continue;
        if ([asset.issuerId isEqualToString:@"BTC"]) {
            [_btcWallets addObject:asset];
        }
        else if ([asset.issuerId isEqualToString:@"LKE"]) {
            [_lkeWallets addObject:asset];
        }
#endif
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
#ifdef PROJECT_IATA
    if (path && path.section == kSectionSWIFTItems) {
    }
    else if (path && path.section == kSectionIATAWallets) {
        NSInteger const tradingTabIndex = 1;
        self.tabBarController.selectedIndex = tradingTabIndex;
    }
#else
    if (path && path.section == kSectionBankCards) {
        LWWalletFormPresenter *form = [LWWalletFormPresenter new];
        form.bankCards = self.data.bankCards;
        [self.navigationController pushViewController:form animated:YES];
    }
    else if (path && path.section == kSectionLykkeWallets) {
        NSInteger const tradingTabIndex = 1;
        self.tabBarController.selectedIndex = tradingTabIndex;
    }
#endif
}


#pragma mark - LWLykkeTableViewCellDelegate

- (void)addLykkeItemClicked:(LWLykkeTableViewCell *)cell {
    
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    LWLykkeAssetsData *data = [self assetDataForIndexPath:path];

    [LWKYCManager sharedInstance].viewController=self;;
    
    [[LWKYCManager sharedInstance] manageKYCStatusForAsset:data.identity successBlock:^{
    
    
        NSDictionary *depositTypes=@{@"EUR":@"currency",
                                     @"USD":@"currency",
                                     @"CHF":@"currency",
                                     @"BTC":@"bitcoin",
                                     @"LKK":@"bitcoin"};
        
        if (data) {
//            if([data.identity isEqualToString:@"LKK"])
//            {
//                if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
//                {
//                    LWMyLykkeBuyPresenter *presenter=[[LWMyLykkeBuyPresenter alloc] init];
//                    [self.navigationController pushViewController:presenter animated:YES];
//                }
//                else
//                {
//                    LWMyLykkeIpadController *presenter=[LWMyLykkeIpadController new];
//                    [self.navigationController pushViewController:presenter animated:YES];
//                    
//                }
//                return;
//            }
            
            
            UIViewController *presenter;

            if([data.identity isEqualToString:@"ETH"])
                presenter=[LWEtheriumDepositPresenter new];
            else if([data.identity isEqualToString:@"LKK"])
            {
                presenter=[LWLykkeBuyTransferContainer new];
                [self.navigationController pushViewController:presenter animated:YES];
                return;
            }
            else if([depositTypes[data.identity] isEqualToString:@"bitcoin"])
            {
                presenter = [LWBitcoinDepositPresenter new];
            }
            else
            {
                if([LWCache isBankCardDepositEnabledForAssetId:data.identity])
                    presenter=[LWCreditCardDepositPresenter new];
                else
                    presenter=[LWCurrencyDepositPresenter new];
            }
            
            
            
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

#ifdef PROJECT_IATA
    if (path.section == kSectionIATAWallets) {
        presenter.assetName = @"LYKKE";
    }
#else
    if (path.section == kSectionLykkeWallets) {
        presenter.assetName = @"LYKKE";
    }
    else if (path.section == kSectionBitcoinWallets) {
        presenter.assetName = @"BITCOIN";
    }
#endif
    
    //presenter.assetName = data.name;
    presenter.issuerId = cell.issuerId;

    [self.navigationController pushViewController:presenter animated:YES];
    
    
}


#pragma mark - LWBitcoinTableViewCellDelegate

- (void)addBitcoinClicked:(LWBitcoinTableViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    LWLykkeAssetsData *data = [self assetDataForIndexPath:path];
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
#ifdef PROJECT_IATA
    // IATA cells
    if (indexPath.section == kSectionIATAWallets) {
        LWLykkeAssetsData *data = [self assetDataForIndexPath:indexPath];
        return (data ? data.identity : nil);
    }
    else if (indexPath.section == kSectionSWIFTItems) {
    }
#else
    // Lykke cells
    if (indexPath.section == kSectionLykkeWallets) {
        LWLykkeAssetsData *data = [self assetDataForIndexPath:indexPath];
        return (data ? data.identity : nil);
    }
    // Banks cells
    else if (indexPath.section == kSectionBankCards) {
        if (self.data && self.data.bankCards) {
            // Show Banks Wallets
            if (self.data.bankCards.count > 0) {
                LWBankCardsData *card = (LWBankCardsData *)self.data.bankCards[indexPath.row - 1];
                return card.identity;
            }
            else {
                return nil;
            }
        }
    }
#endif
    return nil;
}

- (LWLykkeAssetsData *)assetDataForIndexPath:(NSIndexPath *)indexPath {
#ifdef PROJECT_IATA
    if (indexPath.section == kSectionIATAWallets) {
        if (self.data) {
            if (self.iataWallets.count > 0 && indexPath.row > 0) {
                LWLykkeAssetsData *asset = (LWLykkeAssetsData *)self.iataWallets[indexPath.row - 1];
                return asset;
            }
        }
    }
#else
    if (indexPath.section == kSectionLykkeWallets) {
        if (self.data) {
            if (self.lkeWallets.count > 0 && indexPath.row > 0) {
                LWLykkeAssetsData *asset = (LWLykkeAssetsData *)self.lkeWallets[indexPath.row - 1];
                return asset;
            }
        }
    }
    else if (indexPath.section == kSectionBitcoinWallets) {
        if (self.data) {
            if (self.btcWallets.count > 0 && indexPath.row > 0) {
                LWLykkeAssetsData *asset = (LWLykkeAssetsData *)self.btcWallets[indexPath.row - 1];
                return asset;
            }
        }
    }
#endif
    return nil;
}

- (void)showDealFormForIndexPath:(NSIndexPath *)indexPath {
    [self setLoading:YES];
    LWLykkeAssetsData *data = [self assetDataForIndexPath:indexPath];
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
    
    LWLykkeAssetsData *data = [self assetDataForIndexPath:indexPath];
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
