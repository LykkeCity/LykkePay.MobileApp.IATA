//
//  LWReceiverPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWReceiverPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTransferAssetPresenter.h"
#import "LWTransferResultController.h"

#import "LWAssetBuySumTableViewCell.h"
#import "LWSettingsAssetTableViewCell.h"
#import "LWTransferConfirmationView.h"

#import "LWAssetModel.h"
#import "LWAuthManager.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "LWMath.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWFingerprintHelper.h"
#import "UIColor+Generic.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "UITextField+Validation.h"
#import "NSString+Utils.h"


@interface LWReceiverPresenter ()<UITextFieldDelegate, LWTransferConfirmationViewDelegate, LWTransferAssetPresenterDelegate> {
    
    LWTransferConfirmationView *confirmationView;
    UITextField                *sumTextField;
    
    NSString *volumeString;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIImageView        *recepientImageView;
@property (weak, nonatomic) IBOutlet UILabel            *recepientNameLabel;
@property (weak, nonatomic) IBOutlet UIButton           *buyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;


#pragma mark - Utils

- (void)updateTitle;
- (void)updatePrice;
- (NSNumber *)volumeFromField;
- (void)validateUser;
- (void)showConfirmationView;

@end


@implementation LWReceiverPresenter

static NSInteger const kTransferRows = 2;

static NSString *const TransferIdentifiers[kTransferRows] = {
    kSettingsAssetTableViewCellIdentifier,
    @"LWAssetBuySumTableViewCellIdentifier"
};


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTitle];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    volumeString = @"";
    [self volumeChanged:volumeString withValidState:NO];
    
    [self registerCellWithIdentifier:@"LWAssetBuySumTableViewCellIdentifier"
                                name:@"LWAssetBuySumTableViewCell"];
    
    [self registerCellWithIdentifier:kSettingsAssetTableViewCellIdentifier
                                name:kSettingsAssetTableViewCell];
    
    [self.buyButton setTitle:Localize(@"transfer.receiver.button")
                    forState:UIControlStateNormal];
    
    [self setBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.observeKeyboardEvents = YES;
    
    [self updatePrice];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (sumTextField) {
        [sumTextField becomeFirstResponder];
    }
}


#pragma mark - TKPresenter

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.bottomConstraint setConstant:frame.size.height];
    [self animateConstraintChanges];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    [self.bottomConstraint setConstant:0];
    [self animateConstraintChanges];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kTransferRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = TransferIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row == 0) {
        LWSettingsAssetTableViewCell *baseAssetCell = (LWSettingsAssetTableViewCell *)cell;
        baseAssetCell.titleLabel.text = Localize(@"transfer.receiver.currency");
        baseAssetCell.assetLabel.text = [LWAssetModel assetByIdentity:self.selectedAssetId fromList:[LWCache instance].baseAssets];
    }
    else if (indexPath.row == 1) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)cell;
        sumCell.titleLabel.text = Localize(@"transfer.receiver.amount");
        
        sumTextField = sumCell.sumTextField;
        sumTextField.delegate = self;
        sumTextField.placeholder = Localize(@"transfer.receiver.placeholder");
        sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        [sumTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
        [sumTextField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LWTransferAssetPresenter *presenter = [LWTransferAssetPresenter new];
        presenter.selectedAssetId = self.selectedAssetId;
        presenter.delegate = self;
        [self.navigationController pushViewController:presenter animated:YES];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [textField isNumberValidForRange:range replacementString:string];
}

- (void)textFieldDidChange:(UITextField *)sender {
    [self volumeChanged:sender.text withValidState:[sender isNumberValid]];
    [self updatePrice];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidTransfer:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    if (confirmationView) {
        [confirmationView setLoading:NO withReason:@""];
        [confirmationView removeFromSuperview];
    }
    
    LWTransferResultController *controller = [LWTransferResultController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)authManager:(LWAuthManager *)manager didValidatePin:(BOOL)isValid {
    if (confirmationView) {
        if (isValid) {
            [confirmationView requestOperation];
        }
        else {
            [confirmationView pinRejected];
        }
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    
    [self setLoading:NO];
    
    if (confirmationView) {
        [confirmationView setLoading:NO withReason:@""];
        [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
        
        [confirmationView removeFromSuperview];
    }
    else {
        [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    }
}


#pragma mark - Actions

- (IBAction)purchaseClicked:(id)sender {
    
    [self.view endEditing:YES];
    
    // if fingerprint available - show confirmation view
    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;
    if (shouldSignOrder) {
        [self validateUser];
    }
    else {
        [self showConfirmationView];
    }
}


#pragma mark - LWExchangeConfirmationViewDelegate

- (void)checkPin:(NSString *)pin {
    if (confirmationView) {
        [confirmationView setLoading:YES withReason:Localize(@"exchange.assets.modal.validatepin")];
        [[LWAuthManager instance] requestPinSecurityGet:pin];
    }
}

- (void)noAttemptsForPin {
    [(LWAuthNavigationController *)self.navigationController logout];
}

- (void)cancelClicked {
    if (sumTextField) {
        [sumTextField becomeFirstResponder];
    }
    confirmationView = nil;
}

- (void)requestOperationWithHud:(BOOL)isHudActivated {
    [self.view endEditing:YES];
    
    if (isHudActivated) {
        [self setLoading:YES];
    }
    
    [[LWAuthManager instance] requestTransfer:self.selectedAssetId
                                       amount:[self volumeFromField]
                                    recipient:self.recepientId];
}


#pragma mark - LWTransferAssetPresenterDelegate

- (void)assetSelected:(NSString *)assetId {
    self.selectedAssetId = assetId;
    [self.tableView reloadData];
}

- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid {
    if (isValid) {
        volumeString = volume;
        [self updatePrice];
    }
    [LWValidator setButton:self.buyButton enabled:isValid];
}


#pragma mark - Utils

- (void)updateTitle {
    self.title = Localize(@"transfer.receiver.title");
    self.recepientNameLabel.text = self.recepientName;
    self.recepientImageView.image = [UIImage imageNamed:self.recepientImage];
}

- (void)updatePrice {
    if (confirmationView) {
        confirmationView.volumeString = volumeString;
    }
}

- (NSNumber *)volumeFromField {
//    NSDecimalNumber *volume = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
//    
//    double const result = volume.doubleValue;
    
    double result=volumeString.doubleValue;
    
    return [NSNumber numberWithDouble:result];
}

- (void)validateUser {
    
    [LWFingerprintHelper
     validateFingerprintTitle:Localize(@"exchange.assets.modal.fingerpring")
     ok:^(void) {
         [self requestOperationWithHud:YES];
     }
     bad:^(void) {
         [self showConfirmationView];
     }
     unavailable:^(void) {
         [self showConfirmationView];
     }];
}

- (void)showConfirmationView {
    // preparing modal view
    confirmationView = [LWTransferConfirmationView modalViewWithDelegate:self];
    confirmationView.recepientId = self.recepientId;
    confirmationView.recepientName = self.recepientName;
    confirmationView.recepientAmount = volumeString;
    confirmationView.selectedAssetId = self.selectedAssetId;
    [confirmationView setFrame:self.navigationController.view.bounds];
    
    // animation
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [confirmationView.layer addAnimation:transition forKey:nil];
    
    // showing modal view
    [self.navigationController.view addSubview:confirmationView];
    [self updatePrice];
}

@end
