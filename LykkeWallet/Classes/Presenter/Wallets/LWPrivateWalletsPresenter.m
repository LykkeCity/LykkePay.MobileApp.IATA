//
//  LWPrivateWalletsPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletsPresenter.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletTitleCell.h"
#import "LWPrivateWalletAssetCell.h"
#import "LWPrivateWalletsHeaderSumView.h"

@interface LWPrivateWalletsPresenter () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSArray *wallets;
}

@end

@implementation LWPrivateWalletsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView=[[UITableView alloc] init];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.view addSubview:tableView];
    
    NSMutableArray *www=[[NSMutableArray alloc] init];
    
    NSArray *arr=@[@"MY LYKKE WALLET", @"MULTI WALLET", @"WALLET #30153"];
    for(NSString *s in arr)
    {
        LWPrivateWalletModel *w=[[LWPrivateWalletModel alloc] init];
        w.name=s;
        if([arr indexOfObject:s]==0)
        {
            LWPrivateWalletAssetModel *ass=[[LWPrivateWalletAssetModel alloc] init];
            ass.name=@"BTC";
            ass.amount=@(30.15);
            ass.baseAssetAmount=@(201);
            ass.assetId=@"BTC";
            LWPrivateWalletAssetModel *ass1=[[LWPrivateWalletAssetModel alloc] init];
            ass1.name=@"Lykke Corp";
            ass1.amount=@(134.20);
            ass1.baseAssetAmount=@(14);
            ass1.assetId=@"LKK";
            w.assets=@[ass1, ass];

        }
        [www addObject:w];
    }

    wallets=www;
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    
//    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
//    self.navigationController.navigationController.navigationItem.rightBarButtonItem = anotherButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    tableView.frame=self.view.bounds;
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
    if(indexPath.row==0)
    {
        LWPrivateWalletTitleCell *cell=[[LWPrivateWalletTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.wallet=wallets[indexPath.section];
        return cell;
    }
    else
    {
        LWPrivateWalletAssetCell *cell=[[LWPrivateWalletAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.asset=[wallets[indexPath.section] assets][indexPath.row-1];
        return cell;
    }
    
}

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
        view.total=@(401.90);
        return view;
    }
    return nil;
}






@end
