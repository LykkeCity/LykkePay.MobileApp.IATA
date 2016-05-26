//
//  LWWithdrawFundsPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 30.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawFundsPresenter.h"
#import "LWWithdrawInputPresenter.h"
#import "LWQrCodeScannerPresenter.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWConstants.h"
#import "TKContainer.h"
#import "TKButton.h"


@interface LWWithdrawFundsPresenter () <LWTextFieldDelegate, AMScanViewControllerDelegate> {
    LWTextField *bitcoinTextField;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet TKContainer *qrCodeContainer;
@property (weak, nonatomic) IBOutlet UILabel     *qrCodeLabel;
@property (weak, nonatomic) IBOutlet TKButton    *proceedButton;
@property (weak, nonatomic) IBOutlet UILabel     *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton    *pasteButton;


#pragma mark - Utils

- (BOOL)canProceed;
- (void)updatePasteButtonStatus;

@end


@implementation LWWithdrawFundsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"withdraw.funds.title");
    
    
    // init email field
    bitcoinTextField = [LWTextField new];
    bitcoinTextField.delegate = self;
    bitcoinTextField.keyboardType = UIKeyboardTypeEmailAddress;
#ifdef PROJECT_IATA
    bitcoinTextField.placeholder = Localize(@"withdraw.funds.wallet.iata");
#else
    bitcoinTextField.placeholder = Localize(@"withdraw.funds.wallet");
#endif
    bitcoinTextField.viewMode = UITextFieldViewModeNever;
    [self.qrCodeContainer attach:bitcoinTextField];

    [self.qrCodeContainer bringSubviewToFront:self.pasteButton];
    
#ifdef PROJECT_IATA
#else
    [self.proceedButton setGrayPalette];
#endif
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanClicked:)];
    [self.qrCodeLabel setUserInteractionEnabled:YES];
    [self.qrCodeLabel addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updatePasteButtonStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (bitcoinTextField) {
        [bitcoinTextField becomeFirstResponder];
    }
}

- (void)localize {
    self.infoLabel.text = Localize(@"withdraw.funds.info");
    self.qrCodeLabel.text = Localize(@"withdraw.funds.scan");
#ifdef PROJECT_IATA
    self.titleLabel.text = Localize(@"withdraw.funds.address.iata");
#else
    self.titleLabel.text = Localize(@"withdraw.funds.address");
#endif
    
    [self.proceedButton setTitle:Localize(@"withdraw.funds.proceed")
                        forState:UIControlStateNormal];
    
    [self.pasteButton setTitle:Localize(@"withdraw.funds.paste")
                      forState:UIControlStateNormal];
}

- (void)colorize {
    UIColor *color = [UIColor colorWithHexString:kMainElementsColor];
    [self.qrCodeLabel setTextColor:color];
}

#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textField {
    // prevent from being processed if controller is not presented
    if (!self.isVisible) {
        return;
    }

    [self updatePasteButtonStatus];
}


#pragma mark - Outlets

- (IBAction)proceedClicked:(id)sender {
    LWWithdrawInputPresenter *presenter = [LWWithdrawInputPresenter new];
    presenter.assetId = self.assetId;
    presenter.bitcoinString = bitcoinTextField.text;
    [self.navigationController pushViewController:presenter animated:YES];
}

- (IBAction)pasteClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    bitcoinTextField.text = [pasteboard string];
    
    [self updatePasteButtonStatus];
}

- (void)scanClicked:(id)sender {
    LWQrCodeScannerPresenter *presenter = [LWQrCodeScannerPresenter new];
    presenter.delegate = self;
    [self.navigationController pushViewController:presenter animated:YES];
}


#pragma mark - test

- (void)scanViewController:(LWQrCodeScannerPresenter *)controller didSuccessfullyScan:(NSString *)scannedValue {
    [self.navigationController popToViewController:self animated:NO];
    
    bitcoinTextField.text = scannedValue;
    [self updatePasteButtonStatus];
}


#pragma mark - Utils

- (BOOL)canProceed {
    BOOL canProceed = bitcoinTextField.text.length > 0;
    return canProceed;
}

- (void)updatePasteButtonStatus {
    // check button state
    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
    self.pasteButton.hidden = [self canProceed];
}

@end
