//
//  LWRestoreFromSeedPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRestoreFromSeedPresenter.h"
#import "LWCommonButton.h"
#import "LWPrivateKeyManager.h"
#import "LWEnterNewPasswordPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWRecoveryPasswordModel.h"
#import "LWAuthManager.h"
#import "LWPrivateKeyOwnershipMessage.h"
#import "UIViewController+Loading.h"
#import "LWResultPresenter.h"

@interface LWRestoreFromSeedPresenter () <UITextFieldDelegate>
{
    
    
}

@property (weak, nonatomic) IBOutlet LWCommonButton *proceedButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconInvalid;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@end

@implementation LWRestoreFromSeedPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proceedButton.type=BUTTON_TYPE_COLORED;
    self.textField.delegate=self;
    self.proceedButton.enabled=NO;
    self.textField.placeholder=@"Words";
    [self.proceedButton addTarget:self action:@selector(proceedPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCrossCloseButton];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.observeKeyboardEvents=YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_backupMode==BACKUP_MODE_PRIVATE_KEY)
        self.title=@"RESET PASSWORD";
    else if(_backupMode==BACKUP_MODE_COLD_STORAGE)
        self.title=@"DEFROST COLD WALLET";
    
//    if(presenter)
//        return;
//    presenter=[[LWResultPresenter alloc] init];
//    presenter.delegate=self;
//    presenter.buttonTitle=@"GO TO LOGIN";
//    presenter.titleString=@"SUCCESSFULL!";
//    presenter.textString=@"Great! Your password and the PIN changed. You can log in to the app.";
//    presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
//    [self.navigationController presentViewController:presenter animated:YES completion:nil];
//
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

-(void) crossCloseButtonPressed
{
    if(_backupMode==BACKUP_MODE_COLD_STORAGE)
        [self.navigationController popViewControllerAnimated:NO];
    else
        [super crossCloseButtonPressed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textField positionFromPosition:start offset:range.length];
    
    
    // this will be the new cursor location after insert/paste/typing
    NSInteger cursorOffset = [textField offsetFromPosition:beginning toPosition:start] + string.length;
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
//    if(self.iconInvalid.hidden==NO)
//        self.iconInvalid.hidden=YES;
    
    NSArray *arr=[textField.text componentsSeparatedByString:@" "];
    if((arr.count==12 || arr.count==24) && [arr.lastObject length] && [LWPrivateKeyManager keyDataFromSeedWords:arr])
    {
        if(_backupMode==BACKUP_MODE_PRIVATE_KEY)
        {
            [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[_textField.text componentsSeparatedByString:@" "]];
        }
        
        self.proceedButton.enabled=YES;
        
        [textField resignFirstResponder];
        
        self.iconInvalid.hidden=NO;


    }
    else
    {
        self.iconInvalid.hidden=YES;

        self.proceedButton.enabled=NO;
    }
    
    UITextPosition *newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
    UITextRange *newSelectedRange = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
    [textField setSelectedTextRange:newSelectedRange];

    
    return NO;
}

-(void) proceedPressed
{
//    if([[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[_textField.text componentsSeparatedByString:@" "]])
//    {
    if(_backupMode==BACKUP_MODE_PRIVATE_KEY)
    {
        [self setLoading:YES];
        [[LWAuthManager instance] requestPrivateKeyOwnershipMessage:self.email];

    }
    else if(_backupMode==BACKUP_MODE_COLD_STORAGE && [self.delegate respondsToSelector:@selector(restoreFromSeed:restoredKey:)])
    {
        NSData *key=[LWPrivateKeyManager keyDataFromSeedWords:[_textField.text componentsSeparatedByString:@" "]];
        NSString *wifKey=[LWPrivateKeyManager wifKeyFromData:key];
        
        [self.delegate restoreFromSeed:self restoredKey:wifKey];

    }
    
    
 
//    }
//    else
//    {
////        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Private key recovering failed! Please check seed words." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////        [alert show];
//        self.iconInvalid.hidden=NO;
//    }
//    
    
    

}

-(void) authManager:(LWAuthManager *) manager didGetPrivateKeyOwnershipMessage:(LWPrivateKeyOwnershipMessage *)packet
{
    if(packet.signature)
    {
        [self setLoading:NO];
        
        if(packet.confirmedOwnership)
        {
            LWRecoveryPasswordModel *recModel=[[LWRecoveryPasswordModel alloc] init];
            //        recModel.securityMessage1=packet.ownershipMessage;
            recModel.email=self.email;
            
            LWEnterNewPasswordPresenter *presenter=[[LWEnterNewPasswordPresenter alloc] init];
            presenter.recModel=recModel;
            [self.navigationController pushViewController:presenter animated:YES];

        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"These seed words are not corresponding to your private key." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
//        NSString *address=[LWPrivateKeyManager addressFromPrivateKeyWIF:[LWPrivateKeyManager shared].wifPrivateKeyLykke];
//        
//        recModel.signature1=[[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:recModel.securityMessage1];
        

    }
    else
    {
        NSString *signature=[[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:packet.ownershipMessage];
        [[LWAuthManager instance] requestCheckPrivateKeyOwnershipMessageSignature:signature email:self.email];
    }
    
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];

    [self showReject:reject response:context.task.response];
}

-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
    [self.view layoutIfNeeded];
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGFloat height=frame.size.height;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        CGPoint point=[self.view convertPoint:CGPointMake(0, self.view.bounds.size.height) toView:window];
        height=height-(window.bounds.size.height-point.y);
    }
    
    [UIView animateWithDuration:0.7 animations:^{
        self.scrollViewBottomConstraint.constant=height;

        [self.view layoutIfNeeded];
        }];
}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{

        self.scrollViewBottomConstraint.constant=0;
        [self.view layoutIfNeeded];
    }];
}





@end
