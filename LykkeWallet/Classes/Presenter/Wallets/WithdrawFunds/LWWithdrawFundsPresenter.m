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
#import "LWPacketBitcoinAddressValidation.h"
#import "ZBarReaderViewController.h"
#import "LWProgressView.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"

#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"



@interface LWWithdrawFundsPresenter () <LWTextFieldDelegate, AMScanViewControllerDelegate, ZBarReaderDelegate> {
    LWTextField *bitcoinTextField;
    
    LWProgressView *progressValidation;
    int validationRequests;
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
    
    [self setBackButton];
    validationRequests=0;

    
    // init email field
    bitcoinTextField = [LWTextField new];
    bitcoinTextField.delegate = self;
    bitcoinTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [bitcoinTextField setRightOffset:70];

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
    
    progressValidation=[[LWProgressView alloc] init];
    [self.proceedButton addSubview:progressValidation];
    progressValidation.center=CGPointMake(self.proceedButton.bounds.size.width-40, self.proceedButton.bounds.size.height/2);
    

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
    self.title = Localize(@"withdraw.funds.title");
    
    

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
//    LWQrCodeScannerPresenter *presenter = [LWQrCodeScannerPresenter new];
//    presenter.delegate = self;
//    [self.navigationController pushViewController:presenter animated:YES];
    
    
    
#if TARGET_IPHONE_SIMULATOR
    // Simulator
#else
    
    void (^block)(void)=^{
        
        ZBarReaderViewController *codeReader = [ZBarReaderViewController new];
        codeReader.readerDelegate=self;
        codeReader.supportedOrientationsMask = ZBarOrientationMaskAll;
        codeReader.showsZBarControls=NO;
        codeReader.showsHelpOnFail=NO;
        codeReader.tracksSymbols=YES;
        
        ZBarImageScanner *scanner = codeReader.scanner;
        [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
        
        [self.navigationController pushViewController:codeReader animated:YES];
        
        [codeReader setTitle:@"SCAN QR CODE"];
    };
    
    void (^messageBlock)(void)=^{
        [self.view endEditing:YES];
        LWCameraMessageView *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        
        [window addSubview:view];
        
        [view show];
    };
    
    
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        block();
    } else if(authStatus == AVAuthorizationStatusDenied){
        messageBlock();
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [self.view endEditing:YES];
       LWCameraMessageView2 *view=[[NSBundle mainBundle] loadNibNamed:@"LWCameraMessageView2" owner:self options:nil][0];
        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
        view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
        
        [window addSubview:view];
        
        [view showWithCompletion:^(BOOL result){
            if(result)
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(granted){
                            block();
                        } else {
                            messageBlock();
                        }
                    });
                }];
        }];
    } else {
        // impossible, unknown authorization status
    }
    
    
    
#endif

    
    
    
}


#pragma mark - ZBar's Delegate method

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
#if TARGET_IPHONE_SIMULATOR
    // Simulator
#else
    //  get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // just grab the first barcode
        break;
    
    // showing the result on textview
    
    bitcoinTextField.text = symbol.data;
    [self updatePasteButtonStatus];
    
    
    
    // dismiss the controller
    //    [reader dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *array=self.navigationController.viewControllers;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
#endif
    
}



#pragma mark - test

- (void)scanViewController:(LWQrCodeScannerPresenter *)controller didSuccessfullyScan:(NSString *)scannedValue {
    [self.navigationController popToViewController:self animated:NO];
    
    bitcoinTextField.text = scannedValue;
    [self updatePasteButtonStatus];
}


#pragma mark - Utils

- (BOOL)canProceed {
    if(bitcoinTextField.text.length<26 || bitcoinTextField.text.length>35)
        return NO;
    NSString *sss=[[bitcoinTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet alphanumericCharacterSet]] componentsJoinedByString:@""];
    if(sss.length)
        return NO;
//    NSString *firstSymbol=[bitcoinTextField.text substringToIndex:1];
//    NSArray *possibleFirstSymbols=@[@"1", @"3", @"2", @"m", @"n"];
//    BOOL flag=false;
//    for(NSString *s in possibleFirstSymbols)
//    {
//        if([s isEqualToString:firstSymbol])
//        {
//            flag=true;
//            break;
//        }
//    }
//
//    return flag;
    
    return YES;
}

- (void)updatePasteButtonStatus {
    
    if([self canProceed]==NO)
    {
        [LWValidator setButton:self.proceedButton enabled:NO];
        [self hideShowPasteButton:NO];

    }
    else
    {
        validationRequests++;
        if(validationRequests==1)
            [progressValidation startAnimating];
        [[LWAuthManager instance] validateBitcoinAddress:bitcoinTextField.text];
    }
        
//    // check button state
//    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
//    self.pasteButton.hidden = [self canProceed];
}

#pragma mark - LWAuthManager

-(void) authManager:(LWAuthManager *)manager didValidateBitcoinAddress:(LWPacketBitcoinAddressValidation *)bitconAddress
{
    BOOL isValid=bitconAddress.isValid && [self canProceed] && [bitconAddress.bitcoinAddress isEqualToString:bitcoinTextField.text];
    [LWValidator setButton:self.proceedButton enabled:isValid];
    [self hideShowPasteButton:isValid];
    
    validationRequests--;
    if(validationRequests==0)
        [progressValidation stopAnimating];
    
}

-(void) hideShowPasteButton:(BOOL) shouldHide
{
    self.pasteButton.hidden=shouldHide;
    if(shouldHide)
        [bitcoinTextField setRightOffset:10];
    else
        [bitcoinTextField setRightOffset:70];

    
}

@end
