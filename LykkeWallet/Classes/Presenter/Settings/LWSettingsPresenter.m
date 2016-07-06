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
#import "LWPacketAPIVersion.h"
#import "LWSettingsTermsTableViewCell.h"
#import "LWValidator.h"
#import "LWRefundPresenter.h"
#import "LWPacketGetRefundAddress.h"

@import MessageUI;


@interface LWSettingsPresenter () <LWRadioTableViewCellDelegate, LWSettingsConfirmationPresenter, MFMailComposeViewControllerDelegate> {
    LWAssetModel *baseAsset;
}


#pragma mark - Utils

- (void)updateSignStatus;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *callSupportButton;

@end


@implementation LWSettingsPresenter


static NSInteger const kNumberOfRows = 7;
// cell identifiers
static NSInteger const kKYCCellId    = 0;
static NSInteger const kPINCellId    = 1;
static NSInteger const kPushCellId   = 2;
static NSInteger const kAssetCellId  = 3;
static NSInteger const kLogoutCellId = 4;
static NSInteger const kTermsOfUseCellId   = 5;
static NSInteger const kRefundAddress =6;

static NSString *const SettingsCells[kNumberOfRows] = {
    kSettingsAssetTableViewCell,
    kRadioTableViewCell,
    kSettingsAssetTableViewCell,
    kSettingsAssetTableViewCell,
    @"LWSettingsLogOutTableViewCell",
    kSettingsTermsTableViewCell,
    kSettingsAssetTableViewCell

};

static NSString *const SettingsIdentifiers[kNumberOfRows] = {
    kSettingsAssetTableViewCellIdentifier,
    kRadioTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier,
    @"LWSettingsLogOutTableViewCellIdentifier",
    kSettingsTermsTableViewCellIdentifier,
    kSettingsAssetTableViewCellIdentifier
};


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text=[LWCache currentAppVersion];
    
    
    [self registerCellWithIdentifier:SettingsIdentifiers[0]
                                name:SettingsCells[0]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[1]
                                name:SettingsCells[1]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[kLogoutCellId]
                                name:SettingsCells[kLogoutCellId]];
    
    [self registerCellWithIdentifier:SettingsIdentifiers[kTermsOfUseCellId]
                                name:SettingsCells[kTermsOfUseCellId]];

    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
 
    baseAsset = nil;
    
    
    NSDictionary *attributesCallSupport=@{NSKernAttributeName:@(1), NSFontAttributeName:self.callSupportButton.titleLabel.font, NSForegroundColorAttributeName:[UIColor whiteColor]};
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.callSupportButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"settings.callbutton.title") attributes:attributesCallSupport] forState:UIControlStateNormal];
    else
        [self.callSupportButton setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"settings.mailbutton.title") attributes:attributesCallSupport] forState:UIControlStateNormal];

    [LWValidator setButton:self.callSupportButton enabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
    
    [[LWAuthManager instance] requestBaseAssetGet];
    [[LWAuthManager instance] requestAPIVersion];
    [[LWAuthManager instance] requestGetRefundAddress];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"tab.settings");

}

-(IBAction) callSupportPressed:(id)sender
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d", indexPath.row);
    NSString *identifier = SettingsIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    else if (indexPath.row == kLogoutCellId) {
        [(LWAuthNavigationController *)self.navigationController logout];
    }
    else if(indexPath.row == kTermsOfUseCellId)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTermsOfUseURL]];
    else if (indexPath.row == kRefundAddress) {
        LWRefundPresenter *push = [LWRefundPresenter new];
        [self.navigationController pushViewController:push animated:YES];
    }

}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetBaseAsset:(LWAssetModel *)asset {
    baseAsset = asset;
    
    [self setLoading:NO];
    NSIndexPath *path = [NSIndexPath indexPathForRow:kAssetCellId inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    [self configureCell:cell indexPath:path];
}

-(void) authManager:(LWAuthManager *) manager didGetAPIVersion:(LWPacketAPIVersion *)apiVersion
{
    if(apiVersion.apiVersion)
        self.versionLabel.text=[NSString stringWithFormat:@"%@, API %@",[LWCache currentAppVersion], apiVersion.apiVersion];

}

-(void) authManager:(LWAuthManager *)manager didGetRefundAddress:(LWPacketGetRefundAddress *)address
{
    [LWCache instance].refundAddress=address.refundAddress;
    NSIndexPath *path = [NSIndexPath indexPathForRow:kRefundAddress inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    [self configureCell:cell indexPath:path];

}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    
    [self updateSignStatus];
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
        if (baseAsset) {
            assetCell.assetLabel.text = baseAsset.name;
        }
    }
    else if (indexPath.row == kLogoutCellId) {
        LWSettingsLogOutTableViewCell *logoutCell = (LWSettingsLogOutTableViewCell *)cell;
        NSString *logout = [NSString stringWithFormat:@"%@ %@", Localize(@"settings.cell.logout.title"), [LWKeychainManager instance].login];
        logoutCell.logoutLabel.text = logout;
    }
    else if (indexPath.row == kRefundAddress) {
        LWSettingsAssetTableViewCell *refundCell = (LWSettingsAssetTableViewCell *)cell;
        refundCell.titleLabel.text = @"Refund Address";
        refundCell.assetLabel.text=[LWCache instance].refundAddress;
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
