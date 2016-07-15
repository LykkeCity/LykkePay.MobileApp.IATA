//
//  LWAddPrivateWalletPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAddPrivateWalletPresenter.h"

#import "LWWalletsTypeButton.h"
#import "UIViewController+Navigation.h"
#import "LWValidator.h"
#import "LWWalletAddressView.h"
#import "ZBarReaderViewController.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"

@import AVFoundation;

#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]


@interface LWAddPrivateWalletPresenter () <UITextFieldDelegate, ZBarReaderDelegate>
{
    UIScrollView *scrollView;
    LWWalletsTypeButton *newButton;
    LWWalletsTypeButton *existingButton;
    UIView *walletNameContainer;
    UITextField *walletNameTextField;
    UIView *privateKeyContainer;
    UILabel *privateKeyLabel;
    UITextField *privateKeyTextField;
    
    LWWalletAddressView *addressView;
    
    UIView *headerBackground;
    
    UIButton *generatePrivateKeyButton;
    UIButton *scanQRCodeButton;
    
    UIButton *backupButton;
    UIButton *createWalletButton;
    
    NSDictionary *buttonDisabledAttributes;
    
    NSDictionary *createButtonEnabledAttributes;
    
}

@end

@implementation LWAddPrivateWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackButton];
    
    scrollView=[[UIScrollView alloc] init];
    scrollView.backgroundColor=[UIColor whiteColor];
    scrollView.frame=self.view.bounds;
    scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    UIView *topBack=[[UIView alloc] initWithFrame:CGRectMake(0, -500, 1024, 500)];
    topBack.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [scrollView addSubview:topBack];
    
    headerBackground=[[UIView alloc] init];
    headerBackground.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    headerBackground.frame=CGRectMake(0, 0, scrollView.bounds.size.width, 241);
    headerBackground.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, headerBackground.bounds.size.height-0.5, headerBackground.bounds.size.width, 0.5)];
    line.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    line.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [headerBackground addSubview:line];
    
    [scrollView addSubview:headerBackground];
    
    UILabel *subtitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 20)];
    subtitle.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    subtitle.textAlignment=NSTextAlignmentCenter;
    subtitle.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    subtitle.textColor=TextColor;
    subtitle.text=@"Enter details of new wallet";
    [scrollView addSubview:subtitle];
    
    newButton=[[LWWalletsTypeButton alloc] initWithTitle:@"NEW"];
    [newButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    existingButton=[[LWWalletsTypeButton alloc] initWithTitle:@"EXISTING"];
    [existingButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:newButton];
    [scrollView addSubview:existingButton];
    
    walletNameContainer=[[UIView alloc] init];
    walletNameContainer.backgroundColor=[UIColor whiteColor];
    walletNameContainer.layer.cornerRadius=2.5;
    [scrollView addSubview:walletNameContainer];
    
    walletNameTextField=[[UITextField alloc] init];
    walletNameTextField.textColor=TextColor;
    walletNameTextField.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    walletNameTextField.delegate=self;
    walletNameTextField.placeholder=@"Name of wallet";
    [walletNameContainer addSubview:walletNameTextField];
    
    privateKeyContainer=[[UIView alloc] init];
    privateKeyContainer.backgroundColor=[UIColor whiteColor];
    privateKeyContainer.layer.cornerRadius=2.5;
    [scrollView addSubview:privateKeyContainer];
    
    privateKeyLabel=[[UILabel alloc] init];
    privateKeyLabel.textColor=TextColor;
    privateKeyLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    [privateKeyContainer addSubview:privateKeyLabel];
    
    privateKeyTextField=[[UITextField alloc] init];
    privateKeyTextField.textColor=TextColor;
    privateKeyTextField.placeholder=@"Private key";
    privateKeyTextField.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    privateKeyTextField.delegate=self;
    [privateKeyContainer addSubview:privateKeyTextField];
    
    generatePrivateKeyButton=[self createButtonWithIcon:[UIImage imageNamed:@"GeneratePrivateKey"] title:@"Generate key"];
    [scrollView addSubview:generatePrivateKeyButton];
    
    scanQRCodeButton=[self createButtonWithIcon:[UIImage imageNamed:@"QrCodeIcon"] title:@"Scan QR-code"];
    [scanQRCodeButton addTarget:self action:@selector(addressViewPressedScanQRCode) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:scanQRCodeButton];
    
    addressView=[[LWWalletAddressView alloc] initWithWidth:scrollView.bounds.size.width-60];
    addressView.address=@"adkjheuhLjlskjlJLkhldfkjlkjduhljn2lj3lknsldkjlskj";
    [scrollView addSubview:addressView];
    
    
    
    backupButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    buttonDisabledAttributes = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};
    createButtonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    
    [backupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BACKUP" attributes:buttonDisabledAttributes] forState:UIControlStateNormal];
    backupButton.titleLabel.alpha=0.2;
    backupButton.frame=CGRectMake(0, 0, self.view.bounds.size.width-60, 45);
    [scrollView addSubview:backupButton];
    
    createWalletButton=[UIButton buttonWithType:UIButtonTypeCustom];
    createWalletButton.frame=backupButton.frame;
    [scrollView addSubview:createWalletButton];
    
    [LWValidator setButtonWithClearBackground:backupButton enabled:NO];
    [LWValidator setButton:createWalletButton enabled:NO];
    
    
    newButton.selected=YES;
    
    [self alignScrollView];
    
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self alignScrollView];
        }];
}

