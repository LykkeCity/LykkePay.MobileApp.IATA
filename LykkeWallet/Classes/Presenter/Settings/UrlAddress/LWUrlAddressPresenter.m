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
{
    
}

@end


@implementation LWUrlAddressPresenter

static NSInteger const kAddressesCount = 3;

static NSString *const addresses[kAddressesCount] = {
    kDevelopTestServer,
    kStagingTestServer,
    kTestingTestServer
    
};

static NSString *const titles[kAddressesCount] = {
    @"DEV",
    @"STAGING",
    @"TEST"
    
};




//static NSString *const addresses[kAddressesCount] = {
//    kStagingTestServer,
//    kDevelopTestServer,
//    kDemoTestServer
//};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Server addresses";
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
    
    NSString *address = [LWKeychainManager instance].address;
    NSString *newAddress=addresses[indexPath.row];
    
    if (![address isEqualToString:newAddress]) {
        [[LWKeychainManager instance] saveAddress:newAddress];
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
        
        itemCell.titleLabel.font=[UIFont boldSystemFontOfSize:14];
        itemCell.detailLabel.font=[UIFont systemFontOfSize:12];
        itemCell.titleLabel.text = titles[indexPath.row];
        itemCell.detailLabel.text = addresses[indexPath.row];
        itemCell.titleConstraint.constant = 60;
        
        // set checkmark for selected item
        if ([addresses[indexPath.row] isEqualToString:address]) {
            itemCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            itemCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end
