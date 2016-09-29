//
//  LWCreateEditPrivateWalletPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCreateEditPrivateWalletPresenter.h"
#import "LWValidator.h"
#import "LWWalletsTypeButton.h"
#import "LWPrivateKeyManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWPrivateWalletModel.h"
#import "BTCAddress.h"
#import "ZBarReaderViewController.h"
#import "LWCameraMessageView.h"
#import "LWCameraMessageView2.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletsManager.h"

@import AVFoundation;

#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]

@interface LWCreateEditPrivateWalletPresenter () <UITextFieldDelegate>
{
    NSDictionary *createButtonEnabledAttributes;
    NSDictionary *buttonDisabledAttributes;
    BOOL flagColoredAddress;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *walletNewButton;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *walletExistingButton;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *privateKeyTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *createUpdateButton;
@property (weak, nonatomic) IBOutlet UIView *scanQRView;
@property (weak, nonatomic) IBOutlet UIButton *padlockButton;
@property (weak, nonatomic) IBOutlet UIView *modeButtonsContainer;
@property (weak, nonatomic) IBOutlet UIButton *keyPasteButton;
@property (weak, nonatomic) IBOutlet UIButton *keyCopyButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;

@property (strong, nonatomic) NSLayoutConstraint *keyPasteWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *padlockWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *keyCopyWidthConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQRHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *walletNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;


@end

@implementation LWCreateEditPrivateWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    flagColoredAddress=NO;
    
    
    UIView *grayView=[[UIView alloc] initWithFrame:CGRectMake(0, -500, 1024, 500)];
    grayView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.scrollView addSubview:grayView];
    
    self.keyPasteWidthConstraint=[NSLayoutConstraint constraintWithItem:self.keyPasteButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.keyPasteButton addConstraint:_keyPasteWidthConstraint];

    self.padlockWidthConstraint=[NSLayoutConstraint constraintWithItem:self.padlockButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.padlockButton addConstraint:_padlockWidthConstraint];

    self.keyCopyWidthConstraint=[NSLayoutConstraint constraintWithItem:self.keyCopyButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.keyCopyButton addConstraint:_keyCopyWidthConstraint];
    
    self.lineViewHeightConstraint.constant=0.5;

    createButtonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};

     buttonDisabledAttributes= @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};

    NSString *createUpdateButtonTitle;
    
    if(self.editMode)
    {
        self.scanQRView.hidden=YES;
        self.scanQRHeightConstraint.constant=25;
//        self.modeButtonsContainer.hidden=YES;
//        self.walletNameTopConstraint.constant=20;
        
        [_walletNewButton setTitle:@"BITCOIN"];
        [_walletExistingButton setTitle:@"COLORED"];
        [self pressedWalletTypeButton:_walletNewButton];

        
        
        
        createUpdateButtonTitle=@"UPDATE WALLET";
        [LWValidator setButton:self.createUpdateButton enabled:YES];
        
        self.walletNameTextField.text=self.wallet.name;
        self.addressLabel.text=self.wallet.address;
        self.privateKeyTextField.text=self.wallet.privateKey;
        self.privateKeyTextField.secureTextEntry=YES;
        
        if([self.wallet.privateKey isEqualToString:[LWPrivateKeyManager shared].wifPrivateKeyLykke])
        {
            self.walletNameTextField.userInteractionEnabled=NO;
            self.createUpdateButton.hidden=YES;
            self.titleLabel.hidden=YES;
        }
        else
            self.titleLabel.text=@"Change wallet name";
        self.padlockWidthConstraint.active=NO;
    }
    else
    {
        createUpdateButtonTitle=@"CREATE WALLET";
        [LWValidator setButton:self.createUpdateButton enabled:NO];
        self.titleLabel.text=@"Enter details of new wallet";
        self.padlockWidthConstraint.active=YES;
        [self.walletNewButton setTitle:@"NEW"];
        [self.walletExistingButton setTitle:@"EXISTING"];

    }
    
//    self.keyPasteWidthConstraint.constant=0;

    self.privateKeyTextField.delegate=self;
    self.walletNameTextField.delegate=self;
    self.privateKeyTextField.userInteractionEnabled=NO;

    
    [self.walletNewButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.walletExistingButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];
    if(self.editMode==NO)
        [self pressedWalletTypeButton:_walletNewButton];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressViewPressedScanQRCode)];
    [self.scanQRView addGestureRecognizer:gesture];
    
    
    self.walletNameTextField.placeholder=@"Name of wallet";
    self.privateKeyTextField.placeholder=@"Private key";
    [self validateCreateUpdateButton];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];;
    [self setBackButton];
    self.observeKeyboardEvents=YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.editMode)
        self.title=@"EDIT WALLET";
    else
        self.title=@"ADD NEW WALLET";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.createUpdateButton.layer.cornerRadius=self.createUpdateButton.bounds.size.height/2;
    self.walletNewButton.layer.cornerRadius=self.walletNewButton.bounds.size.height/2;
    self.walletExistingButton.layer.cornerRadius=self.walletExistingButton.bounds.size.height/2;
    
}

