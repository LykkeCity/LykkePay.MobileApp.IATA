//
//  LWRestorePasswordWordsPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRestorePasswordWordsPresenter.h"
#import "LWCommonButton.h"
#import "LWPrivateKeyManager.h"
#import "LWEnterNewPasswordPresenter.h"
#import "UIViewController+Navigation.h"
#import "LWRecoveryPasswordModel.h"
#import "LWAuthManager.h"
#import "LWPrivateKeyOwnershipMessage.h"
#import "UIViewController+Loading.h"
#import "LWResultPresenter.h"

@interface LWRestorePasswordWordsPresenter () <UITextFieldDelegate>
{
}

@property (weak, nonatomic) IBOutlet LWCommonButton *proceedButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconInvalid;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@end

@implementation LWRestorePasswordWordsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proceedButton.type=BUTTON_TYPE_COLORED;
    self.textField.delegate=self;
    self.proceedButton.enabled=NO;
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
    self.title=@"RESET PASSWORD";
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(self.iconInvalid.hidden==NO)
        self.iconInvalid.hidden=YES;
    
    NSArray *arr=[textField.text componentsSeparatedByString:@" "];
    if(arr.count==12 && [arr.lastObject length])
    {
        self.proceedButton.enabled=YES;
    }
    else
    {
        self.proceedButton.enabled=NO;
    }
    
    return NO;
}

-(void) proceedPressed
{
    if([[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[_textField.text componentsSeparatedByString:@" "]])
    {
        [self setLoading:YES];
        [[LWAuthManager instance] requestPrivateKeyOwnershipMessage:self.email];
 
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Private key recovering failed! Please check seed words." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
    

}

-(void) authManager:(LWAuthManager *) manager didGetPrivateKeyOwnershipMessage:(LWPrivateKeyOwnershipMessage *)packet
{
    LWRecoveryPasswordModel *recModel=[[LWRecoveryPasswordModel alloc] init];
    recModel.securityMessage1=packet.ownershipMessage;
    recModel.email=self.email;
    
    LWEnterNewPasswordPresenter *presenter=[[LWEnterNewPasswordPresenter alloc] init];
    presenter.recModel=recModel;
    
    NSString *address=[LWPrivateKeyManager addressFromPrivateKeyWIF:[LWPrivateKeyManager shared].wifPrivateKeyLykke];
    
    recModel.signature1=[[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:recModel.securityMessage1];
    
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    
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
