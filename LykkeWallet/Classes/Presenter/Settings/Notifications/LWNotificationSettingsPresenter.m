//
//  LWNotificationSettingsPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNotificationSettingsPresenter.h"
#import "LWRadioTableViewCell.h"
#import "UIViewController+Navigation.h"


@interface LWNotificationSettingsPresenter () {
    
}

@end


@implementation LWNotificationSettingsPresenter


static NSInteger const kNumberOfRows = 2;

static NSString *const SettingsCells[kNumberOfRows] = {
    kRadioTableViewCell,
    kRadioTableViewCell
};

static NSString *const SettingsIdentifiers[kNumberOfRows] = {
    kRadioTableViewCellIdentifier,
    kRadioTableViewCellIdentifier
};


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localize(@"settings.push.title");
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[0]
                             forName:SettingsCells[0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = SettingsIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}


#pragma mark - LWAuthenticatedTablePresenter

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    LWRadioTableViewCell *itemCell = (LWRadioTableViewCell *)cell;
    if (indexPath.row == 0) {
        itemCell.titleLabel.text = Localize(@"settings.cell.push.order.title");
    }
    else if (indexPath.row == 1) {
        itemCell.titleLabel.text = Localize(@"settings.cell.push.asset.title");
    }
}

@end
