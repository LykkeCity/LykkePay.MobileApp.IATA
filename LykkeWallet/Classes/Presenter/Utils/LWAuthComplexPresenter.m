//
//  LWAuthComplexPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWAuthComplexPresenter () <UITableViewDataSource, UITableViewDelegate> {
    UIRefreshControl *refreshControl;
}

@end


@implementation LWAuthComplexPresenter


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(0, @"Should be ovveriden");
    return nil;
}


#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - Utils

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name {
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
}

- (void)setRefreshControl
{
    if (self.tableView) {
        UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
        [self.tableView insertSubview:refreshView atIndex:0];
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor blackColor];
        [refreshControl addTarget:self action:@selector(startRefreshControl)
                 forControlEvents:UIControlEventValueChanged];
        [refreshView addSubview:refreshControl];
    }
}

- (void)stopRefreshControl {
    if (refreshControl) {
        [refreshControl endRefreshing];
    }
}

- (void)startRefreshControl {
    if (refreshControl) {
        [refreshControl beginRefreshing];
    }
}

@end
