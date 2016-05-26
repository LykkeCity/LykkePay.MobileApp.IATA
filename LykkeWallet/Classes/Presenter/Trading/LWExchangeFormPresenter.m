//
//  LWExchangeFormPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeFormPresenter.h"
#import "LWExchangeDealFormPresenter.h"
#import "LWAssetPairModel.h"
#import "LWAssetPairRateModel.h"
#import "LWAssetDescriptionModel.h"
#import "LWAssetInfoTextTableViewCell.h"
#import "LWAssetInfoIconTableViewCell.h"
#import "LWAssetModel.h"
#import "LWValidator.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "LWMath.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "NSString+Utils.h"


@interface LWExchangeFormPresenter () {
    LWAssetDescriptionModel *assetDetails;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *sellButton;


#pragma mark - Utils

- (void)updateRate:(LWAssetPairRateModel *)rate;
- (NSString *)description:(LWAssetDescriptionModel *)model forRow:(NSInteger)row;
- (CGFloat)calculateRowHeightForText:(NSString *)text;

@end


@implementation LWExchangeFormPresenter


CGFloat const kDefaultRowHeight = 50.0;
static NSInteger const kDescriptionRows = 6;

static NSString *const DescriptionIdentifiers[kDescriptionRows] = {
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoIconTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier"
};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.assetPair.name;
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:@"LWAssetInfoTextTableViewCellIdentifier"
                                name:@"LWAssetInfoTextTableViewCell"];
    
    [self registerCellWithIdentifier:@"LWAssetInfoIconTableViewCellIdentifier"
                                name:@"LWAssetInfoIconTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateRate:self.assetRate];

    if (!assetDetails) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestAssetDescription:self.assetPair.identity];
    }
    else {
        [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int const kDescriptionRows = 6;
    return kDescriptionRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const DescriptionNames[kDescriptionRows] = {
        Localize(@"exchange.assets.form.assetclass"),
        Localize(@"exchange.assets.form.popularity"),
        Localize(@"exchange.assets.form.description"),
        Localize(@"exchange.assets.form.issuername"),
        Localize(@"exchange.assets.form.coinsnumber"),
        Localize(@"exchange.assets.form.capitalization")
    };
    
    NSString *identifier = DescriptionIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // show popularity row
    if (indexPath.row == 1) {
        LWAssetInfoIconTableViewCell *iconCell = (LWAssetInfoIconTableViewCell *)cell;
        iconCell.titleLabel.text = DescriptionNames[indexPath.row];
        NSString *imageName = [NSString stringWithFormat:@"AssetPopularity%@", assetDetails.popIndex];
        iconCell.popularityImageView.image = [UIImage imageNamed:imageName];
    }
    // show description rows
    else {
        LWAssetInfoTextTableViewCell *textCell = (LWAssetInfoTextTableViewCell *)cell;
        textCell.titleLabel.text = DescriptionNames[indexPath.row];
        textCell.descriptionLabel.text = [self description:assetDetails forRow:indexPath.row];
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (assetDetails == nil) {
        return 0;
    }
    
    NSString *text = [self description:assetDetails forRow:indexPath.row];
    if (text == nil || [text isKindOfClass:[NSNull class]]
        || [text isEqualToString:@""]) {
        return 0;
    }
    
    // calculate height just for text cells
    if (indexPath.row != 1) {
        return [self calculateRowHeightForText:text];
    }
    
    return kDefaultRowHeight;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetAssetDescription:(LWAssetDescriptionModel *)assetDescription {
    assetDetails = assetDescription;
 
    [self.tableView reloadData];
    [self setLoading:NO];
    
    [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
}

- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate {
    [self updateRate:assetPairRate];

    const NSInteger repeatSeconds = [LWCache instance].refreshTimer.integerValue / 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isVisible) {
            [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
        }
    });
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    [self.tableView reloadData];
}


#pragma mark - Actions

- (IBAction)buyClicked:(id)sender {
    if (self.assetPair && self.assetRate) {
        LWExchangeDealFormPresenter *controller = [LWExchangeDealFormPresenter new];
        controller.assetPair = self.assetPair;
        controller.assetRate = self.assetRate;
        controller.assetDealType = LWAssetDealTypeBuy;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)sellClicked:(id)sender {
    if (self.assetPair && self.assetRate) {
        LWExchangeDealFormPresenter *controller = [LWExchangeDealFormPresenter new];
        controller.assetPair = self.assetPair;
        controller.assetRate = self.assetRate;
        controller.assetDealType = LWAssetDealTypeSell;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - Utils

- (void)updateRate:(LWAssetPairRateModel *)rate {
    
    self.assetRate = rate;
    
    [LWValidator setBuyButton:self.buyButton enabled:(rate != nil)];
    [LWValidator setSellButton:self.sellButton enabled:(rate != nil)];
    
    NSString *priceSellRateString = @". . .";
    NSString *priceBuyRateString = @". . .";
    if (rate) {
        priceSellRateString = [LWUtils priceForAsset:self.assetPair forValue:rate.bid withFormat:Localize(@"graph.button.sell")];
        priceBuyRateString = [LWUtils priceForAsset:self.assetPair forValue:rate.ask withFormat:Localize(@"graph.button.buy")];
    }
    
    [self.sellButton setTitle:priceSellRateString forState:UIControlStateNormal];
    [self.buyButton setTitle:priceBuyRateString forState:UIControlStateNormal];
}

- (NSString *)description:(LWAssetDescriptionModel *)model forRow:(NSInteger)row {
    NSString *text = nil;
    if (model == nil) {
        return text;
    }
    
    switch (row) {
        case 0:
            text = model.assetClass;
            break;
        case 1:
            text = (model.popIndex == nil) ? @"" : [model.popIndex stringValue];
            break;
        case 2:
            text = model.details;
            break;
        case 3:
            text = model.issuerName;
            break;
        case 4:
            text = model.numberOfCoins;
            break;
        case 5:
            text = model.marketCapitalization;
            break;
    }
    return text;
}

- (CGFloat)calculateRowHeightForText:(NSString *)text {
    CGFloat const kTopBottomPadding = 8.0;
    CGFloat const kLeftRightPadding = 26.0 * 2.0;
    CGFloat const kTitleWidth = 116.0;
    CGFloat const kDescriptionWidth = self.tableView.frame.size.width - kLeftRightPadding - kTitleWidth;
    
    UIFont *font = [UIFont fontWithName:kFontRegular size:kAssetDetailsFontSize];
    CGSize const size = CGSizeMake(kDescriptionWidth, CGFLOAT_MAX);
    CGRect rect = [text boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    
    CGFloat const cellHeight = MAX(kDefaultRowHeight, rect.size.height + kTopBottomPadding * 2.0);
    return cellHeight;
}

@end
