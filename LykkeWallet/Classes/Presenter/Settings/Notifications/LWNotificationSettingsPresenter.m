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
#import "UIViewController+Loading.h"
#import "LWAuthManager.h"
#import "LWPacketPushSettingsGet.h"
#import "LWCache.h"



@interface LWNotificationSettingsPresenter () <LWRadioTableViewCellDelegate>{
    
}

@end


@implementation LWNotificationSettingsPresenter


static NSInteger const kNumberOfRows = 1;

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
    
    self.title = Localize(@"settings.push.title");
    
    [self setBackButton];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[0]
                             forName:SettingsCells[0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([LWCache instance].pushNotificationsStatus==PushNotificationsStatusUnknown)
    {
        [self setLoading:YES];
        [[LWAuthManager instance] requestGetPushSettings];
    }
}


#pragma mark - UITableViewDataSource

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

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
        itemCell.titleLabel.text = Localize(@"settings.cell.push.sendpush");
        [itemCell setSwitcherOn:[LWCache instance].pushNotificationsStatus==PushNotificationsStatusEnabled];
        itemCell.delegate=self;
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
        [itemCell addSubview:lineView];
        

    }
    else if (indexPath.row == 1) {
        itemCell.titleLabel.text = Localize(@"settings.cell.push.asset.title");
    }
}

-(void) switcherChanged:(BOOL)isOn
{
    [self setLoading:YES];
    if(isOn)
        [LWCache instance].pushNotificationsStatus=PushNotificationsStatusEnabled;
    else
        [LWCache instance].pushNotificationsStatus=PushNotificationsStatusDisabled;
    
    [[LWAuthManager instance] requestSetPushEnabled:isOn];
    
}

#pragma mark - LWAuthManager

-(void) authManager:(LWAuthManager *)manager didGetPushSettings:(LWPacketPushSettingsGet *)status
{
    [self setLoading:NO];
    [self.tableView reloadData];
}

-(void) authManagerDidSetPushSettings
{
    [self setLoading:NO];
}




@end
