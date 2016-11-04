//
//  LWCreatePrivateWalletPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCreatePrivateWalletPresenter.h"
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
#import "LWCommonButton.h"
#import "LWGenerateKeyPresenter.h"
#import "LWBackupGetStartedPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWBackupCheckWordsPresenter.h"
#import "LWColdWalletKeyTypePresenter.h"

@import AVFoundation;

#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]

@interface LWCreatePrivateWalletPresenter () <UITextFieldDelegate, LWGenerateKeyPresenterDelegate>
{
    LWColdWalletKeyTypePresenter *coldWalletKeyTypePresenter;
    BOOL currentIs256ColdFlag;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *walletNewButton;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *walletExistingButton;
@property (weak, nonatomic) IBOutlet LWWalletsTypeButton *walletColdButton;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *privateKeyTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet LWCommonButton *createUpdateButton;
@property (weak, nonatomic) IBOutlet UIView *scanQRView;
@property (weak, nonatomic) IBOutlet UIButton *padlockButton;
@property (weak, nonatomic) IBOutlet UIView *modeButtonsContainer;
@property (weak, nonatomic) IBOutlet UIButton *keyPasteButton;
@property (weak, nonatomic) IBOutlet UIButton *keyCopyButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *privateKeyTypeView;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privateKeyTypeContainerHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createUpdateButtonWidth;

@property (weak, nonatomic) IBOutlet UIView *privateKeyContainerView;

@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;

@property (strong, nonatomic) NSLayoutConstraint *keyPasteWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *padlockWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *keyCopyWidthConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQRHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *walletNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privateKeyContainerHeightConstraint;


@end

@implementation LWCreatePrivateWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
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

//    createButtonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
//
//     buttonDisabledAttributes= @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};

    NSString *createUpdateButtonTitle;
    

        createUpdateButtonTitle=@"CREATE WALLET";
//        [LWValidator setButton:self.createUpdateButton enabled:NO];
        _createUpdateButton.enabled=NO;
        self.titleLabel.text=@"Enter details of new wallet";
        self.padlockWidthConstraint.active=YES;
        [self.walletNewButton setTitle:@"PRIVATE"];
        [self.walletExistingButton setTitle:@"EXISTING"];
        [self.walletColdButton setTitle:@"COLD"];

    
    
//    self.keyPasteWidthConstraint.constant=0;

    self.privateKeyTextField.delegate=self;
    self.walletNameTextField.delegate=self;
    self.privateKeyTextField.userInteractionEnabled=NO;

    
    [self.walletNewButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.walletExistingButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.walletColdButton addTarget:self action:@selector(pressedWalletTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
//    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];
    
    [_createUpdateButton setTitle:createUpdateButtonTitle forState:UIControlStateNormal];
    
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressViewPressedScanQRCode)];
    [self.scanQRView addGestureRecognizer:gesture];
    
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coldWalletKeyTypePressed)];
    [_privateKeyTypeView addGestureRecognizer:gesture];
    
    
    self.walletNameTextField.placeholder=@"Name of wallet";
    self.privateKeyTextField.placeholder=@"Private key";
    [self validateCreateUpdateButton];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _createUpdateButtonWidth.constant=280;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coldStorageBackupFinished:) name:@"ColdStorageBackupFinished" object:nil];
    
    [self pressedWalletTypeButton:_walletNewButton];
    
    [self adjustThinLines];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];;
    [self setBackButton];
    self.observeKeyboardEvents=YES;
    
    if(coldWalletKeyTypePresenter)
    {
        if(coldWalletKeyTypePresenter.is256Bit!=currentIs256ColdFlag)
        {
            _addressLabel.text=@"";
            [self validateCreateUpdateButton];
            [_createUpdateButton setTitle:@"PROCEED" forState:UIControlStateNormal];
        }
        if(coldWalletKeyTypePresenter.is256Bit)
            _privateKeyTypeLabel.text=@"256 bit / 24 words";
        else
            _privateKeyTypeLabel.text=@"128 bit / 12 words";
        currentIs256ColdFlag=coldWalletKeyTypePresenter.is256Bit;
    }
    else
        currentIs256ColdFlag=YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coldStorageBackupFinished:) name:@"ColdStorageBackupFinished" object:nil];
    

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    self.walletColdButton.layer.cornerRadius=self.walletColdButton.bounds.size.height/2;
    
}

