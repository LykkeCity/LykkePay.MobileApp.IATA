//
//  LWWithdrawInputPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawInputPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWWithdrawConfirmationView.h"
#import "LWFingerprintHelper.h"
#import "LWAssetPairModel.h"
#import "LWAssetBuySumTableViewCell.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWCache.h"
#import "LWUtils.h"
#import "LWMath.h"
#import "TKButton.h"
#import "UITextField+Validation.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "NSString+Utils.h"


@interface LWWithdrawInputPresenter () <UITextFieldDelegate, LWWithdrawConfirmationViewDelegate> {
    
    LWWithdrawConfirmationView *confirmationView;
    UITextField *sumTextField;
    NSString    *volumeString;
}

@property (weak, nonatomic) IBOutlet TKButton *operationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


#pragma mark - Utils

- (void)validateUser;
- (void)showConfirmationView;

@end


@implementation LWWithdrawInputPresenter


static NSInteger const kFormRows = 1;

static NSString *const FormIdentifiers[kFormRows] = {
    @"LWAssetBuySumTableViewCellIdentifier"
};

float const kMathHeightKeyboard = 239.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = Localize(@"withdraw.funds.title");
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    volumeString = @"";
    [self volumeChanged:volumeString withValidState:NO];
    
    [self registerCellWithIdentifier:@"LWAssetBuySumTableViewCellIdentifier"
                                name:@"LWAssetBuySumTableViewCell"];

    [self.operationButton setTitle:Localize(@"withdraw.funds.proceed")
                          forState:UIControlStateNormal];
    
    [self setBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.observeKeyboardEvents = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (sumTextField) {
        [sumTextField becomeFirstResponder];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kFormRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = FormIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row == 0) {
        LWAssetPairModel *assetPair = [LWAssetPairModel assetPairById:self.assetPairId];
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)cell;
        sumCell.titleLabel.text = Localize(@"withdraw.funds.amount");
        sumCell.assetLabel.text = [LWUtils baseAssetTitle:assetPair];
        
        sumTextField = sumCell.sumTextField;
        sumTextField.delegate = self;
        sumTextField.placeholder = Localize(@"withdraw.funds.placeholder");
        sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
        sumTextField.accuracy=[[LWCache instance] accuracyForAssetId:self.assetId];
        
        [sumTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
        [sumTextField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [textField isNumberValidForRange:range replacementString:string];
}

- (void)textFieldDidChange:(UITextField *)sender {
    [self volumeChanged:sender.text withValidState:[sender isNumberValid]];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidCashOut:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    if (confirmationView) {
        [confirmationView setLoading:NO withReason:@""];
        [confirmationView removeFromSuperview];
    }
    
    UIAlertController *ctrl = [UIAlertController alertControllerWithTitle:Localize(@"withdraw.funds.confirm.title") message:Localize(@"withdraw.funds.confirm.desc")
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:Localize(@"withdraw.funds.confirm.ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ctrl dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
    [ctrl addAction:actionOK];
    [self presentViewController:ctrl animated:YES completion:nil];
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
        [confirmationView removeFromSuperview];
    }
    
    [self showReject:reject response:context.task.response
                code:context.error.code willNotify:YES];
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


#pragma mark - LWWithdrawConfirmationViewDelegate

- (void)checkPin:(NSString *)pin {
    if (confirmationView) {
        [confirmationView setLoading:YES withReason:Localize(@"withdraw.funds.validatepin")];
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
    
    NSDecimalNumber *decimalAmount = [LWMath numberWithString:volumeString];
    NSNumber *amount = [NSNumber numberWithDouble:decimalAmount.doubleValue];
    [[LWAuthManager instance] requestCashOut:amount
                                     assetId:self.assetId
                                    multiSig:self.bitcoinString];
}

- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid {
    if (isValid) {
        volumeString = volume;
    }
    
    [LWValidator setButton:self.operationButton enabled:isValid];
}

- (void)validateUser {
    
    [LWFingerprintHelper
     validateFingerprintTitle:Localize(@"withdraw.funds.modal.fingerpring")
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
    confirmationView = [LWWithdrawConfirmationView modalViewWithDelegate:self];
    
    NSDecimalNumber *amount = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
    NSString *amountText = [LWMath makeStringByDecimal:amount withPrecision:2];
    
    confirmationView.bitcoinString = self.bitcoinString;
    confirmationView.amountString = amountText;
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
}

@end
