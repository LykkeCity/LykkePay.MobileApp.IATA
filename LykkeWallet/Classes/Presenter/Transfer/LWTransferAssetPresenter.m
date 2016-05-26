//
//  LWTransferAssetPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransferAssetPresenter.h"
#import "LWChooseAssetTableViewCell.h"
#import "LWAssetModel.h"
#import "LWCache.h"
#import "LWConstants.h"
#import "UIViewController+Navigation.h"


@interface LWTransferAssetPresenter () {
    
}

@property (copy, nonatomic) NSArray *assets;

@end


@implementation LWTransferAssetPresenter

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localize(@"settings.assets.title");
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:@"LWChooseAssetTableViewCellIdentifier"
                             forName:@"LWChooseAssetTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.assets = [[LWCache instance].baseAssets copy];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.assets ? self.assets.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"LWChooseAssetTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWChooseAssetTableViewCell *cell = (LWChooseAssetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell && self.selectedAssetId) {
        [self.delegate assetSelected:cell.assetId];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - LWAuthenticatedTablePresenter

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    LWChooseAssetTableViewCell *itemCell = (LWChooseAssetTableViewCell *)cell;
    LWAssetModel *model = (LWAssetModel *)[self.assets objectAtIndex:indexPath.row];
    if (model && itemCell) {
        itemCell.assetId        = model.identity;
        itemCell.assetName.text = model.name;
        itemCell.tintColor = [UIColor colorWithHexString:kMainElementsColor];
        // set checkmark for base asset
        if (self.selectedAssetId &&
            [model.identity isEqualToString:self.selectedAssetId]) {
            itemCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            itemCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end