-(void) pressedWalletTypeButton:(UIButton *) button
{
    if(button.selected)
        return;
    
    self.walletNewButton.selected=NO;
    self.walletExistingButton.selected=NO;
    self.walletColdButton.selected=NO;
    button.selected=YES;
    
    
    NSString *createUpdateButtonTitle;
    
    if(button==self.walletNewButton)
    {
        self.privateKeyTextField.text=[[LWPrivateKeyManager shared] availableSecondaryPrivateKey];
        self.addressLabel.text=[LWPrivateKeyManager addressFromPrivateKeyWIF:self.privateKeyTextField.text];
        self.privateKeyTextField.userInteractionEnabled=NO;
        
        self.scanQRView.hidden=YES;
        self.scanQRHeightConstraint.constant=10;
        _privateKeyContainerView.hidden=YES;
        _privateKeyContainerHeightConstraint.constant=0;
        self.keyPasteWidthConstraint.active=YES;
        
        _privateKeyTypeView.hidden=YES;
        _privateKeyTypeContainerHeightConstraint.constant=0;
        
        NSString *sss=self.addressLabel.text;
        
        
                createUpdateButtonTitle=@"CREATE WALLET";
        
        _descriptionLabel.text=@"This is a private wallet, a secure backup of the private key and its is guaranteed with 12 words from a backup";
        
        NSLog(@"%@", sss);
    }
    else if(button==self.walletExistingButton)
    {
        self.addressLabel.text=@"";
        self.privateKeyTextField.text=@"";
        self.privateKeyTextField.userInteractionEnabled=YES;
        self.scanQRView.hidden=NO;
        self.scanQRHeightConstraint.constant=54;
        
        _privateKeyContainerView.hidden=NO;
        _privateKeyContainerHeightConstraint.constant=45;
        
        _privateKeyTypeView.hidden=YES;
        _privateKeyTypeContainerHeightConstraint.constant=0;

        
        self.keyPasteWidthConstraint.active=NO;
        createUpdateButtonTitle=@"ADD WALLET";
        
        _descriptionLabel.text=@"Import any external personal wallet, use your private key for transfers and reference to Lykke Wallet";
        


    }
    else
    {
        self.privateKeyTextField.text=@"";
        self.addressLabel.text=@"";
        self.privateKeyTextField.userInteractionEnabled=NO;
        
        self.scanQRView.hidden=YES;
        self.scanQRHeightConstraint.constant=10;
        _privateKeyContainerView.hidden=YES;
        _privateKeyContainerHeightConstraint.constant=0;
        self.keyPasteWidthConstraint.active=YES;
        
        _privateKeyTypeView.hidden=NO;
        _privateKeyTypeContainerHeightConstraint.constant=70;


        createUpdateButtonTitle=@"PROCEED";

        
        _descriptionLabel.text=@"The private key will be generated but will not be stored in Lykke Wallet";
    }
    
    
    _padlockWidthConstraint.active=YES;
    
//    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
//    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];

    [_createUpdateButton setTitle:createUpdateButtonTitle forState:UIControlStateNormal];
    
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


-(IBAction)pasteButtonPressed:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    self.privateKeyTextField.text=string;
    [self validatePrivateKeyField];
    [self validateCreateUpdateButton];
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
        if(self.walletNameTextField.text.length && (([self.walletNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length && self.addressLabel.text.length) || _walletColdButton.selected==YES))
        {
//            [LWValidator setButton:self.createUpdateButton enabled:YES];
            _createUpdateButton.enabled=YES;
        }
        else
        {
//            [LWValidator setButton:self.createUpdateButton enabled:NO];
            _createUpdateButton.enabled=NO;
        }
        
        for(LWPrivateWalletModel *m in [LWPrivateWalletsManager shared].wallets)
        {
            if([[m.name lowercaseString] isEqualToString:walletName])
            {
//                [LWValidator setButton:self.createUpdateButton enabled:NO];
                _createUpdateButton.enabled=NO;
                break;
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
    
//    if(textField==self.walletNameTextField)
//        string=string.uppercaseString;
    
        
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField==self.privateKeyTextField)
        [self validatePrivateKeyField];
//    else if(textField==self.walletNameTextField)
//    {
        [self validateCreateUpdateButton];
//    }
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
        view.frame=window.bounds;

        
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
        if(_walletColdButton.selected && _addressLabel.text.length==0)
        {
            LWGenerateKeyPresenter *presenter=[[LWGenerateKeyPresenter alloc] init];
            presenter.flagSkipIntro=NO;
            presenter.delegate=self;
            presenter.backupMode=BACKUP_MODE_COLD_STORAGE;

            [self.navigationController pushViewController:presenter animated:YES];
            
            return;
        }
        
        
        LWPrivateWalletModel *wallet=[[LWPrivateWalletModel alloc] init];
        wallet.address=self.addressLabel.text;
        wallet.privateKey=self.privateKeyTextField.text;
        wallet.name=self.walletNameTextField.text;
        
        if(_walletExistingButton.selected)
        {
            wallet.isExternalWallet=YES;
            wallet.encryptedKey=[[LWPrivateKeyManager shared] encryptExternalWalletKey:wallet.privateKey];
        }
        else if(_walletColdButton.selected)
        {
            wallet.isExternalWallet=YES;
            wallet.isColdStorageWallet=YES;
        }
//        wallet.encryptedKey=[[LWPrivateKeyManager shared] encryptKey:wallet.privateKey password:[LWKeychainManager instance].password];
        [[LWPrivateWalletsManager shared] addNewWallet:wallet withCompletion:^(BOOL success){
            [self setLoading:NO];
            if(success)
            {
//                [[LWKeychainManager instance] savePrivateKey:wallet.privateKey forWalletAddress:wallet.address];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

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

-(void) coldWalletKeyTypePressed
{
    if(!coldWalletKeyTypePresenter)
    {
        coldWalletKeyTypePresenter=[LWColdWalletKeyTypePresenter new];
        coldWalletKeyTypePresenter.is256Bit=YES;
    }
    [self.navigationController pushViewController:coldWalletKeyTypePresenter animated:YES];
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    self.scrollViewBottomConstraint.constant=0;
}

-(void) generateKeyPresenterFinished:(LWGenerateKeyPresenter *)vc
{
    [self.navigationController popViewControllerAnimated:NO];
    
    LWBackupGetStartedPresenter *presenter=[[LWBackupGetStartedPresenter alloc] init];
    presenter.backupMode=BACKUP_MODE_COLD_STORAGE;
    if(!coldWalletKeyTypePresenter || coldWalletKeyTypePresenter.is256Bit)
        presenter.seedWords=[LWPrivateKeyManager generateSeedWords24];
    else
        presenter.seedWords=[LWPrivateKeyManager generateSeedWords12];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

-(void) coldStorageBackupFinished:(NSNotification *) notification
{
    LWBackupCheckWordsPresenter *vc=notification.object;
    NSArray *words=vc.wordsList;
    NSLog(@"%@", words);
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
    NSMutableArray *controllers=[self.navigationController.viewControllers mutableCopy];
    while(controllers.lastObject!=self)
    {
        [controllers removeLastObject];
    }
    [self.navigationController setViewControllers:controllers];
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    BTCKey *key=[[BTCKey alloc] initWithPrivateKey:[LWPrivateKeyManager keyDataFromSeedWords:words]];
    
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
    [self validateCreateUpdateButton];
    [_createUpdateButton setTitle:@"CREATE WALLET" forState:UIControlStateNormal];
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