-(void) pressedWalletTypeButton:(UIButton *) button
{
    if(button.selected)
        return;
    
    self.walletNewButton.selected=NO;
    self.walletExistingButton.selected=NO;
    button.selected=YES;

    if(self.editMode)
    {
        if(button==self.walletNewButton)
        {
            _addressTitleLabel.text=@"Wallet address";
            _addressLabel.text=[LWPrivateKeyManager addressFromPrivateKeyWIF:self.privateKeyTextField.text];
            
        }
        else
        {
            _addressTitleLabel.text=@"Private wallet colored address";
            _addressLabel.text=[[LWPrivateKeyManager shared] coloredAddressFromBitcoinAddress:[LWPrivateKeyManager addressFromPrivateKeyWIF:self.privateKeyTextField.text]];

        }
        return;
    }
    
    
    NSString *createUpdateButtonTitle;
    
    if(button==self.walletNewButton)
    {
        self.privateKeyTextField.text=[[LWPrivateKeyManager shared] availableSecondaryPrivateKey];
        self.addressLabel.text=[LWPrivateKeyManager addressFromPrivateKeyWIF:self.privateKeyTextField.text];
        self.privateKeyTextField.userInteractionEnabled=NO;
        
        self.scanQRView.hidden=YES;
        self.scanQRHeightConstraint.constant=20;
        self.keyPasteWidthConstraint.active=YES;
        
        NSString *sss=self.addressLabel.text;
        
        
                createUpdateButtonTitle=@"CREATE WALLET";
        
        NSLog(@"%@", sss);
    }
    else
    {
        self.addressLabel.text=@"";
        self.privateKeyTextField.text=@"";
        self.privateKeyTextField.userInteractionEnabled=YES;
        self.scanQRView.hidden=NO;
        self.scanQRHeightConstraint.constant=54;
        self.keyPasteWidthConstraint.active=NO;
        createUpdateButtonTitle=@"ADD WALLET";

    }
    
    _padlockWidthConstraint.active=YES;
    
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];


    
    [self.view endEditing:YES];
    
    [self validateCreateUpdateButton];
    
    [self.view layoutSubviews];
}

-(IBAction) copyButtonPressed:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=self.privateKeyTextField.text;

    [self showCopied];
}

-(IBAction)padlockPressed:(id)sender
{
    if(self.editMode)
    {
        self.padlockButton.selected=!self.padlockButton.selected;
        if(self.padlockButton.selected)
        {
            self.privateKeyTextField.secureTextEntry=NO;
            self.keyCopyWidthConstraint.active=NO;
        }
        else
        {
            self.privateKeyTextField.secureTextEntry=YES;
            self.keyCopyWidthConstraint.active=YES;
        }
    }
}

-(IBAction)pasteButtonPressed:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    self.privateKeyTextField.text=string;
    [self validatePrivateKeyField];
}

-(void) validatePrivateKeyField
{
    if(self.privateKeyTextField.text.length==0)
        self.keyPasteWidthConstraint.active=NO;
    else
        self.keyPasteWidthConstraint.active=YES;
    
    BTCKey *key;
    if(self.privateKeyTextField.text.length)
    {
        key=[[BTCKey alloc] initWithWIF:self.privateKeyTextField.text];
        if(key)
        {
            if([LWPrivateKeyManager shared].isDevServer)
            {
                
                BTCAddress *address=key.addressTestnet;
                self.addressLabel.text=address.string;
            }
            else
            {
                BTCAddress *address=key.address;
                self.addressLabel.text=address.string;
            }
//            privateKey=key;
            _padlockWidthConstraint.active=NO;
            self.privateKeyTextField.userInteractionEnabled=NO;
        }
    }
    
    if(!key && self.addressLabel.text.length)
    {
        self.addressLabel.text=@"";
        _padlockWidthConstraint.active=YES;
    }
    [self.view layoutIfNeeded];


}