-(void) alignScrollView
{
    newButton.center=CGPointMake(scrollView.bounds.size.width/2-newButton.bounds.size.width/2-2.5, 51);
    existingButton.center=CGPointMake(scrollView.bounds.size.width/2+existingButton.bounds.size.width/2+2.5, 51);
    
    walletNameContainer.frame=CGRectMake(30, 91, scrollView.bounds.size.width-60, 45);
    walletNameTextField.frame=CGRectMake(15, 0, walletNameContainer.bounds.size.width-30, walletNameContainer.bounds.size.height);
    
    privateKeyContainer.frame=CGRectMake(30, 146, scrollView.bounds.size.width-60, 45);
    privateKeyLabel.frame=CGRectMake(15, 0, privateKeyContainer.bounds.size.width-20, privateKeyContainer.bounds.size.height);
    privateKeyTextField.frame=privateKeyLabel.frame;
    
    generatePrivateKeyButton.center=CGPointMake(scrollView.bounds.size.width/2, 208+generatePrivateKeyButton.bounds.size.height/2);
    scanQRCodeButton.center=generatePrivateKeyButton.center;
    
    addressView.center=CGPointMake(scrollView.bounds.size.width/2, headerBackground.bounds.size.height+10+addressView.bounds.size.height/2);
    
    backupButton.center=CGPointMake(scrollView.bounds.size.width/2, addressView.frame.origin.y+addressView.bounds.size.height+10+backupButton.bounds.size.height/2);
    createWalletButton.center=CGPointMake(scrollView.bounds.size.width/2, backupButton.frame.origin.y+backupButton.bounds.size.height+10+createWalletButton.bounds.size.height/2);
    
    if(newButton.selected)
    {
        privateKeyTextField.hidden=YES;
        privateKeyLabel.hidden=NO;
        scanQRCodeButton.hidden=YES;
        generatePrivateKeyButton.hidden=NO;
        if(createWalletButton.enabled)
        {
            [createWalletButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CREATE WALLET" attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
            createWalletButton.titleLabel.alpha=1;
        }
        else
        {
            [createWalletButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CREATE WALLET" attributes:buttonDisabledAttributes] forState:UIControlStateNormal];
            createWalletButton.titleLabel.alpha=0.2;
        }
    }
    else
    {
        privateKeyTextField.hidden=NO;
        privateKeyLabel.hidden=YES;
        scanQRCodeButton.hidden=NO;
        generatePrivateKeyButton.hidden=YES;
        if(createWalletButton.enabled)
        {
            [createWalletButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"ADD WALLET" attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
            createWalletButton.titleLabel.alpha=1;
        }
        else
        {
            [createWalletButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"ADD WALLET" attributes:buttonDisabledAttributes] forState:UIControlStateNormal];
            createWalletButton.titleLabel.alpha=0.2;
        }
        
    }
    
    scrollView.contentSize=CGSizeMake(scrollView.bounds.size.width, createWalletButton.frame.origin.y+createWalletButton.bounds.size.height+10);
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];;

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"ADD NEW WALLET";
    self.observeKeyboardEvents=YES;

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];;

}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    scrollView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-frame.size.height);
    
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    scrollView.frame=self.view.bounds;
}

-(void) pressedWalletTypeButton:(UIButton *) button
{
    if(button.selected)
        return;
    newButton.selected=NO;
    existingButton.selected=NO;
    button.selected=YES;
    
    addressView.address=nil;
    
    [self.view setNeedsLayout];
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
    button.frame=CGRectMake(0, 0, icon.bounds.size.width+label.bounds.size.width+3, icon.bounds.size.height);
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
        
        [codeReader setTitle:@"SCAN QR-CODE"];
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
    
    
    
    privateKeyTextField.text=symbol.data;
    
    
    
    // dismiss the controller
    //    [reader dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
#endif
    
}

-(NSString *) nibName
{
    return nil;
}


@end
