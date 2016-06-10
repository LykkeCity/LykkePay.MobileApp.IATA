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
#import "LWLykkeWalletsData.h"
#import "LWLykkeAssetsData.h"
#import "LWMathKeyboardView.h"

typedef enum {
    LastInput_Volume = 1,
    LastInput_Result = 2
} LastInputs;

@interface LWExchangeDealFormPresenter () <UITextFieldDelegate, LWExchangeConfirmationViewDelegate, LWMathKeyboardViewDelegate> {
    
    LWExchangeConfirmationView *confirmationView;
    UITextField                *sumTextField;
    UITextField                *resultTextField;
    
    BOOL      isInputValid;
    NSString *volumeString;
    NSString *resultString;
    LastInputs lastInput;
    
    UILabel *balance;
    
    NSArray *predefinedSums;
    UIView *predefinedSumsView;
    NSNumber *balanceOfAccount;
    NSString *balanceCurrencySymbol;
    int balanceAccuracy;
    
    
    LWAssetPairRateModel *rateToSend;
    NSNumber *volumeToSend;
    NSString *volumeStringToSend;
    NSString *resultStringToSend;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton           *buyButton;
@property (weak, nonatomic) IBOutlet UILabel            *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *buyButtonContainer;


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

static NSInteger const kFormRows = 4;

static NSString *const FormIdentifiers[kFormRows] = {
    @"LWAssetBuySumTableViewCellIdentifier",
    @"LWAssetBuyPriceTableViewCellIdentifier",
    @"LWAssetBuyTotalTableViewCellIdentifier"
};

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollEnabled=NO;
    
    NSAssert(self.assetDealType != LWAssetDealTypeUnknown, @"Incorrect deal type!");
    
//    [self updateTitle];
    [self updateDescription];
    
    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
    
    volumeString = @"";
    resultString = @"";
    
    [LWValidator setButton:self.buyButton enabled:NO];
    
//    [self volumeChanged:volumeString withValidState:NO];
    
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
    
    [self updateTitle];
//    predefinedSumsView=[self predefinedSumsEnterView];
//    [self.view addSubview:predefinedSumsView];
//    
//    predefinedSumsView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+predefinedSumsView.bounds.size.height/2);
    if (sumTextField) {
        [sumTextField becomeFirstResponder];
    }

}






#pragma mark - TKPresenter

//- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
//    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    
//    [self.bottomConstraint setConstant:frame.size.height+predefinedSumsView.bounds.size.height];
//    
//    predefinedSumsView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-frame.size.height-predefinedSumsView.bounds.size.height/2);
//
//    
//    [self animateConstraintChanges];
//}
//
//- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
//    [self.bottomConstraint setConstant:0];
//    predefinedSumsView.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+predefinedSumsView.bounds.size.height/2);
//    [self animateConstraintChanges];
//}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kFormRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor=[UIColor whiteColor];
        balance=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 15)];
        balance.text=@"";
        if(balanceOfAccount)
        {
            NSString *str=[NSString stringWithFormat:@"%f",balanceOfAccount.floatValue];
            balance.text=[NSString stringWithFormat:@"%@ available", [LWUtils formatVolumeString:str currencySign:balanceCurrencySymbol accuracy:balanceAccuracy removeExtraZeroes:YES]];

        }
        balance.font=[UIFont systemFontOfSize:14];
        balance.textColor=[UIColor blackColor];
        balance.textAlignment=NSTextAlignmentCenter;
        balance.center=CGPointMake(self.tableView.bounds.size.width/2, balance.center.y);
        [cell addSubview:balance];
        return cell;
        
    }
    
    
    NSString *identifier = FormIdentifiers[indexPath.row-1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row == 1) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)cell;
        sumCell.titleLabel.text = Localize(@"exchange.assets.buy.sum");
        sumCell.assetLabel.text = [LWUtils baseAssetTitle:self.assetPair];

        sumTextField = sumCell.sumTextField;
        sumTextField.delegate = self;
        sumTextField.placeholder = Localize(@"exchange.assets.buy.placeholder");
        sumTextField.keyboardType = UIKeyboardTypeDecimalPad;

        [sumTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
//        [sumTextField addTarget:self
//                         action:@selector(textFieldDidChange:)
//               forControlEvents:UIControlEventEditingChanged];
    }
    else if (indexPath.row == 2) {
        LWAssetBuyPriceTableViewCell *priceCell = (LWAssetBuyPriceTableViewCell *)cell;
        priceCell.titleLabel.text = Localize(@"exchange.assets.buy.price");
    }
    else if (indexPath.row == 3) {
        LWAssetBuyTotalTableViewCell *totalCell = (LWAssetBuyTotalTableViewCell *)cell;
        totalCell.titleLabel.text = Localize(@"exchange.assets.buy.total");
        totalCell.assetLabel.text = [LWUtils quotedAssetTitle:self.assetPair];
        
        resultTextField = totalCell.totalTextField;
        resultTextField.delegate = self;
        resultTextField.placeholder = Localize(@"exchange.assets.result.placeholder");
        resultTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        [resultTextField setTintColor:[UIColor colorWithHexString:kDefaultTextFieldPlaceholder]];
//        [resultTextField addTarget:self
//                         action:@selector(textFieldDidChange:)
//               forControlEvents:UIControlEventEditingChanged];
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
    
    
    self.buyButtonContainer.translatesAutoresizingMaskIntoConstraints=YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.buyButtonContainer.center=CGPointMake(self.buyButtonContainer.center.x, self.buyButtonContainer.center.y-self.keyboardView.bounds.size.height);
    }];
}


-(void) hideCustomKeyboard
{
    [super hideCustomKeyboard];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.buyButtonContainer.center=CGPointMake(self.buyButtonContainer.center.x, self.buyButtonContainer.center.y+self.keyboardView.bounds.size.height);

    } completion:^(BOOL finished){
        self.buyButtonContainer.translatesAutoresizingMaskIntoConstraints=NO;
    }];
    
}

- (void)mathKeyboardView:(LWMathKeyboardView *) view volumeStringChangedTo:(NSString *) string
{
    if(view.targetTextField==sumTextField)
    {
        volumeString=string;
//        sumTextField.text=string;//[LWUtils formatVolumeString:string currencySign:@"" accuracy:balanceAccuracy];
        lastInput=LastInput_Volume;
    }
    else
    {
        resultString=string;
//        resultTextField.text=string;//[LWUtils formatVolumeString:string currencySign:@"" accuracy:balanceAccuracy];
        lastInput=LastInput_Result;
    }
    
    isInputValid=string.floatValue!=0;
    [self updatePrice];
}





