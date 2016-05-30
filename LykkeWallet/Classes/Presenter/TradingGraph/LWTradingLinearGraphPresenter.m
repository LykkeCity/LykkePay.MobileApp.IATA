//
//  LWTradingLinearGraphPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//



#import "LWExchangeDealFormPresenter.h"
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

#import "LWTradingLinearGraphPresenter.h"
#import "LWPacketGraphPeriods.h"
#import "LWPacketGraphData.h"
#import "LWGraphPeriodModel.h"
#import "LWTradingLinearGraphViewTest.h"


//#import <stockchart/stockchart.h>



#define GRAPH_RED_COLOR [UIColor colorWithRed:187.0/255 green:5.0/255 blue:54.0/255 alpha:1]
#define GRAPH_GREEN_COLOR [UIColor colorWithRed:125.0/255 green:182.0/255 blue:41.0/255 alpha:1]




@interface LWTradingLinearGraphPresenter () {
    LWTradingLinearGraphViewTest *linearGraphView;
    LWPacketGraphPeriods *graphPeriods;
    LWGraphPeriodModel *selectedPeriod;
    UILabel *fixingTimeLabel;
    UILabel *lastPriceLabel;
    UILabel *changeLabel;
    
    UIView *periodsButtonsView;
    NSMutableArray *periodButtons;
    
    UILabel *graphStartDateLabel;
    UILabel *graphEndDateLabel;
    UILabel *fixedPriceOnGraphLabel;
    
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


@implementation LWTradingLinearGraphPresenter

static int const kNumberOfRows = 4;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.assetPair.name;
    
    self.isValid = NO;
    self.pairRateModel = nil;
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    [self setBackButton];
    
    
    //    LWTradingGraphLinearView *vvv=[[LWTradingGraphLinearView alloc] initWithFrame:CGRectZero];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
    [[LWAuthManager instance] requestGraphPeriods];

}

-(void) viewDidAppear:(BOOL)animated
{
    [self setupChart];
   
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    CGFloat const graphHeight = self.view.bounds.size.height - self.tableView.frame.size.height - self.bottomView.frame.size.height;
//    self.graphHeightConstraint.constant = graphHeight;
}


#pragma mark - UITableViewDataSource

-(CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *const titles[kNumberOfRows] = {
        Localize(@"graph.cell.time"),
        Localize(@"graph.cell.price"),
        Localize(@"graph.cell.change")
    };

    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
    if(indexPath.row<3)
    {
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, view.bounds.size.width, view.bounds.size.height)];
        label.text=titles[indexPath.row];
        label.font=[UIFont systemFontOfSize:13];
        label.textColor=[UIColor lightGrayColor];
        [view addSubview:label];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, view.bounds.size.width-60, view.bounds.size.height)];
        label.textAlignment=NSTextAlignmentRight;
        label.font=[UIFont systemFontOfSize:16];
        [view addSubview:label];
        
        if(indexPath.row==0)
            fixingTimeLabel=label;
        else if(indexPath.row==1)
            lastPriceLabel=label;
        else if(indexPath.row==2)
            changeLabel=label;
    }
    if(indexPath.row==3)
    {
        periodsButtonsView=view;
        [self updatePeriodButtons];
    }
    
    [cell addSubview:view];
    
    
    return cell;
}




#pragma mark - Utils


-(void) updatePeriodButtons
{
    periodButtons=[[NSMutableArray alloc] init];
    CGFloat width=periodsButtonsView.bounds.size.width/graphPeriods.periods.count;
    for(LWGraphPeriodModel *m in graphPeriods.periods)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(width*([graphPeriods.periods indexOfObject:m]), 0, width, periodsButtonsView.bounds.size.height);
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        [button setTitle:m.name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:170.0/255 green:38.0/255 blue:252.0/255 alpha:1] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(periodButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [periodButtons addObject:button];
        [periodsButtonsView addSubview:button];
        
        
        if([m.value isEqualToString:selectedPeriod.value])
            button.selected=YES;

    }
    if(selectedPeriod)
    {
        
    }
    
}

-(void) periodButtonPressed:(UIButton *) button
{
    for(UIButton *b in periodButtons)
    {
        b.selected=NO;
    }
    button.selected=YES;
    selectedPeriod=graphPeriods.periods[[periodButtons indexOfObject:button]];
    [[LWAuthManager instance] requestGraphDataForPeriod:selectedPeriod assetPairId:self.assetPair.identity];

}


- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    
    NSString *values[kNumberOfRows] = {
        @" - ",
        @" - ",
        @" - "
    };
    
    NSArray *arr=@[fixingTimeLabel, lastPriceLabel, changeLabel];
    
    if (self.isValid) {
        values[0] = @"4:30 PM EST";
        values[1] = [LWMath makeStringByNumber:self.pairRateModel.ask
                                 withPrecision:self.assetPair.accuracy.integerValue];
        values[2] = @"-21,06 -1,08%";
    }
    if(row<3)
    {
        UILabel *label=arr[row];
        label.text=values[row];
    }
