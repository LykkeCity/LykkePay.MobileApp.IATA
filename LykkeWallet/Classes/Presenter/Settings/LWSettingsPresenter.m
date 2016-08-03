//
//  LWSettingsPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWSettingsPresenter.h"
#import "LWSettingsConfirmationPresenter.h"
#import "LWNotificationSettingsPresenter.h"
#import "LWPersonalDataPresenter.h"
#import "LWAssetsTablePresenter.h"
#import "LWAuthNavigationController.h"
#import "LWKeychainManager.h"
#import "LWAssetModel.h"
#import "LWSettingsAssetTableViewCell.h"
#import "LWSettingsLogOutTableViewCell.h"
#import "LWRadioTableViewCell.h"
#import "LWCache.h"
#import "LWFingerprintHelper.h"
#import "UIViewController+Loading.h"
#import "LWCache.h"
#import "LWPacketApplicationInfo.h"
#import "LWSettingsTermsTableViewCell.h"
#import "LWSettingsCallSupportTableViewCell.h"
#import "LWValidator.h"
#import "LWRefundPresenter.h"
#import "LWPacketGetRefundAddress.h"
#import "LWUtils.h"

@import MessageUI;


@interface LWSettingsPresenter () <LWRadioTableViewCellDelegate, LWSettingsConfirmationPresenter, MFMailComposeViewControllerDelegate> {
    LWAssetModel *baseAsset;
}


#pragma mark - Utils

- (void)updateSignStatus;


@end


@implementation LWSettingsPresenter


static NSInteger const kNumberOfRows = 8;
// cell identifiers
static NSInteger const kKYCCellId    = 0;
static NSInteger const kPINCellId    = 1;
static NSInteger const kPushCellId   = 2;
static NSInteger const kAssetCellId  = 3;
static NSInteger const kRefundAddress =4;
static NSInteger const kTermsOfUseCellId   = 5;
static NSInteger const kCallSupportCellId =6;
static NSInteger const kLogoutCellId = 7;


static NSString *const SettingsCells[kNumberOfRows] = {
    kSettingsAssetTableViewCell,
    kRadioTableViewCell,
    kSettingsAssetTableViewCell,
    kSettingsAssetTableViewCell,
    kSettingsAssetTableViewCell,
    kSettingsTermsTableViewCell,
    kSettingsCallSupportTableViewCell,
    @"LWSettingsLogOutTableViewCell"

};

static NSString *const SettingsIdentifiers[kNumberOfRows] = {
    kSettingsAssetTableViewCellIdentifier,
    kRadioTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier,
    kSettingsTermsTableViewCellIdentifier,
    kSettingsCallSupportTableViewCellIdentifier,
    @"LWSettingsLogOutTableViewCellIdentifier"
};


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor=[UIColor whiteColor];
    
    
    [self registerCellWithIdentifier:SettingsIdentifiers[0]
                                name:SettingsCells[0]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[1]
                                name:SettingsCells[1]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[kLogoutCellId]
                                name:SettingsCells[kLogoutCellId]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[kTermsOfUseCellId]
                                name:SettingsCells[kTermsOfUseCellId]];

    [self registerCellWithIdentifier:SettingsIdentifiers[kCallSupportCellId]
                                name:SettingsCells[kCallSupportCellId]];

    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
 
    baseAsset = nil;
    
    
//    NSDictionary *attributesCallSupport=@{NSKernAttributeName:@(1), NSFontAttributeName:self.callSupportButton.titleLabel.font, NSForegroundColorAttributeName:[UIColor whiteColor]};
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
//        [self.callSupportButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"settings.callbutton.title") attributes:attributesCallSupport] forState:UIControlStateNormal];
//    else
//        [self.callSupportButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"settings.mailbutton.title") attributes:attributesCallSupport] forState:UIControlStateNormal];
//
//    [LWValidator setButton:self.callSupportButton enabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
    
    [self.tableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"tab.settings");
    if([LWCache instance].refundAddress.length==0 || [LWCache instance].baseAssetId.length==0)
    {
        [self setLoading:YES];
    }
    [[LWAuthManager instance] requestBaseAssetGet];
    [[LWAuthManager instance] requestAPIVersion];
    [[LWAuthManager instance] requestGetRefundAddress];

}