#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!self.keyboardView || (self.keyboardView && self.keyboardView.isVisible==NO))
        [self showCustomKeyboard];
    
    self.keyboardView.targetTextField=textField;
    
    
    if(textField==sumTextField)
    {
        self.keyboardView.accuracy=[self accuracyForBaseAsset];
       [self.keyboardView setText:[sumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    else if(textField==resultTextField)
    {
        self.keyboardView.accuracy=[self accuracyForQuotingAsset];
        [self.keyboardView setText:[resultTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    
    return NO;
}


//- (void)textFieldDidChange:(UITextField *)sender {
//    if (sender == sumTextField) {
//        [self volumeChanged:sender.text
//             withValidState:[sender isNumberValid]];
//    }
//    else if (sender == resultTextField) {
//        [self resultChanged:sender.text
//             withValidState:[sender isNumberValid]];
//    }
//    [self updatePrice];
//}


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

-(void) authManager:(LWAuthManager *)manager didReceiveLykkeData:(LWLykkeWalletsData *)data
{
    
//    NSString *baseAssetID=[LWCache instance].baseAssetId;
    
//    NSString *balanceAsset=self.assetPair.baseAssetId;
//    if([baseAssetID isEqualToString:balanceAsset] && self.assetDealType==LWAssetDealTypeSell)
//        balanceAsset=self.assetPair.baseAssetId;
//    else if(self.assetDealType==LWAssetDealTypeBuy)
//        balanceAsset=self.assetPair.quotingAssetId;
    
        NSString *balanceAsset;
        if(self.assetDealType==LWAssetDealTypeSell)
            balanceAsset=self.assetPair.baseAssetId;
        else if(self.assetDealType==LWAssetDealTypeBuy)
            balanceAsset=self.assetPair.quotingAssetId;


    
    balanceOfAccount=@(0);
    
    balanceAccuracy=2;
    for(LWLykkeAssetsData *d in data.lykkeData.assets)
    {
        if([d.identity isEqualToString:balanceAsset])
        {
            balanceOfAccount=d.balance;
            balanceAccuracy=d.accuracy.intValue;
            balanceCurrencySymbol=d.symbol;
        }
    }
    
//    balanceOfAccount=@(10.2);//Testing
    
    NSString *str=[NSString stringWithFormat:@"%f",balanceOfAccount.floatValue];
    balance.text=[NSString stringWithFormat:@"%@ available", [LWUtils formatVolumeString:str currencySign:balanceCurrencySymbol accuracy:balanceAccuracy removeExtraZeroes:YES]];


}

- (void)authManager:(LWAuthManager *)manager didReceiveDealResponse:(LWAssetDealModel *)purchase {
    
    [self setLoading:NO];
    
    if (confirmationView) {
        [confirmationView setLoading:NO withReason:@""];
        [confirmationView removeFromSuperview];
    }

    LWExchangeResultPresenter *controller = [LWExchangeResultPresenter new];
    controller.purchase = purchase;
    controller.assetPair=self.assetPair;
    
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
}


#pragma mark - Actions

- (IBAction)purchaseClicked:(id)sender {
    
    [self.view endEditing:YES];
    
    rateToSend=self.assetRate;
    volumeToSend=[self volumeFromField];
    resultStringToSend=resultString;
    volumeStringToSend=volumeString;
    
    
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
    
    NSString *baseAssetId=[LWCache instance].baseAssetId;
    
    baseAssetId=self.assetPair.baseAssetId;
    
    if (self.assetDealType == LWAssetDealTypeBuy) {
        
        NSString *rate=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%.10f", rateToSend.ask.floatValue] currencySign:@"" accuracy:self.assetPair.accuracy.intValue removeExtraZeroes:YES];
        
        [[LWAuthManager instance] requestPurchaseAsset: baseAssetId
                                             assetPair:self.assetPair.identity
                                                volume:volumeToSend
                                                  rate:rate];
    }
    else {
        
        NSString *rate=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%.10f", rateToSend.bid.floatValue] currencySign:@"" accuracy:self.assetPair.accuracy.intValue removeExtraZeroes:YES];

        [[LWAuthManager instance] requestSellAsset:baseAssetId
                                         assetPair:self.assetPair.identity
                                            volume:volumeToSend
                                              rate:rate];
    }
}

//- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid {
//    isInputValid = isValid;
//    lastInput = LastInput_Volume;
//    if (isInputValid) {
//        volumeString = volume;
//        [self updatePrice];
//    }
//    else {
//        self.descriptionLabel.text = @"";
//    }
//    
//    [LWValidator setButton:self.buyButton enabled:isValid];
//    if(isInputValid)
//        [self updatePrice];
//}
//
//- (void)resultChanged:(NSString *)input withValidState:(BOOL)isValid {
//    isInputValid = isValid;
//    lastInput = LastInput_Result;
//    if (isInputValid) {
//        resultString = input;
//        [self updatePrice];
//    }
//    else {
//        self.descriptionLabel.text = @"";
//    }
//    
//
//    [LWValidator setButton:self.buyButton enabled:isValid];
//    if(isInputValid)
//        [self updatePrice];
//
//}


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
        if (!volumeString || [volumeString isEqualToString:@""] || volumeString.floatValue==0) {
            self.descriptionLabel.text = @"";
            return;
        }
    }
    else {
        if (!resultString || [resultString isEqualToString:@""] || resultString.floatValue==0) {
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
    NSString *volume = [LWUtils formatVolumeString:volumeString currencySign:@"" accuracy:[self accuracyForBaseAsset].intValue removeExtraZeroes:YES];
    NSString *result = [LWUtils formatVolumeString:resultString currencySign:@"" accuracy:[self accuracyForQuotingAsset].intValue removeExtraZeroes:YES];
    if([volume isEqualToString:@"0"] || [result isEqualToString:@"0"])
    {
        self.descriptionLabel.text=@"";
        return;
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
    LWAssetBuyPriceTableViewCell *priceCell = (LWAssetBuyPriceTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    NSString *priceText = nil;
    if (self.assetDealType == LWAssetDealTypeBuy) {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.ask];
    }
    else {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.bid];
    }
    
    priceText=[priceText stringByReplacingOccurrencesOfString:@"," withString:@"."];
    priceCell.priceLabel.text = priceText;
    
    // update total cell
    NSString *volume = volumeString;
    NSString *total = resultString;
    if (lastInput == LastInput_Volume) {
        LWAssetBuyTotalTableViewCell *totalCell = (LWAssetBuyTotalTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        total = [self totalString];
        totalCell.totalTextField.text = total;
        sumTextField.text=[LWUtils formatVolumeString:volume currencySign:@"" accuracy:[self accuracyForQuotingAsset].intValue removeExtraZeroes:NO];
    }
    else if (lastInput == LastInput_Result) {
        LWAssetBuySumTableViewCell *sumCell = (LWAssetBuySumTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        volume = [self volumeString];
        sumCell.sumTextField.text = volume;
        
        LWAssetBuyTotalTableViewCell *totalCell = (LWAssetBuyTotalTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        totalCell.totalTextField.text=[LWUtils formatVolumeString:total currencySign:@"" accuracy:[self accuracyForBaseAsset].intValue removeExtraZeroes:NO];
    }
    
    volumeString=[volume stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultString=[total stringByReplacingOccurrencesOfString:@" " withString:@""];


//    if (confirmationView) {
//        confirmationView.rateString = priceText;
//        confirmationView.volumeString = volumeString;
//        confirmationView.totalString = resultString;
//    }
    if(self.assetDealType==LWAssetDealTypeBuy)
    {
        if(resultString.floatValue>balanceOfAccount.floatValue || (resultString.floatValue==0 || volumeString.floatValue==0))
            [LWValidator setButton:self.buyButton enabled:NO];
        else if(volumeString.floatValue>0)
            [LWValidator setButton:self.buyButton enabled:YES];
    }
    else
    {
        if(volumeString.floatValue>balanceOfAccount.floatValue || (resultString.floatValue==0 || volumeString.floatValue==0))
            [LWValidator setButton:self.buyButton enabled:NO];
        else if(volumeString.floatValue>0)
            [LWValidator setButton:self.buyButton enabled:YES];

    }
    
    [self updateDescription];
}

- (NSNumber *)volumeFromField {
//    NSDecimalNumber *volume = [volumeString isEmpty] ? [NSDecimalNumber zero] : [LWMath numberWithString:volumeString];
    
    
    double volume=volumeString.doubleValue;
    
    double const result = self.assetDealType == LWAssetDealTypeBuy ? volume : -volume;
    
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
    NSString *priceText;
    
//    if (self.assetDealType == LWAssetDealTypeBuy) {
//        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.ask];
//    }
//    else {
//        priceText = [LWUtils priceForAsset:self.assetPair forValue:self.assetRate.bid];
//    }

    if (self.assetDealType == LWAssetDealTypeBuy) {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:rateToSend.ask];
    }
    else {
        priceText = [LWUtils priceForAsset:self.assetPair forValue:rateToSend.bid];
    }

    
    priceText=[priceText stringByReplacingOccurrencesOfString:@"," withString:@"."];

    confirmationView.rateString = priceText;
    confirmationView.volumeString = volumeStringToSend;
    confirmationView.totalString = resultStringToSend;

}

// if (invert): total = volume / price
// else: total = volume * price
- (NSString *)totalString {

//    return [LWUtils formatVolumeString:[NSString stringWithFormat:@"%f", volumeString.floatValue*] currencySign:<#(NSString *)#> accuracy:<#(int)#>]
    
    NSString *baseAssetId = [LWCache instance].baseAssetId;
    NSDecimalNumber *decimalPrice = nil;
    if (self.assetDealType == LWAssetDealTypeBuy) {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.ask decimalValue]];
    }
    else {
        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.bid decimalValue]];
    }
    
    float price=decimalPrice.floatValue;
    float result=0;
    
    
//    if ([baseAssetId isEqualToString:self.assetPair.baseAssetId] && price!=0) {
//        
//        result=volumeString.floatValue/price;
//    }
//    else {
//        result=volumeString.floatValue*price;
//    }
    
    result=volumeString.floatValue*price;
    
    NSString *vvv=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%.20f", result] currencySign:@"" accuracy:[self accuracyForQuotingAsset].intValue removeExtraZeroes:YES];
    if([vvv isEqualToString:@"0"])
        vvv=@"";
    return vvv;
    

}

// if (invert): volume = total * price
// else: volume = total / price
- (NSString *)volumeString {

    NSString *baseAssetId = [LWCache instance].baseAssetId;
//    NSDecimalNumber *decimalPrice = nil;
    
    float price;
    if (self.assetDealType == LWAssetDealTypeBuy) {
//        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.ask decimalValue]];
        price=self.assetRate.ask.floatValue;
    }
    else {
//        decimalPrice = [NSDecimalNumber decimalNumberWithDecimal:[self.assetRate.bid decimalValue]];
        price=self.assetRate.bid.floatValue;
    }
    
//    float price=decimalPrice.floatValue;
    float volume=0;
    
//    if ([baseAssetId isEqualToString:self.assetPair.baseAssetId]) {
//        volume = resultString.floatValue*price;
//    }
//    else {
//        if (price!=0) {
//            volume = resultString.floatValue/price;
//        }
//    }
    
    if(price!=0)
        volume=resultString.floatValue/price;
    else
        volumeString=0;

    
    
    NSString *rrr=[LWUtils formatVolumeString:[NSString stringWithFormat:@"%.20f", volume] currencySign:@"" accuracy:[self accuracyForBaseAsset].intValue removeExtraZeroes:YES];
    if([rrr isEqualToString:@"0"])
        rrr=@"";
    return rrr;


}

-(NSNumber *) accuracyForBaseAsset
{
    NSArray *assets=[LWCache instance].baseAssets;
    
//    NSString *identity=[LWCache instance].baseAssetId;
    NSString *identity=self.assetPair.baseAssetId;
    NSNumber *accuracy=@(0);
    for(LWAssetModel *m in assets)
    {
        if([m.identity isEqualToString:identity])
        {
            accuracy=m.accuracy;
            break;
        }
    }
    
    return accuracy;
}

-(NSNumber *) accuracyForQuotingAsset
{
    NSArray *assets=[LWCache instance].baseAssets;
//    NSString *identity=[LWCache instance].baseAssetId;
//    if([self.assetPair.baseAssetId isEqualToString:identity]==NO)
//    {
//        identity=self.assetPair.baseAssetId;
//    }
    
    NSString *identity=self.assetPair.quotingAssetId;
    NSNumber *accuracy=@(0);
    for(LWAssetModel *m in assets)
    {
        if([m.identity isEqualToString:identity])
        {
            accuracy=m.accuracy;
            break;
        }
    }
    
    return accuracy;

}

@end