//    cell.detailLabel.text = values[row];
}

- (void)requestPrices {
    const NSInteger repeatSeconds = [LWCache instance].refreshTimer.integerValue / 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isVisible) {
            [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
//            if(selectedPeriod)
//                [[LWAuthManager instance] requestGraphDataForPeriod:selectedPeriod];
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
    
//    [self.tableView reloadData];
}

- (void)invalidPrices {
    [LWValidator setBuyButton:self.buyButton enabled:self.isValid];
    [LWValidator setSellButton:self.sellButton enabled:self.isValid];
    
//    [self.tableView reloadData];
}

- (void)setupChart {
//    SCHStockChartViewPro *chart = [[SCHStockChartViewPro alloc]
//                                   initWithFrame:self.graphView.bounds];
    
    linearGraphView=[[LWTradingLinearGraphViewTest alloc] initWithFrame:self.graphView.bounds];
    
    graphStartDateLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, linearGraphView.bounds.size.width/2, 30)];
    graphStartDateLabel.font=[UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    graphStartDateLabel.textColor=[UIColor lightGrayColor];
    [linearGraphView addSubview:graphStartDateLabel];
    
    graphEndDateLabel=[[UILabel alloc] initWithFrame:CGRectMake(linearGraphView.bounds.size.width/2, 0, linearGraphView.bounds.size.width/2-10, 30)];
    graphEndDateLabel.font=graphStartDateLabel.font;
    graphEndDateLabel.textColor=graphStartDateLabel.textColor;
    graphEndDateLabel.textAlignment=NSTextAlignmentRight;
    [linearGraphView addSubview:graphEndDateLabel];
    
    fixedPriceOnGraphLabel=[[UILabel alloc] initWithFrame:CGRectMake(linearGraphView.bounds.size.width/2, 30, linearGraphView.bounds.size.width/2-10, 25)];
    fixedPriceOnGraphLabel.font=[UIFont systemFontOfSize:20];
    fixedPriceOnGraphLabel.textColor=GRAPH_GREEN_COLOR;
    
    fixedPriceOnGraphLabel.textAlignment=NSTextAlignmentRight;
    [linearGraphView addSubview:fixedPriceOnGraphLabel];
    
    [self.graphView addSubview:linearGraphView];

}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate {
    self.pairRateModel = assetPairRate;
    self.isValid = YES;
    
    [self updatePrices];
    [self requestPrices];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    self.isValid = NO;
    
    [self invalidPrices];
    [self requestPrices];
}

-(void) authManager:(LWAuthManager *)manager didGetGraphPeriods:(LWPacketGraphPeriods *)_graphPeriods
{
    graphPeriods=_graphPeriods;
    if(!selectedPeriod)
        selectedPeriod=graphPeriods.lastSelectedPeriod;
    [[LWAuthManager instance] requestGraphDataForPeriod:selectedPeriod assetPairId:self.assetPair.identity];
    [self updatePeriodButtons];
}

-(void) authManager:(LWAuthManager *) manager didGetGraphData:(LWPacketGraphData *)graphData
{
    linearGraphView.changes=graphData.graphValues;
    [linearGraphView setNeedsDisplay];
    
    float absChange=[graphData.graphValues.lastObject floatValue]-[graphData.graphValues[0] floatValue];
    NSString *changeString=@"";
    if(absChange>0)
    {
        changeString=[changeString stringByAppendingString:@"+"];
    }
    changeString=[changeString stringByAppendingFormat:@"%.2f (", absChange];
    if(absChange>0)
    {
        changeString=[changeString stringByAppendingString:@"+"];
    }
    changeString=[changeString stringByAppendingFormat:@"%.2f%%)", graphData.percentChange.floatValue];

    
    
    changeLabel.text=changeString;
    if(graphData.percentChange.floatValue>0)
    {
        changeLabel.textColor=GRAPH_GREEN_COLOR;
        fixedPriceOnGraphLabel.textColor=GRAPH_GREEN_COLOR;
    }
    else
    {
        changeLabel.textColor=GRAPH_RED_COLOR;
        fixedPriceOnGraphLabel.textColor=GRAPH_RED_COLOR;
    }
    lastPriceLabel.text=[NSString stringWithFormat:@"%.6f", [graphData.graphValues.lastObject floatValue]];
    fixedPriceOnGraphLabel.text=lastPriceLabel.text;
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    
    fixingTimeLabel.text=[formatter stringFromDate:graphData.fixingTime];
    
    [formatter setDateFormat:@"MMM dd, HH:mm a"];
    graphStartDateLabel.text=[[formatter stringFromDate:graphData.startDate] uppercaseString];
    graphEndDateLabel.text=[[formatter stringFromDate:graphData.endDate] uppercaseString];

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
