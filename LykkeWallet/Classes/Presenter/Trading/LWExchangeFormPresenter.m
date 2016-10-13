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
#import "LWAssetURLTableViewCell.h"
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
static NSInteger const kDescriptionRows = 8;

static NSString *const DescriptionIdentifiers[kDescriptionRows] = {
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoIconTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetInfoTextTableViewCellIdentifier",
    @"LWAssetURLTableViewCellIdentifier"
};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:@"LWAssetInfoTextTableViewCellIdentifier"
                                name:@"LWAssetInfoTextTableViewCell"];
    
    [self registerCellWithIdentifier:@"LWAssetInfoIconTableViewCellIdentifier"
                                name:@"LWAssetInfoIconTableViewCell"];
    
    [self registerCellWithIdentifier:@"LWAssetURLTableViewCellIdentifier"
                                name:@"LWAssetURLTableViewCell"];

    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = self.assetPair.name;
    if(self.assetPair.inverted)
    {
        NSArray *arr=[self.assetPair.name componentsSeparatedByString:@"/"];
        if(arr.count==2)
        {
            self.title=[NSString stringWithFormat:@"%@/%@", arr[1], arr[0]];
        }
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateRate:self.assetRate];

    if (!assetDetails) {
        [self setLoading:YES];
        
        [[LWAuthManager instance] requestAssetDescription:self.assetPair.quotingAssetId];
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
//    int const kDescriptionRows = 7;
    return kDescriptionRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const DescriptionNames[kDescriptionRows] = {
        @"Full name",
        Localize(@"exchange.assets.form.assetclass"),
        Localize(@"exchange.assets.form.popularity"),
        Localize(@"exchange.assets.form.description"),
        Localize(@"exchange.assets.form.issuername"),
        Localize(@"exchange.assets.form.coinsnumber"),
        Localize(@"exchange.assets.form.capitalization"),
        Localize(@"exchange.assets.form.description_url")
    };
    
    NSString *identifier = DescriptionIdentifiers[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // show popularity row
    if (indexPath.row == 2) {
        LWAssetInfoIconTableViewCell *iconCell = (LWAssetInfoIconTableViewCell *)cell;
        iconCell.titleLabel.text = DescriptionNames[indexPath.row];
        NSString *imageName = [NSString stringWithFormat:@"AssetPopularity%@", assetDetails.popIndex];
        iconCell.popularityImageView.image = [UIImage imageNamed:imageName];
    }
    else if(indexPath.row==7)
    {
        LWAssetURLTableViewCell *urlCell = (LWAssetURLTableViewCell *)cell;
        urlCell.titleLabel.text = DescriptionNames[indexPath.row];
        [urlCell.urlButton setTitle:[self description:assetDetails forRow:indexPath.row] forState:UIControlStateNormal];

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
    if (indexPath.row != 2) {
        return [self calculateRowHeightForText:text];
    }
    
    return kDefaultRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    
    NSString *priceSell=[LWUtils formatFairVolume:rate.bid.doubleValue accuracy:self.assetPair.accuracy.intValue roundToHigher:NO];
    priceSell=[priceSell stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *priceBuy=[LWUtils formatFairVolume:rate.ask.doubleValue accuracy:self.assetPair.accuracy.intValue roundToHigher:YES];
    priceBuy=[priceBuy stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(rate)
    {
        priceSellRateString = [LWUtils priceForAsset:self.assetPair forValue:@(priceSell.doubleValue) withFormat:@"SELL"];
        priceBuyRateString = [LWUtils priceForAsset:self.assetPair forValue:@(priceBuy.doubleValue) withFormat:@"BUY"];
    }
    
//    if (rate) {
//        priceSellRateString = [LWUtils priceForAsset:self.assetPair forValue:rate.bid withFormat:@"SELL"];
//        priceBuyRateString = [LWUtils priceForAsset:self.assetPair forValue:rate.ask withFormat:@"BUY"];
//    }
    
    
//    NSDictionary *attributes = @{NSKernAttributeName:@(1), NSFontAttributeName:self.buyButton.titleLabel.font, NSForegroundColorAttributeName:rate==nil?self.buyButton.currentTitleColor:[UIColor whiteColor]};

//    NSDictionary *attributesBuy = @{NSKernAttributeName:@(1), NSFontAttributeName:self.buyButton.titleLabel.font, NSForegroundColorAttributeName:rate==nil?self.buyButton.currentTitleColor:[UIColor whiteColor]};
//
//    NSDictionary *attributesSell=@{NSKernAttributeName:@(1), NSFontAttributeName:self.sellButton.titleLabel.font, NSForegroundColorAttributeName:rate==nil?self.sellButton.currentTitleColor:[UIColor whiteColor]};
    
        NSDictionary *attributesBuy = @{NSFontAttributeName:self.buyButton.titleLabel.font, NSForegroundColorAttributeName:rate==nil?self.buyButton.currentTitleColor:[UIColor whiteColor]};
    
        NSDictionary *attributesSell=@{NSFontAttributeName:self.sellButton.titleLabel.font, NSForegroundColorAttributeName:rate==nil?self.sellButton.currentTitleColor:[UIColor whiteColor]};

    
    [self.buyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:priceBuyRateString attributes:attributesBuy] forState:UIControlStateNormal];
    [self.sellButton setAttributedTitle:[[NSAttributedString alloc] initWithString:priceSellRateString attributes:attributesSell] forState:UIControlStateNormal];
    
    
//    [self.sellButton setTitle:priceSellRateString forState:UIControlStateNormal];
//    [self.buyButton setTitle:priceBuyRateString forState:UIControlStateNormal];
}

- (NSString *)description:(LWAssetDescriptionModel *)model forRow:(NSInteger)row {
    NSString *text = nil;
    if (model == nil) {
        return text;
    }
    
    switch (row) {
            case 0:
            text=model.fullName;
            break;
        case 1:
            text = model.assetClass;
            break;
        case 2:
            text = (model.popIndex == nil) ? @"" : [model.popIndex stringValue];
            break;
        case 3:
            text = model.details;
            break;
        case 4:
            text = model.issuerName;
            break;
        case 5:
            text = model.numberOfCoins;
            break;
        case 6:
            text = model.marketCapitalization;
            break;
        case 7:
            text = model.assetDescriptionURL;
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
