//
//  LWPrivateWalletHistoryPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletHistoryPresenter.h"

@interface LWPrivateWalletHistoryPresenter () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSArray *wallets;
}

@end

@implementation LWPrivateWalletHistoryPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    tableView=[[UITableView alloc] init];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.view addSubview:tableView];

    
    // Do any additional setup after loading the view.
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
