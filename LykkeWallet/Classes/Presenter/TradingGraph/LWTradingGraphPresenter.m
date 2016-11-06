//
//  LWTradingGraphPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 18.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradingGraphPresenter.h"
#import "LWExchangeDealFormPresenter.h"
#import "LWGraphPeriodRatesModel.h"
#import "LWAssetPairRateModel.h"
#import "LWAssetPairModel.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWValidator.h"
#import "LWConstants.h"
#import "LWAssetModel.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "LWMath.h"
#import "TKButton.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"

#import <stockchart/stockchart.h>




@interface LWGenPointStockAdapter : NSObject <SCHSeriesPointAdapter>
@property NSArray       *generatedPoints;
@property SCHStockPoint *point;

- (instancetype)initWithGeneratedPoints:(NSArray *)points;
- (NSInteger)getPointCount;
- (SCHAbstractPoint *)getPointAt:(NSInteger)i;

@end

@implementation LWGenPointStockAdapter

- (instancetype)initWithGeneratedPoints:(NSArray *)points
{
    self = [super init];
    
    if(self)
    {
        _generatedPoints = points;
        _point = [[SCHStockPoint alloc] init];
    }
    
    return self;
}

- (NSInteger)getPointCount
{
    return [self.generatedPoints count];
}

- (SCHAbstractPoint *)getPointAt:(NSInteger)i
{
    SCHStockDataPoint *p = self.generatedPoints[i];
    [self.point setValuesWithOpen:p.o High:p.h Low:p.l Close:p.c];
    return self.point;
}

@end




@interface LWTradingGraphPresenter () {
    LWGraphPeriodRatesModel *periodRateModel;
}

@property (assign, nonatomic) BOOL isValid;
@property (strong, nonatomic) LWAssetPairRateModel *pairRateModel;

@property (weak, nonatomic) IBOutlet TKButton *sellButton;
@property (weak, nonatomic) IBOutlet TKButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView   *graphView;
@property (weak, nonatomic) IBOutlet UIView   *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphHeightConstraint;

#pragma mark - Utils
- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row;
- (void)requestPrices;
- (void)updatePrices;
- (void)invalidPrices;
- (void)setupChart;

@end


@implementation LWTradingGraphPresenter

static int const kNumberOfRows = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.assetPair.name;

    self.isValid = NO;
    self.pairRateModel = nil;
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    [self setupChart];
    [self setBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat const graphHeight = self.view.bounds.size.height - self.tableView.frame.size.height - self.bottomView.frame.size.height;
    self.graphHeightConstraint.constant = graphHeight;
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


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    NSString *const titles[kNumberOfRows] = {
        Localize(@"graph.cell.time"),
        Localize(@"graph.cell.price"),
        Localize(@"graph.cell.change")
    };
    cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    
    NSString *values[kNumberOfRows] = {
        @" - ",
        @" - ",
        @" - "
    };
    
    if (self.isValid) {
#warning TODO: update from periodRateModel model
        values[0] = @"4:30 PM EST";
        values[1] = [LWMath makeStringByNumber:self.pairRateModel.ask
                                 withPrecision:self.assetPair.accuracy.integerValue];
        values[2] = @"-21,06 -1,08%";
    }

    cell.detailLabel.text = values[row];
}

- (void)requestPrices {
    const NSInteger repeatSeconds = [LWCache instance].refreshTimer.integerValue / 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isVisible) {
            NSNumber *points = [NSNumber numberWithInt:10];
            NSString *assetId = self.assetPair.identity;
#warning TODO: change period to selected
            [[LWAuthManager instance] requestGraphPeriodRates:@"M1"
                                                      assetId:assetId
                                                       points:points];
        }
    });
}

- (void)updatePrices {
    [LWValidator setBuyButton:self.buyButton enabled:self.isValid];
    [LWValidator setSellButton:self.sellButton enabled:self.isValid];
    
    NSString *priceSellRateString = @". . .";
    NSString *priceBuyRateString = @". . .";
    if (self.pairRateModel) {
        priceSellRateString = [LWUtils priceForAsset:self.assetPair forValue:self.pairRateModel.bid withFormat:Localize(@"graph.button.sell")];
        
        priceBuyRateString = [LWUtils priceForAsset:self.assetPair forValue:self.pairRateModel.ask withFormat:Localize(@"graph.button.buy")];
    }
    
    [self.sellButton setTitle:priceSellRateString forState:UIControlStateNormal];
    [self.buyButton setTitle:priceBuyRateString forState:UIControlStateNormal];

    [self.tableView reloadData];
}

- (void)invalidPrices {
    [LWValidator setBuyButton:self.buyButton enabled:self.isValid];
    [LWValidator setSellButton:self.sellButton enabled:self.isValid];
    
    [self.tableView reloadData];
}

- (void)setupChart {
    SCHStockChartViewPro *chart = [[SCHStockChartViewPro alloc]
                                   initWithFrame:self.graphView.bounds];
    [self.graphView addSubview:chart];
    
    // Customize area
    SCHArea *chartArea = [chart addArea];
    [chartArea setHeightInPercents:90];
    [chartArea setAxesVisibleLeft:NO Top:NO Right:YES Bottom:YES];
    [chartArea.areaAppearance setOutlineWidth:0.0];
    chartArea.plot.plotAppearance.outlineColor = [UIColor colorWithHexString:kMainGrayElementsColor];
    
    SCHSeries *price = [chart addSeries:chartArea];
    SCHCandlestickStockRenderer *renderer = [[SCHCandlestickStockRenderer alloc] init];
    UIColor *riseColor = [UIColor colorWithHexString:kAssetChangePlusColor];
    UIColor *fallColor = [UIColor colorWithHexString:kAssetChangeMinusColor];
    renderer.riseAppearance.primaryFillColor = riseColor;
    renderer.riseAppearance.outlineColor = riseColor;
    renderer.riseAppearance.gradient = SCHAppearanceGradientNone;
    renderer.fallAppearance.primaryFillColor = fallColor;
    renderer.fallAppearance.outlineColor = fallColor;
    renderer.fallAppearance.gradient = SCHAppearanceGradientNone;
    
    [price setRenderer:renderer];
    price.name = @"price";
    price.yAxisSide = SCHAxisSideRight;
    SCHStockDataGenerator *gen = [[SCHStockDataGenerator alloc] init];
    NSArray *points = [gen getNext:20];
    price.pointAdapter = [[LWGenPointStockAdapter alloc] initWithGeneratedPoints:points];
    
    [chart setAutoresizingMask:(UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight)];
    [self.graphView setAutoresizesSubviews:YES];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate {
    self.pairRateModel = assetPairRate;
    self.isValid = YES;
    
    [self updatePrices];
    [self requestPrices];
}

- (void)authManager:(LWAuthManager *)manager didGetGraphPeriodRates:(LWGraphPeriodRatesModel *)periodRates {
    periodRateModel = [periodRates copy];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    self.isValid = NO;
    
    [self invalidPrices];
    [self requestPrices];
}


#pragma mark - Actions

- (IBAction)sellClicked:(id)sender {
    LWExchangeDealFormPresenter *controller = [LWExchangeDealFormPresenter new];
    controller.assetPair = self.assetPair;
    controller.assetDealType = LWAssetDealTypeSell;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)buyClicked:(id)sender {
    LWExchangeDealFormPresenter *controller = [LWExchangeDealFormPresenter new];
    controller.assetPair = self.assetPair;
    controller.assetDealType = LWAssetDealTypeBuy;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