-(void) callSupport
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://+41615880402"]];
    else
    {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[@"support@lykkex.com"]];
//            [composeViewController setSubject:@"example subject"];
            [self presentViewController:composeViewController animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0)
        return 5;
    else if(section==1)
        return 2;
    else
        return 2;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d", indexPath.row);
    
    if(indexPath.section==2 && indexPath.row==1)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if([[LWCache instance].serverAPIVersion length])
        {
            UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 50)];
            label.text=[NSString stringWithFormat:@"%@, API %@",[LWCache currentAppVersion], [LWCache instance].serverAPIVersion];
            label.textAlignment=NSTextAlignmentCenter;
            label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
            label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
            label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:label];
            
        }
        
        cell.userInteractionEnabled=NO;
        return cell;
    }
    
    NSIndexPath *newIndexPath=indexPath;
    
    if(indexPath.section==1)
    {
        newIndexPath=[NSIndexPath indexPathForRow:indexPath.row+5 inSection:0];
    }
    else if(indexPath.section==2)
        newIndexPath=[NSIndexPath indexPathForRow:indexPath.row+7 inSection:0];
    
    NSString *identifier = SettingsIdentifiers[newIndexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:newIndexPath];
    
    cell.separatorInset=UIEdgeInsetsMake(0, 20, 0, 0);
    if(indexPath.row==0)
    {
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
        [cell addSubview:lineView];
    }
    if((indexPath.section==0 && indexPath.row==4) || (indexPath.section==1 && indexPath.row==1) || (indexPath.section==2))
    {
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 50.0-0.5, 1024, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
        [cell addSubview:lineView];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)] && (indexPath.section==2 && indexPath.row==1)) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, 1024, 0.f, 0.f);

    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section==0)
    {
        if (indexPath.row == kKYCCellId) {
            LWPersonalDataPresenter *push = [LWPersonalDataPresenter new];
            [self.navigationController pushViewController:push animated:YES];
        }
        else if (indexPath.row == kPushCellId) {
            LWNotificationSettingsPresenter *push = [LWNotificationSettingsPresenter new];
            [self.navigationController pushViewController:push animated:YES];
        }
        else if (indexPath.row == kAssetCellId && baseAsset) {
            LWAssetsTablePresenter *assets = [LWAssetsTablePresenter new];
            assets.baseAssetId = baseAsset.identity;
            [self.navigationController pushViewController:assets animated:YES];
        }
        else if (indexPath.row == kRefundAddress) {
            LWRefundPresenter *push = [LWRefundPresenter new];
            [self.navigationController pushViewController:push animated:YES];
        }

    }
    else if(indexPath.section==1)
    {
        if(indexPath.row+5==kTermsOfUseCellId)
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTermsOfUseURL]];
        else if(indexPath.row+5==kCallSupportCellId)
            [self callSupport];
    }
    else if(indexPath.section==2)
    {
        if(indexPath.row+7==kLogoutCellId)
            [(LWAuthNavigationController *)self.navigationController logout];

    }
    

}

