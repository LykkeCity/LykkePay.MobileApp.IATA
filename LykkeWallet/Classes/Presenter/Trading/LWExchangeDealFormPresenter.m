//
//  LWExchangeDealFormPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeDealFormPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWExchangeResultPresenter.h"
#import "LWAssetBuySumTableViewCell.h"
#import "LWAssetBuyPriceTableViewCell.h"
#import "LWAssetBuyTotalTableViewCell.h"
#import "LWExchangeConfirmationView.h"
#import "LWPacketPinSecurityGet.h"
#import "LWAssetPairModel.h"
#import "LWAssetModel.h"
#import "LWAssetPairRateModel.h"
#import "LWLykkeAssetsData.h"
#import "LWLykkeWalletsData.h"
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

typedef enum {
    LastInput_Volume = 1,
    LastInput_Result = 2
} LastInputs;

@interface LWExchangeDealFormPresenter () <UITextFieldDelegate, LWExchangeConfirmationViewDelegate> {
    
    LWExchangeConfirmationView *confirmationView;
    UITextField                *sumTextField;
    UITextField                *resultTextField;
    
    BOOL      isInputValid;
    NSString *volumeString;
    NSString *resultString;
    LastInputs lastInput;
    
    NSNumber *balanceOfAccount;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton           *buyButton;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;


#pragma mark - Utils

- (void)updateTitle;
- (void)updateDescription;
- (void)updatePrice;
- (NSNumber *)volumeFromField;
- (void)validateUser;
- (void)showConfirmationView;
- (NSString *)totalString;

@end


@implementation LWExchangeDealFormPresenter

static NSInteger const kFormRows = 3;

static NSString *const FormIdentifiers[kFormRows] = {
    @"LWAssetBuySumTableViewCellIdentifier",
    @"LWAssetBuyPriceTableViewCellIdentifier",
    @"LWAssetBuyTotalTableViewCellIdentifier"
};

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.assetDealType != LWAssetDealTypeUnknown, @"Incorrect deal type!");
    
    [self updateTitle];
    [self updateDescription];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    volumeString = @"";
    resultString = @"";
    [self volumeChanged:volumeString withValidState:NO];
    
    [self registerCellWithIdentifier:@"LWAssetBuySumTableViewCellIdentifier"
                                name:@"LWAssetBuySumTableViewCell"];
    
    [self registerCellWithIdentifier:@"LWAssetBuyPriceTableViewCellIdentifier"
                                name:@"LWAssetBuyPriceTableViewCell"];
    
    [self registerCellWithIdentifier:@"LWAssetBuyTotalTableViewCellIdentifier"
                                name:@"LWAssetBuyTotalTableViewCell"];
    
    [self.buyButton setTitle:Localize(@"exchange.assets.buy.checkout")
                    forState:UIControlStateNormal];
    
    [self setBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.observeKeyboardEvents = YES;
    
    [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];

    [[LWAuthManager instance] requestLykkeWallets];

    
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
    return kFormRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = FormIdentifiers[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row == 0) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)cell;
        sumCell.titleLabel.text = Localize(@"exchange.assets.buy.sum");
        sumCell.assetLabel.text = [LWUtils baseAssetTitle:self.assetPair];

        sumTextField = sumCell.sumTextField;
        sumTextField.delegate = self;
        sumTextField.placeholder = Localize(@"exchange.assets.buy.placeholder");
        sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        NSString *baseAsset=[LWCache instance].baseAssetId;
        NSString *quoting=[self.assetPair.identity stringByReplacingOccurrencesOfString:baseAsset withString:@""];

        
        sumTextField.accuracy=[[LWCache instance] accuracyForAssetId:quoting];

        [sumTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
        [sumTextField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
    }
    else if (indexPath.row == 1) {
        LWAssetBuyPriceTableViewCell *priceCell = (LWAssetBuyPriceTableViewCell *)cell;
        priceCell.titleLabel.text = Localize(@"exchange.assets.buy.price");
    }
    else if (indexPath.row == 2) {
        LWAssetBuyTotalTableViewCell *totalCell = (LWAssetBuyTotalTableViewCell *)cell;
        totalCell.titleLabel.text = Localize(@"exchange.assets.buy.total");
        totalCell.assetLabel.text = [LWUtils quotedAssetTitle:self.assetPair];
        
        resultTextField = totalCell.totalTextField;
        resultTextField.delegate = self;
        resultTextField.placeholder = Localize(@"exchange.assets.result.placeholder");
        resultTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        resultTextField.accuracy=[[LWCache instance] accuracyForAssetId:[LWCache instance].baseAssetId];
        
        [resultTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
        [resultTextField addTarget:self
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
    if (sender == sumTextField) {
        [self volumeChanged:sender.text
             withValidState:[sender isNumberValid]];
    }
    else if (sender == resultTextField) {
        [self resultChanged:sender.text
             withValidState:[sender isNumberValid]];
    }
    if(sender.text.length==0)
    {
        resultTextField.text=@"";
        sumTextField.text=@"";
    }
    
    [self updatePrice];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didGetAssetPairRate:(LWAssetPairRateModel *)assetPairRate {
    
    self.assetRate = assetPairRate;
    
    [self updatePrice];
    
    const NSInteger repeatSeconds = [LWCache instance].refreshTimer.integerValue / 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isVisible) {
            [[LWAuthManager instance] requestAssetPairRate:self.assetPair.identity];
        }
    });
}

- (void)authManager:(LWAuthManager *)manager didReceiveDealResponse:(LWAssetDealModel *)purchase {
    
    [self setLoading:NO];
    
    if (confirmationView) {
        [confirmationView setLoading:NO withReason:@""];
        [confirmationView removeFromSuperview];
    }

    LWExchangeResultPresenter *controller = [LWExchangeResultPresenter new];
    controller.purchase = purchase;
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

-(void) authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data
{
    NSString *baseAsset=[LWCache instance].baseAssetId;
    NSString *quoting=[self.assetPair.identity stringByReplacingOccurrencesOfString:baseAsset withString:@""];

    NSString *assetId;
    
    if(self.assetDealType==LWAssetDealTypeBuy)
        assetId=baseAsset;
    else
        assetId=quoting;
    
    balanceOfAccount=@(0);
    
    
    for(LWLykkeAssetsData *d in data.lykkeData.assets)
    {
        if([d.identity isEqualToString:assetId])
        {
            balanceOfAccount=d.balance;
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
    
    NSString *baseAsset=[LWCache instance].baseAssetId;
    NSString *quoting=[self.assetPair.identity stringByReplacingOccurrencesOfString:baseAsset withString:@""];
    
    if (self.assetDealType == LWAssetDealTypeBuy) {
        [[LWAuthManager instance] requestPurchaseAsset:quoting
                                             assetPair:self.assetPair.identity
                                                volume:[self volumeFromField]
                                                  rate:self.assetRate.ask];
    }
    else {
        [[LWAuthManager instance] requestSellAsset:quoting
                                         assetPair:self.assetPair.identity
                                            volume:[self volumeFromField]
                                              rate:self.assetRate.bid];
    }
}

- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid {
    isInputValid = isValid;
    lastInput = LastInput_Volume;
    if(volume.length==0)
        volumeString=@"";
    if (isInputValid) {
        volumeString = volume;
        [self updatePrice];
    }
    else {
        self.descriptionLabel.text = @"";
    }
    
    if([self balanceIsNotEnough])
        isValid=NO;
    
    [LWValidator setButton:self.buyButton enabled:isValid];
}

- (void)resultChanged:(NSString *)input withValidState:(BOOL)isValid {
    isInputValid = isValid;
    lastInput = LastInput_Result;
    if(input.length==0)
        resultString=@"";
    if (isInputValid) {
        resultString = input;
        [self updatePrice];
    }
    else {
        self.descriptionLabel.text = @"";
    }
    
    if([self balanceIsNotEnough])
        isValid=NO;

    
    [LWValidator setButton:self.buyButton enabled:isValid];
}

-(BOOL) balanceIsNotEnough
{
    NSString *volume=[volumeString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    NSString *result=[resultString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    return ((self.assetDealType==LWAssetDealTypeSell && volume.doubleValue>balanceOfAccount.doubleValue) || (self.assetDealType==LWAssetDealTypeBuy && result.doubleValue>balanceOfAccount.doubleValue));
}


#pragma mark - Utils

- (void)updateTitle {
    NSString *operation = (self.assetDealType == LWAssetDealTypeBuy)
    ? Localize(@"exchange.assets.buy.title")
    : Localize(@"exchange.assets.sell.title");
    
    self.title = [NSString stringWithFormat:@"%@%@",
                  operation,
                  [LWUtils baseAssetTitle:self.assetPair]];
}

- (void)updateDescription {
    if (lastInput == LastInput_Volume) {
        if (!volumeString || [volumeString isEqualToString:@""]) {
            self.descriptionLabel.text = @"";
            return;
        }
    }
    else {
        if (!resultString || [resultString isEqualToString:@""]) {
            self.descriptionLabel.text = @"";
            return;
        }
    }
    
    if (!isInputValid) {
        self.descriptionLabel.text = @"";
        return;
    }
    
    // operation type
    NSString *operation = (self.assetDealType == LWAssetDealTypeBuy)
    ? Localize(@"exchange.assets.description.buy")
    : Localize(@"exchange.assets.description.sell");
    
    // build description
    NSString *volume = volumeString;
    NSString *result = resultString;
    if (lastInput == LastInput_Volume) {
        result = [self totalString];
    }
    else {
        volume = [self volumeString];
    }
    NSString *description = [NSString stringWithFormat:operation,
                             volume,
                             [LWUtils baseAssetTitle:self.assetPair],
                             result,
                             [LWUtils quotedAssetTitle:self.assetPair]];
    
    self.descriptionLabel.text = description;
}

- (void)updatePrice {
    
    if (!self.assetRate) {
        return;
    }
    
    // update price cell
    LWAssetBuyPriceTableViewCell *priceCell = (LWAssetBuyPriceTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

    NSString *priceText = nil;
    if (self.assetDealType == LWAssetDealTypeBuy) {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.ask];
    }
    else {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.bid];
    }
    priceCell.priceLabel.text = priceText;
    
    // update total cell
    NSString *volume = volumeString;
    NSString *total = resultString;
    if (lastInput == LastInput_Volume) {
        LWAssetBuyTotalTableViewCell *totalCell = (LWAssetBuyTotalTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        total = [self totalString];
        resultString=total;
        [totalCell.totalTextField setTextWithAccuracy: total];
    }
    else if (lastInput == LastInput_Result) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        volume = [self volumeString];
        volumeString=volume;
        
        [sumCell.sumTextField setTextWithAccuracy:volume];
//        sumCell.sumTextField.text = volume;
    }

    if (confirmationView) {
        confirmationView.rateString = priceText;
        confirmationView.volumeString = volume;
        confirmationView.totalString = total;
    }
    
    [self updateDescription];
}

- (NSNumber *)volumeFromField {
    NSDecimalNumber *volume = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
    
    double const result = self.assetDealType == LWAssetDealTypeBuy ? volume.doubleValue : -volume.doubleValue;
    
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
    confirmationView = [LWExchangeConfirmationView modalViewWithDelegate:self];
    confirmationView.assetPair = self.assetPair;
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

// if (invert): total = volume / price
// else: total = volume * price
- (NSString *)totalString {
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSDecimalNumber *decimalPrice = nil;
    if (self.assetDealType == LWAssetDealTypeBuy) {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.ask decimalValue]];
    }
    else {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.bid decimalValue]];
    }
    NSDecimalNumber *volume = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
    
    NSDecimalNumber *result = [NSDecimalNumber zero];
    if ([baseAssetId isEqualToString:self.assetPair.baseAssetId]) {
        if (![LWMath isDecimalEqualToZero:decimalPrice]) {
            result = [volume decimalNumberByDividingBy:decimalPrice];
        }
    }
    else {
        result = [volume decimalNumberByMultiplyingBy:decimalPrice];
    }
    
    NSInteger const accuracy = self.assetPair.accuracy.integerValue;
    NSNumber *number = [NSNumber numberWithDouble:result.doubleValue];
    NSString *totalText = [LWMath historyPriceString:number
                                           precision:accuracy
                                          withPrefix:@""];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *groupSymbol = [formatter groupingSeparator];
    totalText = [totalText stringByReplacingOccurrencesOfString:groupSymbol withString:@""];
    return totalText;
}

// if (invert): volume = total * price
// else: volume = total / price
- (NSString *)volumeString {
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSDecimalNumber *decimalPrice = nil;
    if (self.assetDealType == LWAssetDealTypeBuy) {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.ask decimalValue]];
    }
    else {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.bid decimalValue]];
    }
    
    NSDecimalNumber *total = [resultString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:resultString];
    
    NSDecimalNumber *volume = [NSDecimalNumber zero];
    if ([baseAssetId isEqualToString:self.assetPair.baseAssetId]) {
        volume = [total decimalNumberByMultiplyingBy:decimalPrice];
    }
    else {
        if (![LWMath isDecimalEqualToZero:decimalPrice]) {
            volume = [total decimalNumberByDividingBy:decimalPrice];
        }
    }
    
    NSInteger const accuracy = self.assetPair.accuracy.integerValue;
    NSNumber *number = [NSNumber numberWithDouble:volume.doubleValue];
    NSString *volumeText = [LWMath historyPriceString:number
                                           precision:accuracy
                                          withPrefix:@""];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *groupSymbol = [formatter groupingSeparator];
    volumeText = [volumeText stringByReplacingOccurrencesOfString:groupSymbol withString:@""];
    
    return volumeText;
}

@end
