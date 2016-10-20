//
//  LWBuyLykkeInContainerPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBuyLykkeInContainerPresenter.h"
#import "LWLykkeAssetsData.h"
#import "LWLykkeWalletsData.h"
#import "LWBuyLykkeInContainerTableViewCell.h"
#import "LWExchangeDealFormPresenter.h"
#import "LWAssetPairModel.h"
#import "LWIPadModalNavigationControllerViewController.h"



@interface LWBuyLykkeInContainerPresenter () <UITableViewDataSource, UITableViewDelegate>
{
    
    NSMutableArray *wallets;
}

@end

@implementation LWBuyLykkeInContainerPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = ({UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1 / UIScreen.mainScreen.scale)];
        line.backgroundColor = self.tableView.separatorColor;
        line;
    });
    self.tableView.allowsSelection=YES;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LWBuyLykkeInContainerTableViewCell" bundle:nil] forCellReuseIdentifier:@"BuyLykkeInContainerId"];
    // Do any additional setup after loading the view from its nib.
    
    self.hideKeyboardOnTap=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!wallets)
        [self setLoading:YES];
    
    [[LWAuthManager instance] requestLykkeWallets];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!wallets.count)
        return 0;
    return wallets.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWBuyLykkeInContainerTableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:@"BuyLykkeInContainerId"];
    if (!cell)
    {
        cell = [[LWBuyLykkeInContainerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BuyLykkeInContainerId"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    cell.assetLabel.text=[wallets[indexPath.row] name];
    LWLykkeAssetsData *wallet=wallets[indexPath.row];
    NSString *assetId=wallet.identity;
    cell.balanceLabel.text=[NSString stringWithFormat:@"%@ %@", [[LWCache instance] currencySymbolForAssetId:assetId], [LWUtils formatFairVolume:wallet.balance.doubleValue accuracy:[LWCache accuracyForAssetId:assetId] roundToHigher:NO]];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    LWExchangeDealFormPresenter *presenter=[LWExchangeDealFormPresenter new];
    LWAssetPairModel *pair;
    
    NSString *assetId=[wallets[indexPath.row] identity];
    for(LWAssetPairModel *m in [LWCache instance].allAssetPairs)
    {
        if([m.identity rangeOfString:assetId].location!=NSNotFound && [m.identity rangeOfString:@"LKK"].location!=NSNotFound)
        {
            pair=m;
            break;
        }
    }
    
    if(!pair)
        return;
    if([pair.baseAssetId isEqualToString:@"LKK"]==NO)
        [pair setInverted:!pair.inverted];
    
    
    presenter.assetPair=pair;
    presenter.assetDealType=LWAssetDealTypeBuy;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.parentViewController.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
    }

    
}


-(void) authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data
{
    [self setLoading:NO];
    wallets=[[NSMutableArray alloc] init];
    for(LWLykkeAssetsData *d in data.lykkeData.assets)
        if(d.balance.doubleValue>0 && [d.identity isEqualToString:@"LKK"]==NO)
            [wallets addObject:d];

    
    
    [self.tableView reloadData];
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response];
}


@end