-(CGFloat) tableView:(UITableView *) tableView heightForFooterInSection:(NSInteger)section
{
    if(section==2)
        return 0;
    
    return 20;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    //Set the background color of the View
    view.tintColor = [UIColor whiteColor];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetBaseAsset:(LWAssetModel *)asset {
    baseAsset = asset;
    
    if([LWCache instance].refundAddress.length>0)
    {
        [self setLoading:NO];
    }

    NSIndexPath *path = [NSIndexPath indexPathForRow:kAssetCellId inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    [self configureCell:cell indexPath:path];
}

-(void) authManager:(LWAuthManager *) manager didGetAPIVersion:(LWPacketApplicationInfo *)apiVersion
{
    if(apiVersion.apiVersion)
    {
        [LWCache instance].serverAPIVersion=apiVersion.apiVersion;
        [self.tableView reloadData];
    }

}

-(void) authManager:(LWAuthManager *)manager didGetRefundAddress:(LWPacketGetRefundAddress *)address
{
    [LWCache instance].refundAddress=address.refundAddress;
    NSIndexPath *path = [NSIndexPath indexPathForRow:kRefundAddress inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    [self configureCell:cell indexPath:path];

    if([LWCache instance].baseAssetId.length>0)
    {
        [self setLoading:NO];
    }

}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    
    [self updateSignStatus];
    
    [self setLoading:NO];
}

- (void)authManagerDidSetSignOrders:(LWAuthManager *)manager {
    [self setLoading:NO];
    [self updateSignStatus];
}


#pragma mark - LWAuthenticatedTablePresenter

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kKYCCellId) {
        LWSettingsAssetTableViewCell *kycCell = (LWSettingsAssetTableViewCell *)cell;
        kycCell.titleLabel.text = Localize(@"settings.cell.kyc.title");
        kycCell.assetLabel.text = @"";
    }
    else if (indexPath.row == kPINCellId) {
        LWRadioTableViewCell *radioCell = (LWRadioTableViewCell *)cell;
        radioCell.delegate = self;
        radioCell.titleLabel.text = Localize(@"settings.cell.pin.title");
        [radioCell setSwitcherOn:[LWCache instance].shouldSignOrder];
    }
    else if (indexPath.row == kPushCellId) {
        LWSettingsAssetTableViewCell *assetCell = (LWSettingsAssetTableViewCell *)cell;
        assetCell.titleLabel.text = Localize(@"settings.cell.push.title");
        assetCell.assetLabel.text = @"";
    }
    else if (indexPath.row == kAssetCellId) {
        LWSettingsAssetTableViewCell *assetCell = (LWSettingsAssetTableViewCell *)cell;
        assetCell.titleLabel.text = Localize(@"settings.cell.asset.title");
        if ([LWCache instance].baseAssetId) {
            
            NSString *baseAssetId = [LWCache instance].baseAssetId;
            for(LWAssetModel *m in [LWCache instance].baseAssets)
                if ([baseAssetId isEqualToString:m.identity]) {
                    assetCell.assetLabel.text = m.name;
                    break;
                }
            
        }
    }
    else if (indexPath.row == kLogoutCellId) {
        LWSettingsLogOutTableViewCell *logoutCell = (LWSettingsLogOutTableViewCell *)cell;
        NSString *logout = [NSString stringWithFormat:@"%@ %@", Localize(@"settings.cell.logout.title"), [LWKeychainManager instance].login.lowercaseString];
        logoutCell.logoutLabel.text = logout;
    }
    else if (indexPath.row == kRefundAddress) {
        LWSettingsAssetTableViewCell *refundCell = (LWSettingsAssetTableViewCell *)cell;
        refundCell.titleLabel.text = @"Refund Address";
        refundCell.assetLabel.text=[LWCache instance].refundAddress;
    }
    else if(indexPath.row==kCallSupportCellId)
    {
        LWSettingsCallSupportTableViewCell *assetCell = (LWSettingsCallSupportTableViewCell *)cell;
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        {
            assetCell.titleLabel.text = Localize(@"settings.callbutton.title");
        }
        else
        {
            assetCell.titleLabel.text = Localize(@"settings.mailbutton.title");
            assetCell.phoneLabel.text=@"support@lykkex.com";
        }
        
 
    }

    
}


#pragma mark - LWRadioTableViewCellDelegate

- (void)switcherChanged:(BOOL)isOn {
    LWSettingsConfirmationPresenter *validator = [LWSettingsConfirmationPresenter new];
    validator.delegate = self;
    validator.isOn = isOn;
    [self.navigationController pushViewController:validator animated:YES];
}


#pragma mark - LWSettingsConfirmationPresenter

- (void)operationConfirmed:(LWSettingsConfirmationPresenter *)presenter {
    [self setLoading:YES];
    [[LWAuthManager instance] requestSignOrders:presenter.isOn];
}

- (void)operationRejected {
    [self updateSignStatus];
}


#pragma mark - Utils

- (void)updateSignStatus {
    LWRadioTableViewCell *radioCell = (LWRadioTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPINCellId inSection:0]];
    [radioCell setSwitcherOn:[LWCache instance].shouldSignOrder];
}

@end
