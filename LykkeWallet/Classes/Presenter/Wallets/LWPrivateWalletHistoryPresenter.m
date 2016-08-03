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


@interface LWPrivateWalletHistoryPresenter () <UITableViewDelegate, UITableViewDataSource, LWDoubleButtonViewDelegate>
{
    UITableView *tableView;
    NSArray *wallets;
    LWDoubleButtonView *button;
    
    NSArray *historyArray;
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

    
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLoading:YES];
    [[LWPrivateWalletsManager shared] loadHistoryForWallet:self.wallet.address withCompletion:^(NSArray *array){
        [self setLoading:NO];
        historyArray=array;
        [tableView reloadData];
    }];
    
    [self setTitle:@"HISTORY"];

}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    tableView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-82);
    button.frame=CGRectMake(30, self.view.bounds.size.height-30-45, self.view.bounds.size.width-60, 45);
}

-(void) doubleButtonPressedLeft:(LWDoubleButtonView *)button
{
    LWPrivateWalletTransferPresenter *presenter=[[LWPrivateWalletTransferPresenter alloc] init];
    LWPKTransferModel *transfer=[[LWPKTransferModel alloc] init];
    transfer.sourceWallet=self.wallet;
    transfer.asset=self.asset;
    presenter.transfer=transfer;
    
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) doubleButtonPressedRight:(LWDoubleButtonView *)button
{
    
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
