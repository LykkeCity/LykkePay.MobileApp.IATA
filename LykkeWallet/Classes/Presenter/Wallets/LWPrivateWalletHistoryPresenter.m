//
//  LWPrivateWalletHistoryPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletHistoryPresenter.h"
#import "LWDoubleButtonView.h"
#import "LWPrivateWalletsManager.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletHistoryCellModel.h"
#import "LWPrivateWalletHistoryCell.h"
#import "LWPrivateWalletTransferPresenter.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWPKTransferModel.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWRefreshControlView.h"
#import "LWPrivateWalletEmptyHistoryPresenter.h"
#import "LWPrivateWalletDeposit.h"

@interface LWPrivateWalletHistoryPresenter () <UITableViewDelegate, UITableViewDataSource, LWDoubleButtonViewDelegate, LWPrivateWalletEmptyHistoryPresenterDelegate>
{
    UITableView *tableView;
    NSArray *wallets;
    LWDoubleButtonView *button;
    
    NSArray *historyArray;
    LWRefreshControlView *refreshControl;
    LWPrivateWalletEmptyHistoryPresenter *emptyPresenter;
    
    
    UILabel *balanceLabel;
}

@end

@implementation LWPrivateWalletHistoryPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackButton];
    self.view.backgroundColor=[UIColor whiteColor];
    
    button=[[LWDoubleButtonView alloc] initWithTitles:@[@"TRANSFER", @"DEPOSIT"]];
    button.delegate=self;
    [self.view addSubview:button];
    
    tableView=[[UITableView alloc] init];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:tableView];
    
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[LWRefreshControlView alloc] init];
    [refreshControl addTarget:self action:@selector(reloadHistory)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];

    balanceLabel=[[UILabel alloc] init];
    balanceLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    balanceLabel.textAlignment=NSTextAlignmentCenter;
    balanceLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    [self.view addSubview:balanceLabel];
    
    
    

    
    
    // Do any additional setup after loading the view.
}

-(void) reloadHistory
{
    [[LWPrivateWalletsManager shared] loadHistoryForWallet:self.wallet.address withCompletion:^(NSArray *array){
        [self setLoading:NO];
        historyArray=array;
        [tableView reloadData];
        [refreshControl endRefreshing];
        if(emptyPresenter)
            [emptyPresenter.refreshControl endRefreshing];
        
        if(historyArray.count==0)
        {
            emptyPresenter=[[LWPrivateWalletEmptyHistoryPresenter alloc] init];
            emptyPresenter.view.frame=self.view.bounds;
            emptyPresenter.delegate=self;
            [self.view addSubview:emptyPresenter.view];
            [self addChildViewController:emptyPresenter];
        }
        else if(emptyPresenter)
        {
            [emptyPresenter.view removeFromSuperview];
            [emptyPresenter removeFromParentViewController];
            emptyPresenter=nil;
        }
        
        [[LWPrivateWalletsManager shared] loadWalletBalances:self.wallet.address withCompletion:^(NSArray *arr){
        
            for(LWPrivateWalletAssetModel *m in arr)
            {
                if([m.assetId isEqualToString:self.asset.assetId])
                {
                    balanceLabel.text=[NSString stringWithFormat:@"%@ %@ available", self.asset.assetId, m.amount.stringValue];
                    if(emptyPresenter)
                        emptyPresenter.balanceLabel.text=balanceLabel.text;
                        
                }
            }
        
        }];
        
    }];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLoading:YES];
    [self reloadHistory];
    
    [self setTitle:self.wallet.name];

}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    balanceLabel.frame=CGRectMake(0, 0, self.view.bounds.size.width, 20);
    tableView.frame=CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-82-20);
    button.frame=CGRectMake(30, self.view.bounds.size.height-30-45, self.view.bounds.size.width-60, 45);
}

-(void) doubleButtonPressedLeft:(LWDoubleButtonView *)button
{
    LWPrivateWalletTransferPresenter *presenter=[[LWPrivateWalletTransferPresenter alloc] init];
    LWPKTransferModel *transfer=[[LWPKTransferModel alloc] init];
    transfer.sourceWallet=self.wallet;
    transfer.asset=self.asset;
    presenter.transfer=transfer;
    
//    [self.navigationController pushViewController:presenter animated:YES];
    
    
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

-(void) doubleButtonPressedRight:(LWDoubleButtonView *)button
{
    [self depositPressed];
}

-(void) depositPressed
{
    LWPrivateWalletDeposit *presenter=[[LWPrivateWalletDeposit alloc] init];
    presenter.asset=self.asset;
    presenter.wallet=self.wallet;
    
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return historyArray.count;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWPrivateWalletHistoryCell *cell=[[LWPrivateWalletHistoryCell alloc] initWithModel:historyArray[indexPath.row]];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
