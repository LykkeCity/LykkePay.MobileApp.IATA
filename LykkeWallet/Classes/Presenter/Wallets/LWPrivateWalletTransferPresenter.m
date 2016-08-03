//
//  LWPrivateWalletTransferPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletTransferPresenter.h"
#import "LWValidator.h"
#import "BTCAddress.h"
#import "LWPrivateKeyManager.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "ZBarReaderViewController.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"
#import "LWChoosePrivateWalletView.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateWalletTransferInputPresenter.h"
#import "LWPKTransferModel.h"

@import AVFoundation;

@interface LWPrivateWalletTransferPresenter () <UITextFieldDelegate>
{
    UIView *addressBackground;
    UITextField *addressTextField;
    UIButton *pasteButton;
    UIButton *scanQRCodeButton;
    UIButton *selectWalletButton;
    UIButton *proceedButton;
    NSDictionary *proceedEnabledAttributes;
    NSDictionary *proceedDisabledAttributes;
    UILabel *selectedWalletNameLabel;
}

@end

@implementation LWPrivateWalletTransferPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self setBackButton];
    
    selectedWalletNameLabel=[[UILabel alloc] init];
    selectedWalletNameLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    selectedWalletNameLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    selectedWalletNameLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:selectedWalletNameLabel];
    
    addressBackground=[[UIView alloc] init];
    addressBackground.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    addressBackground.clipsToBounds=YES;
    addressBackground.layer.cornerRadius=2.5;
    [self.view addSubview:addressBackground];
    
    addressTextField=[[UITextField alloc] init];
    [addressBackground addSubview:addressTextField];
    addressTextField.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    addressTextField.backgroundColor=nil;
    addressTextField.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    addressTextField.placeholder=@"Enter address of wallet";
    
    
    scanQRCodeButton=[self createButtonWithIcon:[UIImage imageNamed:@"QrCodeIcon"] title:@"Scan QR code"];
    [scanQRCodeButton addTarget:self action:@selector(addressViewPressedScanQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanQRCodeButton];
    
    selectWalletButton=[self createButtonWithIcon:[UIImage imageNamed:@"SelectWallet"] title:@"Select wallet"];
    [selectWalletButton addTarget:self action:@selector(selectWalletPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectWalletButton];

    proceedButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton addTarget:self action:@selector(proceedPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:proceedButton];
    
    proceedEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    proceedDisabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};
    
    [proceedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:proceedDisabledAttributes] forState:UIControlStateDisabled];
    [proceedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PROCEED" attributes:proceedEnabledAttributes] forState:UIControlStateNormal];
    
    pasteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [pasteButton setTitle:@"Paste" forState:UIControlStateNormal];
    pasteButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    pasteButton.titleLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    [pasteButton sizeToFit];
    [addressBackground addSubview:pasteButton];
    
    proceedButton.enabled=NO;
    [self validateProceedButton];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"TRANSFER TO";
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self alignSubviews];
}


-(void) alignSubviews
{
    selectedWalletNameLabel.frame=CGRectMake(30, 0, self.view.bounds.size.width-60, 17);
    addressBackground.frame=CGRectMake(30, 36, self.view.bounds.size.width-60, 45);
    addressTextField.frame=CGRectMake(15, 12, addressBackground.bounds.size.width-30, addressBackground.bounds.size.height-24);
    scanQRCodeButton.center=CGPointMake(self.view.bounds.size.width/2-10-scanQRCodeButton.bounds.size.width/2, 96+scanQRCodeButton.bounds.size.height/2);
    selectWalletButton.center=CGPointMake(self.view.bounds.size.width/2+10+selectWalletButton.bounds.size.width/2, scanQRCodeButton.center.y);
    
    proceedButton.frame=CGRectMake(30, 134, self.view.bounds.size.width-60, 45);
    [LWValidator setButton:proceedButton enabled:proceedButton.enabled];
    pasteButton.frame=CGRectMake(addressBackground.bounds.size.width-pasteButton.bounds.size.width-15, 0, pasteButton.bounds.size.width, addressBackground.bounds.size.height);

}

-(void) validateProceedButton
{
    
    proceedButton.enabled=NO;
    if(addressTextField.text.length)
    {
        BTCAddress *address=[BTCAddress addressWithString:addressTextField.text];
        if(address)
        {
            if(address.isTestnet==[LWPrivateKeyManager shared].isDevServer)
                proceedButton.enabled=YES;
        }
    }
        [LWValidator setButton:proceedButton enabled:proceedButton.enabled];
    if(addressTextField.text.length)
        pasteButton.hidden=YES;
    else
        pasteButton.hidden=NO;
    if(proceedButton.enabled==NO)
        selectedWalletNameLabel.text=@"";
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
    [self validateProceedButton];
    return NO;
}


-(void) selectWalletPressed
{
    
    [LWChoosePrivateWalletView showWithCurrentWallet:self.transfer.sourceWallet completion:^(LWPrivateWalletModel *wallet){
        addressTextField.text=wallet.address;
        [self validateProceedButton];
        selectedWalletNameLabel.text=wallet.name;
    }];

}

-(void) proceedPressed
{
    LWPrivateWalletTransferInputPresenter *presenter=[[LWPrivateWalletTransferInputPresenter alloc] init];

    self.transfer.destinationAddress=addressTextField.text;
    presenter.transfer=self.transfer;
    
    [self.navigationController pushViewController:presenter animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIButton *) createButtonWithIcon:(UIImage *) image title:(NSString *) title
{
    UIImageView *icon=[[UIImageView alloc] initWithImage:image];
    UILabel *label=[[UILabel alloc] init];
    label.text=title;
    label.textColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    [label sizeToFit];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 0, icon.bounds.size.width+label.bounds.size.width+6, icon.bounds.size.height);
    [button addSubview:icon];
    [button addSubview:label];
    label.center=CGPointMake(button.bounds.size.width-label.bounds.size.width/2, button.bounds.size.height/2);
    
    return button;
}


-(void) addressViewPressedScanQRCode
{
    
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
    
    BTCAddress *address=[BTCAddress addressWithString:(NSString *) symbol.data];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    BOOL flagTestnet=[[LWPrivateKeyManager shared] isDevServer];
    
    //    flagTestnet=NO;
    
    if(address)
    {
        
        if(flagTestnet)
        {
            if(address.isTestnet)
            {
                addressTextField.text=symbol.data;
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"This address is for Production environment.\nIt can not be used with Testnet!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
        }
        else
        {
            if(address.isTestnet==NO)
            {
                addressTextField.text=symbol.data;
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"This address is for Testnet environment.\nIt can not be used with Lykke!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
                return;
            }
        }
        [self validateProceedButton];
        [self.view setNeedsLayout];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Invalid address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    
#endif
    
}


-(NSString *) nibName
{
    return nil;
}


@end