-(void) validateCreateUpdateButton
{
    NSString *walletName=[self.walletNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
    if(self.editMode)
    {
        if([self.walletNameTextField.text isEqualToString:_wallet.name.lowercaseString])
            [LWValidator setButton:self.createUpdateButton enabled:NO];
        else if(self.walletNameTextField.text.length && [self.walletNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length)
        {
            [LWValidator setButton:self.createUpdateButton enabled:YES];
        }
        for(LWPrivateWalletModel *m in [LWPrivateWalletsManager shared].wallets)
        {
            if([[m.name lowercaseString] isEqualToString:walletName])
            {
                [LWValidator setButton:self.createUpdateButton enabled:NO];
                break;
            }
        }
    }
    else
    {
        if(self.walletNameTextField.text.length && [self.walletNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length && self.addressLabel.text.length)
        {
            [LWValidator setButton:self.createUpdateButton enabled:YES];
        }
        else
            [LWValidator setButton:self.createUpdateButton enabled:NO];
        
        for(LWPrivateWalletModel *m in [LWPrivateWalletsManager shared].wallets)
        {
            if([[m.name lowercaseString] isEqualToString:walletName])
            {
                [LWValidator setButton:self.createUpdateButton enabled:NO];
                break;
            }
        }

        
    }
    
    if(_addressLabel.text.length)
        _addressTitleLabel.text=@"Wallet address";
    else
        _addressTitleLabel.text=@"Wallet address is not defined";
    
    
}



-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *charSet=[NSCharacterSet alphanumericCharacterSet];
    NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(newString.length)
    {
        NSString *nums=@"0123456789";
        NSString *first=[newString substringToIndex:1];
        if([nums rangeOfString:first].location!=NSNotFound)
            return NO;
        if([first stringByTrimmingCharactersInSet:charSet].length!=0)
            return NO;
    }
    
    if(textField==self.walletNameTextField)
        string=string.uppercaseString;
        
        
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField==self.privateKeyTextField)
        [self validatePrivateKeyField];
    else if(textField==self.walletNameTextField)
    {
        [self validateCreateUpdateButton];
    }
    return NO;
}


-(void) addressViewPressedScanQRCode
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
    
    BTCKey *privateKey=[[BTCKey alloc] initWithWIF:(NSString*)symbol.data];
    
    NSString *prod=privateKey.WIF;
    NSString *testnet=privateKey.WIFTestnet;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    if(privateKey)
    {
        
        if([LWPrivateKeyManager shared].isDevServer)
        {
            if([testnet isEqualToString:symbol.data])
            {
                self.privateKeyTextField.text=symbol.data;
                self.addressLabel.text=privateKey.addressTestnet.string;
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"This private key is for Production environment.\nIt can not be used with Testnet!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
        }
        else
        {
            if([prod isEqualToString:symbol.data])
            {
                self.addressLabel.text=privateKey.address.string;
                self.privateKeyTextField.text=symbol.data;
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"This private key is for Testnet environment.\nIt can not be used with Lykke!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
                return;
            }
        }
        [self validatePrivateKeyField];
        [self.view setNeedsLayout];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Invalid private key" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    
#endif
    
}


-(IBAction)createUpdateButtonPressed:(id)sender
{
    [self setLoading:YES];
    [self.view endEditing:YES];
    if(self.editMode==NO)
    {
        LWPrivateWalletModel *wallet=[[LWPrivateWalletModel alloc] init];
        wallet.address=self.addressLabel.text;
        wallet.privateKey=self.privateKeyTextField.text;
        wallet.name=self.walletNameTextField.text;
        wallet.encryptedKey=[[LWPrivateKeyManager shared] encryptKey:wallet.privateKey password:[LWKeychainManager instance].password];
        [[LWPrivateWalletsManager shared] addNewWallet:wallet withCompletion:^(BOOL success){
            [self setLoading:NO];
            if(success)
            {
                [[LWKeychainManager instance] savePrivateKey:wallet.privateKey forWalletAddress:wallet.address];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    else
    {
        self.wallet.name=self.walletNameTextField.text;
        if(!self.wallet.encryptedKey)
            self.wallet.encryptedKey=[[LWPrivateKeyManager shared] encryptKey:_wallet.privateKey password:[LWKeychainManager instance].password];
        [[LWPrivateWalletsManager shared] updateWallet:self.wallet withCompletion:^(BOOL success){
            [self setLoading:NO];
            if(success)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

    }

}

-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
//    CGPoint point=[window convertPoint:CGPointMake(0, window.bounds.size.height-frame.size.height) toView:self.view];
//    
//    [self.bottomOffsetConstraint setConstant:self.view.bounds.size.height-point.y];

    self.scrollViewBottomConstraint.constant=frame.size.height;
    
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    self.scrollViewBottomConstraint.constant=0;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
