//
//  LWCreateEditPrivateWalletPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEditPrivateWalletPresenter.h"
#import "LWPrivateKeyManager.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWPrivateWalletModel.h"
#import "LWCommonButton.h"
#import "LWPrivateWalletAddressPresenter.h"

#import "LWKeychainManager.h"
#import "LWPrivateWalletsManager.h"
#import "LWRestoreFromSeedPresenter.h"
#import "LWResultPresenter.h"



#import "LWIPadModalNavigationControllerViewController.h"
#import "LWBackupCheckWordsPresenter.h"

@import AVFoundation;

#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]

@interface LWEditPrivateWalletPresenter () <UITextFieldDelegate, LWRestoreFromSeedDelegate>
{
    NSDictionary *createButtonEnabledAttributes;
    NSDictionary *buttonDisabledAttributes;
    BOOL flagColoredAddress;
    UIButton *doneButton;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *privateKeyTextField;
@property (weak, nonatomic) IBOutlet LWCommonButton *defrostButton;
@property (weak, nonatomic) IBOutlet UILabel *defrostLabel;
@property (weak, nonatomic) IBOutlet UIView *addressView;



@property (weak, nonatomic) IBOutlet UIButton *padlockButton;


@property (weak, nonatomic) IBOutlet UIButton *keyCopyButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;





@property (weak, nonatomic) IBOutlet UIView *privateKeyContainerView;

@property (strong, nonatomic) NSLayoutConstraint *padlockWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *keyCopyWidthConstraint;




@property (weak, nonatomic) IBOutlet NSLayoutConstraint *walletNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privateKeyContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distBetweenTextContainersConstraint;


@end

@implementation LWEditPrivateWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    flagColoredAddress=NO;
    
    
    UIView *grayView=[[UIView alloc] initWithFrame:CGRectMake(0, -500, 1024, 500)];
    grayView.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    [self.scrollView addSubview:grayView];
    

    self.padlockWidthConstraint=[NSLayoutConstraint constraintWithItem:self.padlockButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.padlockButton addConstraint:_padlockWidthConstraint];

    self.keyCopyWidthConstraint=[NSLayoutConstraint constraintWithItem:self.keyCopyButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.keyCopyButton addConstraint:_keyCopyWidthConstraint];
    
 
    NSString *createUpdateButtonTitle;
    
    
        if(_wallet.isExternalWallet==NO || _wallet.isColdStorageWallet)
        {
            _privateKeyContainerView.hidden=YES;
            _privateKeyContainerHeightConstraint.constant=0;
            _distBetweenTextContainersConstraint.constant=0;
            
        }
    
    if([_wallet.address isEqualToString:[LWPrivateKeyManager addressFromPrivateKeyWIF:[LWPrivateKeyManager shared].wifPrivateKeyLykke]])
    {
        _walletNameTextField.userInteractionEnabled=NO;
        _titleLabel.text=@"";
    }
    
    if(_wallet.isColdStorageWallet==NO)
    {
        _defrostButton.hidden=YES;
        _defrostLabel.hidden=YES;
    }
    
        self.walletNameTextField.text=self.wallet.name;
    
        self.privateKeyTextField.text=self.wallet.privateKey;
        self.privateKeyTextField.secureTextEntry=YES;
        
        self.padlockWidthConstraint.active=NO;
    
//    self.keyPasteWidthConstraint.constant=0;

    self.privateKeyTextField.delegate=self;
    self.walletNameTextField.delegate=self;
    self.privateKeyTextField.userInteractionEnabled=NO;

    
    
    self.walletNameTextField.placeholder=@"Name of wallet";
    self.privateKeyTextField.placeholder=@"Private key";
    
    [self adjustThinLines];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton=button;
    doneButton.hidden=YES;
    button.frame = CGRectMake(0, 0, 45, 32);
    
    NSDictionary *attr=@{NSKernAttributeName:@(1.2), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]};
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"DONE" attributes:attr] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.rightBarButtonItem=barButton;

    _defrostButton.type=BUTTON_TYPE_CLEAR;
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressPressed)];
    [_addressView addGestureRecognizer:gesture];
    
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
    
        self.title=@"EDIT WALLET";
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

-(void) doneButtonPressed
{
    if(_walletNameTextField.text.length && [_walletNameTextField.text isEqualToString:_wallet.name]==NO)
    {
        _wallet.name=_walletNameTextField.text;
        [self setLoading:YES];
        [[LWPrivateWalletsManager shared] updateWallet:_wallet withCompletion:^(BOOL success){
            [self setLoading:NO];
            if(success)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

    }
    [_walletNameTextField resignFirstResponder];

}


-(IBAction) copyButtonPressed:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=self.privateKeyTextField.text;

    [self showCopied];
}

-(IBAction)padlockPressed:(id)sender
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



-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    doneButton.hidden=NO;
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    doneButton.hidden=YES;
    _walletNameTextField.text=_wallet.name;
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
    return NO;
}

-(void) addressPressed
{
    LWPrivateWalletAddressPresenter *presenter=[LWPrivateWalletAddressPresenter new];
    presenter.wallet=_wallet;
    [self.navigationController pushViewController:presenter animated:YES];
    
}

-(IBAction)defrostButtonPressed:(id)sender
{
    
    
    LWResultPresenter *ppp=[LWResultPresenter new];
    ppp.titleString=@"SUCCESSFULL!";
    ppp.textString=@"Your cold reserve can now be used as a private wallet (Deposit and withdraw)";
    ppp.image=[UIImage imageNamed:@"SuccessIcon"];
    ppp.buttonTitle=@"BACK TO WALLETS";
    [self.navigationController pushViewController:ppp animated:YES];
    
    return;
    
    
    
    LWRestoreFromSeedPresenter *presenter=[LWRestoreFromSeedPresenter new];
    presenter.delegate=self;
    presenter.backupMode=BACKUP_MODE_COLD_STORAGE;
    [self.navigationController pushViewController:presenter animated:YES];
    
}

-(void) restoreFromSeed:(LWRestoreFromSeedPresenter *)vc restoredKey:(NSString *)keyWif
{
    [self.navigationController popViewControllerAnimated:YES];

    if([[LWPrivateKeyManager addressFromPrivateKeyWIF:keyWif] isEqualToString:_wallet.address]==NO)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Seed words you provided do not correspond to this cold wallet address!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    _wallet.privateKey=keyWif;
    _wallet.encryptedKey=[[LWPrivateKeyManager shared] encryptExternalWalletKey:keyWif];
    _wallet.isColdStorageWallet=NO;
    
    [self setLoading:YES];
    [[LWPrivateWalletsManager shared] defrostColdStorageWallet:_wallet withCompletion:^(BOOL success){
    
        [self setLoading:NO];
        if(success)
        {
            _wallet.isColdStorageWallet=NO;
            [self.navigationController popViewControllerAnimated:YES];

        }
    
    }];
}


-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    self.scrollViewBottomConstraint.constant=frame.size.height;
    
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    self.scrollViewBottomConstraint.constant=0;
}



@end
