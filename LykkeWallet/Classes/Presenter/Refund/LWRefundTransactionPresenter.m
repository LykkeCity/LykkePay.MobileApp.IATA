//
//  LWRefundPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundTransactionPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWPrivateKeyManager.h"
#import "LWKeychainManager.h"
#import "BTCKey.h"
#import "LWValidator.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"
#import "ZBarReaderViewController.h"
#import "LWRefundBroadcastPresenter.h"
#import "LWTransactionManager.h"
#import "BTCTransaction.h"
#import "LWUtils.h"

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]
#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]

@import AVFoundation;

@interface LWRefundTransactionPresenter () <UITextFieldDelegate, UITextViewDelegate>
{
    NSString *encodedPrivateKey;
    BTCKey *key;
    
    BTCTransaction *signedTransaction;
    
    NSString *transactionPlaceholder;
}

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextView *transaction;
@property (weak, nonatomic) IBOutlet UIImageView *iconValid;
@property (weak, nonatomic) IBOutlet UIImageView *iconTransactionIsValid;
@property (weak, nonatomic) IBOutlet UIButton *buttonProceed;
@property (weak, nonatomic) IBOutlet UIView *scanView;

@end

@implementation LWRefundTransactionPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    transactionPlaceholder=@"Hex encoded bitcoin transaction";
    
    self.password.placeholder=@"Your password";
    self.password.delegate=self;
    self.transaction.delegate=self;
    self.transaction.textColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.3];
    self.transaction.text = transactionPlaceholder;

    
    encodedPrivateKey=[[LWKeychainManager instance] encodedPrivateKeyForEmail:self.email];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanQRPressed)];
    [self.scanView addGestureRecognizer:gesture];
    
    NSDictionary *attrDisabled = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};
    NSDictionary *attrEnabled = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.buttonProceed setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:attrEnabled] forState:UIControlStateNormal];
    [self.buttonProceed setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:attrDisabled] forState:UIControlStateDisabled];
    [LWValidator setButton:self.buttonProceed enabled:NO];

//    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:gesture];
    // Do any additional setup after loading the view from its nib.
}

//-(void) hideKeyboard
//{
//    [self.view endEditing:YES];
//}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:@"REFUND"];
    [self.navigationController setNavigationBarHidden:NO];
    [self setCrossCloseButton];
    
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;

    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}


-(void) tryToSignransaction
{
    if(!key)
        return;
    NSString *keyWif;
    
    if([[LWPrivateKeyManager shared] isDevServer])
        keyWif=key.WIFTestnet;
    else
        keyWif=key.WIF;
    
    signedTransaction=[LWTransactionManager signMultiSigTransaction:self.transaction.text withKey:keyWif];
    
    if(signedTransaction)
    {
        [self.transaction resignFirstResponder];
        self.iconTransactionIsValid.hidden=NO;
        self.transaction.userInteractionEnabled=NO;
        
        [LWValidator setButton:self.buttonProceed enabled:YES];
    }
 
}


-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString=[textView.text stringByReplacingCharactersInRange:range withString:text];
    textView.text=newString;
    [self tryToSignransaction];
    
    return NO;
//    
//
//    if(newString.length && self.iconValid.hidden==NO)
//    {
//        [LWValidator setButton:self.buttonProceed enabled:YES];
//        return NO;
//    }
//    [LWValidator setButton:self.buttonProceed enabled:NO];
//    return YES;
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    self.password.text=newString;

        NSString *prK=[[LWPrivateKeyManager shared] decryptPrivateKey:encodedPrivateKey withPassword:newString];
        if(prK && prK.length>15)
        {
            key=[[BTCKey alloc] initWithWIF:prK];
            if(key)
            {
                self.password.userInteractionEnabled=NO;
                [self.password resignFirstResponder];
                self.iconValid.hidden=NO;
                
                [self tryToSignransaction];
                return NO;
            }
        }
    
    
    [LWValidator setButton:self.buttonProceed enabled:NO];

    return NO;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if([self.transaction.text isEqualToString:transactionPlaceholder])
    {
    self.transaction.text = @"";
    }
    self.transaction.textColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    return YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [self textViewDidChange:textView];
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.transaction.text.length == 0){
        self.transaction.textColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.3];
        self.transaction.text = transactionPlaceholder;
        return;
    }
    else
    {
        self.transaction.textColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    }
    
    [self tryToSignransaction];
}

-(IBAction) proceedPressed:(id)sender
{
    LWRefundBroadcastPresenter *presenter=[[LWRefundBroadcastPresenter alloc] init];
    presenter.transactionText=[LWUtils hexStringFromData:signedTransaction.data];
    presenter.lockTime=signedTransaction.lockTime;
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) scanQRPressed
{
    [self.view endEditing:YES];
    
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
        [scanner setSymbology: ZBAR_EAN8 config: ZBAR_CFG_ENABLE to: 0];
        //        [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
        
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
    
    
    self.transaction.text=symbol.data;
    [self textViewDidChange:self.transaction];
//    if(self.iconValid.hidden==NO)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//        [LWValidator setButton:self.buttonProceed enabled:YES];
//            });
//    }
    
    
    
    // dismiss the controller
    //    [reader dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
#endif
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
