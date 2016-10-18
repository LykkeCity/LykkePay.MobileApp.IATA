//
//  LWPrivateWalletsPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletsPresenter.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletTitleCell.h"
#import "LWPrivateWalletAssetCell.h"
#import "LWPrivateWalletsHeaderSumView.h"
#import "LWPrivateWalletsManager.h"
#import "LWPrivateWalletHistoryPresenter.h"
#import "LWAddPrivateWalletPresenter.h"
#import "UIViewController+Loading.h"
#import "LWRefreshControlView.h"
#import "LWCreateEditPrivateWalletPresenter.h"

@interface LWPrivateWalletsPresenter () <UITableViewDelegate, UITableViewDataSource>
{
//    UITableView *tableView;
    NSArray *wallets;
    LWRefreshControlView *refreshControl;
}

@end

@implementation LWPrivateWalletsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
//    tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
//    [self.view addSubview:tableView];
    
    NSMutableArray *www=[[NSMutableArray alloc] init];
    wallets=www;
    
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[LWRefreshControlView alloc] init];
    [refreshControl addTarget:self action:@selector(reloadWallets)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];

    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    if(!wallets.count)
        [self setLoading:YES];
    [self reloadWallets];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"WALLET";
}

-(void) reloadWallets
{
    [[LWPrivateWalletsManager shared] loadWalletsWithCompletion:^(NSArray *arr){
        wallets=arr;
        [refreshControl endRefreshing];
        [self.tableView reloadData];
        [self setLoading:NO];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    self.tableView.frame=self.view.bounds;
//    [self.tableView layoutIfNeeded];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return wallets.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LWPrivateWalletModel *wallet=wallets[section];
    return wallet.assets.count+1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
        return [LWPrivateWalletTitleCell height];
    else
        return [LWPrivateWalletAssetCell height];
}

-(UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id tableViewCell;
    if(indexPath.row==0)
    {
        
        LWPrivateWalletTitleCell *cell=[[LWPrivateWalletTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.wallet=wallets[indexPath.section];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        tableViewCell=cell;
    }
    else
    {
        LWPrivateWalletAssetCell *cell=[[LWPrivateWalletAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.asset=[wallets[indexPath.section] assets][indexPath.row-1];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if(indexPath.row==[self tableView:self.tableView numberOfRowsInSection:indexPath.section]-1)
            [cell addBottomLine];
        tableViewCell=cell;
    }
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSelected:)];
    [(UIView *)tableViewCell addGestureRecognizer:gesture];
    [(UIView *)tableViewCell setTag:indexPath.section*1000+indexPath.row];
    return tableViewCell;
}

-(void) cellSelected:(UITapGestureRecognizer *) gesture;
{
    int tag=(int)gesture.view.tag;
    int row=tag%1000;
    int section=tag/1000;
    id presenter;
    if(row==0)
    {
        presenter=[[LWCreateEditPrivateWalletPresenter alloc] init];
        [(LWCreateEditPrivateWalletPresenter *)presenter setEditMode:YES];
        [(LWCreateEditPrivateWalletPresenter *)presenter setWallet:wallets[section]];
        
    }
    else
    {
        presenter=[[LWPrivateWalletHistoryPresenter alloc] init];
        [(LWCreateEditPrivateWalletPresenter *)presenter setWallet:wallets[section]];
        [(LWPrivateWalletHistoryPresenter *)presenter setAsset:[wallets[section] assets][row-1]];
        
    }
    [self.navigationController pushViewController:presenter animated:YES];

}

//-(void) tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//    
//    id presenter;
//    if(indexPath.row==0)
//    {
//        presenter=[[LWCreateEditPrivateWalletPresenter alloc] init];
//        [(LWCreateEditPrivateWalletPresenter *)presenter setEditMode:YES];
//        [(LWCreateEditPrivateWalletPresenter *)presenter setWallet:wallets[indexPath.section]];
//
//    }
//    else
//    {
//        presenter=[[LWPrivateWalletHistoryPresenter alloc] init];
//        [(LWCreateEditPrivateWalletPresenter *)presenter setWallet:wallets[indexPath.section]];
//        [(LWPrivateWalletHistoryPresenter *)presenter setAsset:[wallets[indexPath.section] assets][indexPath.row-1]];
//        
//    }
//    [self.navigationController pushViewController:presenter animated:YES];
//}


-(CGFloat) tableView:(UITableView *) tableView heightForFooterInSection:(NSInteger)section
{
    if(section==wallets.count-1)
        return 0;
    
    return 10;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 52;
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        LWPrivateWalletsHeaderSumView *view=[[LWPrivateWalletsHeaderSumView alloc] init];
        
        float total=0;
        for(LWPrivateWalletModel *m in wallets)
            for(LWPrivateWalletAssetModel *a in m.assets)
                total+=a.baseAssetAmount.floatValue;
        
        
        view.total=@(total);
        return view;
    }
    return nil;
}


//-(NSString *) nibName
//{
//    return nil;
//}





@end
