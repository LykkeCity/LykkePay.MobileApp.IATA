//
//  LWAssetsTablePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetsTablePresenter.h"
#import "LWChooseAssetTableViewCell.h"
#import "LWAuthManager.h"
#import "LWAssetModel.h"
#import "LWConstants.h"
#import "LWCache.h"

#import "UIColor+Generic.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"


@interface LWAssetsTablePresenter () {
    
}

@property (copy, nonatomic) NSArray *assets;

@end


@implementation LWAssetsTablePresenter


-(void) awakeFromNib
{
    

}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = Localize(@"settings.assets.title");
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:@"LWChooseAssetTableViewCellIdentifier"
                             forName:@"LWChooseAssetTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.assets = [[LWCache instance].baseAssets copy];
    if (!self.assets || self.assets.count == 0) {
        [self setLoading:YES];
    }
    
    [[LWAuthManager instance] requestBaseAssets];
}


#pragma mark - LWAuthManagerDelegate

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)authManager:(LWAuthManager *)manager didGetBaseAssets:(NSArray *)assets {
    [self setLoading:NO];
    
    self.assets = [assets copy];
    [self.tableView reloadData];
}

- (void)authManagerDidSetAsset:(LWAuthManager *)manager {
    [self setLoading:NO];
    [LWCache instance].baseAssetId=self.baseAssetId;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];

    [self.navigationController popViewControllerAnimated:YES];
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
    if(indexPath.row==0)
    {
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
        [cell addSubview:lineView];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWChooseAssetTableViewCell *cell = (LWChooseAssetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    if (cell && self.baseAssetId) {
        // do nothing
        if ([cell.assetId isEqualToString:self.baseAssetId]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [[LWAuthManager instance] requestBaseAssetSet:cell.assetId];
            self.baseAssetId=cell.assetId;
            [self setLoading:YES];
        }
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
        if (self.baseAssetId &&
            [model.identity isEqualToString:self.baseAssetId]) {
            itemCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            itemCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end
