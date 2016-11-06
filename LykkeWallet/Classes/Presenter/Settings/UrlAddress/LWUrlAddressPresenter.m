//
//  LWUrlAddressPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 29.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWUrlAddressPresenter.h"
#import "LWDetailTableViewCell.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Navigation.h"
#import "LWKeychainManager.h"
#import "LWConstants.h"


@interface LWUrlAddressPresenter ()

@end


@implementation LWUrlAddressPresenter

static NSInteger const kAddressesCount = 3;
static NSString *const addresses[kAddressesCount] = {
    kStagingTestServer,
    kDevelopTestServer,
    kDemoTestServer
};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Server addresses";
    [self setBackButton];
    
    [self registerCellWithIdentifier:kDetailTableViewCellIdentifier
                             forName:kDetailTableViewCell];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kAddressesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = kDetailTableViewCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWDetailTableViewCell *cell = (LWDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *address = [LWKeychainManager instance].address;
    
    if (![cell.titleLabel.text isEqualToString:address]) {
        [[LWKeychainManager instance] saveAddress:cell.titleLabel.text];
        [(LWAuthNavigationController *)self.navigationController logout];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - LWAuthenticatedTablePresenter

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    LWDetailTableViewCell *itemCell = (LWDetailTableViewCell *)cell;
    if (itemCell) {
        NSString *address = [LWKeychainManager instance].address;
        itemCell.titleLabel.text = addresses[indexPath.row];
        itemCell.detailLabel.text = @"";
        itemCell.titleConstraint.constant = 200;
        
        // set checkmark for selected item
        if ([addresses[indexPath.row] isEqualToString:address]) {
            itemCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            itemCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end
