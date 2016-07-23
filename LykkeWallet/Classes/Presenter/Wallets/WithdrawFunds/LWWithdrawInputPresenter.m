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
#import "LWAssetBuySumTableViewCell.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWCache.h"
#import "LWMath.h"
#import "TKButton.h"
#import "UITextField+Validation.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "NSString+Utils.h"
#import "LWWithdrawCurrencyPresenter.h"
#import "LWLykkeAssetsData.h"
#import "LWLykkeWalletsData.h"
#import "LWMathKeyboardView.h"
#import "LWUtils.h"




@interface LWWithdrawInputPresenter () <UITextFieldDelegate, LWWithdrawConfirmationViewDelegate, LWMathKeyboardViewDelegate> {
    
    LWWithdrawConfirmationView *confirmationView;
    UITextField *sumTextField;
    NSString    *volumeString;
//    NSArray *predefinedSums;
//    UIView *predefinedSumsView;
    
    UILabel *balance;
    
    NSNumber *accountBalance;
    
//    LWMathKeyboardView *keyboardView;
    int accuracy;
    
}

@property (weak, nonatomic) IBOutlet TKButton *operationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *operationView;

#pragma mark - Utils

- (void)validateUser;
- (void)showConfirmationView;

@end


@implementation LWWithdrawInputPresenter


static NSInteger const kFormRows = 2;

static NSString *const FormIdentifiers[kFormRows] = {
    @"LWAssetBuySumTableViewCellIdentifier"
};

float const kMathHeightKeyboard = 239.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled=NO;
    
    accuracy=-1;
    
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
    self.title = Localize(@"withdraw.funds.title");

    if (sumTextField) {
        [sumTextField becomeFirstResponder];
    }
    
    [[LWAuthManager instance] requestLykkeWallets];

}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kFormRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor=[UIColor whiteColor];
        balance=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 15)];
        balance.text=@"";
        balance.font=[UIFont fontWithName:@"ProximaNova-Regular" size:16];
        balance.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        balance.textAlignment=NSTextAlignmentCenter;
        balance.center=CGPointMake(self.tableView.bounds.size.width/2, balance.center.y);
        [cell addSubview:balance];
        return cell;
        
    }

    NSString *identifier = FormIdentifiers[indexPath.row-1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row == 1) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)cell;
        sumCell.titleLabel.text = Localize(@"withdraw.funds.amount");
        sumCell.assetLabel.text=self.assetId;
        sumTextField = sumCell.sumTextField;
        sumTextField.delegate = self;
        sumTextField.placeholder = Localize(@"withdraw.funds.placeholder");
        sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        [sumTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
        
    }
    
    return cell;
}

-(void) mathKeyboardDonePressed:(LWMathKeyboardView *)keyboardView
{
    [self hideCustomKeyboard];
}



-(void) showCustomKeyboard
{
    [super showCustomKeyboard];
    self.keyboardView.targetTextField=sumTextField;
    
    [self.keyboardView setAccuracy:[LWUtils accuracyForAssetId:self.assetId]];
    
    [self.keyboardView setText:volumeString];
    
    self.operationView.translatesAutoresizingMaskIntoConstraints = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.operationView.center=CGPointMake(self.operationView.center.x, self.operationView.center.y-self.keyboardView.bounds.size.height);
    }];
}


-(void) hideCustomKeyboard
{
    [super hideCustomKeyboard];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.operationView.center=CGPointMake(self.operationView.center.x, self.operationView.center.y+self.keyboardView.bounds.size.height);
    } completion:^(BOOL finished){
        self.operationView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }];
    
}


#pragma mark - UITextFieldDelegate


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!self.keyboardView || (self.keyboardView && self.keyboardView.isVisible==NO))
        [self showCustomKeyboard];

    return NO;
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

-(void) authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data
{
    NSString *balanceAsset=self.assetId;
    
    NSString *symbol;
    
    for(LWLykkeAssetsData *d in data.lykkeData.assets)
    {
        if([d.identity isEqualToString:balanceAsset])
        {
            accountBalance=d.balance;
            accuracy=d.accuracy.intValue;
            symbol=d.symbol;
        }
    }
    
    
    balance.text=[NSString stringWithFormat:@"%@ available", [LWUtils formatVolumeNumber:accountBalance currencySign:symbol accuracy:accuracy removeExtraZeroes:YES]];
    
}



#pragma mark - TKPresenter

//- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
//    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    [self.bottomConstraint setConstant:frame.size.height+predefinedSumsView.bounds.size.height];
//
//    predefinedSumsView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-frame.size.height-predefinedSumsView.bounds.size.height/2);
//    [self animateConstraintChanges];
//}
//
//- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
//    [self.bottomConstraint setConstant:0];
//    predefinedSumsView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+predefinedSumsView.bounds.size.height/2);
//
//    [self animateConstraintChanges];
//}


#pragma mark - Actions

- (IBAction)purchaseClicked:(id)sender {
    
    [self.view endEditing:YES];
    
    if(!self.bitcoinString)
    {
        LWWithdrawCurrencyPresenter *presenter=[LWWithdrawCurrencyPresenter new];
        presenter.assetID=self.assetId;
        presenter.amount=@([sumTextField.text floatValue]);
        [self.navigationController pushViewController:presenter animated:YES];
        return;
    }
    
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
    
    
    NSNumber *amount=[NSNumber numberWithDouble:sumTextField.text.doubleValue];
    
    
    [[LWAuthManager instance] requestCashOut:amount
                                     assetId:self.assetId
                                    multiSig:self.bitcoinString];
}

- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid {
    if (isValid) {
        volumeString = volume;
    }
    if(volume.floatValue<=accountBalance.floatValue && isValid)
        isValid=YES;
    else
        isValid=NO;
    
    sumTextField.text=volume;
    [LWValidator setButton:self.operationButton enabled:isValid];
}

-(void) mathKeyboardView:(LWMathKeyboardView *)view volumeStringChangedTo:(NSString *)volume
{
    BOOL valid=YES;
    if([volume rangeOfString:@"-"].location!=NSNotFound)
        valid=NO;
    if(volume.floatValue==0)
        valid=NO;
    
    volumeString=volume;
    
    
    [self volumeChanged:volume withValidState:valid];
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
    
//    NSDecimalNumber *amount = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
//    NSString *amountText = [LWMath makeStringByDecimal:amount withPrecision:2];
    
//    NSNumber *amount=@(volumeString.floatValue);
    NSString *volume=[volumeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *amountText=[LWUtils formatVolumeNumber:@(volume.floatValue) currencySign:@"" accuracy:accuracy removeExtraZeroes:YES];
    
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
