//
//  LWBackupCheckWordsPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupCheckWordsPresenter.h"
#import "LWValidator.h"
#import "LWAuthNavigationController.h"
#import "LWBackupSuccessPresenter.h"
#import "LWPrivateKeyManager.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWWalletMigrationModel.h"

@interface LWBackupCheckWordsPresenter () <UITextFieldDelegate>
{
    CGFloat keyboardHeight;
    NSString *oldEncodedPrivateKey;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitWidthConstraint;


@end

@implementation LWBackupCheckWordsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate=self;
    self.textField.placeholder=@"Words";
    
    _submitButton.enabled=NO;
    [self.submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    if([UIScreen mainScreen].bounds.size.width==320)
        _submitWidthConstraint.constant=280;
    

    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.observeKeyboardEvents=YES;
    self.title=@"BACK UP";
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
//    UITextPosition *end = [textField positionFromPosition:start offset:range.length];
//    UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];
    
    // this will be the new cursor location after insert/paste/typing
    NSInteger cursorOffset = [textField offsetFromPosition:beginning toPosition:start] + string.length;
    
    
    NSString *newStr=[textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *arr=[newStr componentsSeparatedByString:@" "];
    NSMutableAttributedString *attrstring=[[NSMutableAttributedString alloc] init];
    
    NSDictionary *greenAttributes=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:19.0/255 green:183.0/255 blue:42.0/255 alpha:1]};
    NSDictionary *redAttributes=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:17], NSForegroundColorAttributeName:[UIColor redColor]};
    NSDictionary *blackAttributes=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    
    BOOL flagOK=YES;
    
    for(int i=0;i<arr.count;i++)
    {
        NSString *s=arr[i];
        if(i<self.wordsList.count && [s isEqualToString:self.wordsList[i]]==NO)
            flagOK=NO;
        
            
        NSAttributedString *str;
        if(i!=arr.count-1)
        {
            if(flagOK)
                str=[[NSAttributedString alloc] initWithString:[s stringByAppendingString:@" "] attributes:greenAttributes];
            else
                str=[[NSAttributedString alloc] initWithString:[s stringByAppendingString:@" "] attributes:redAttributes];
        }
        else
        {
            if(flagOK && i==self.wordsList.count-1)
            {
                str=[[NSAttributedString alloc] initWithString:s attributes:greenAttributes];
                [self.textField resignFirstResponder];
                self.textField.userInteractionEnabled=NO;
                _submitButton.enabled=YES;

            }
            else
                str=[[NSAttributedString alloc] initWithString:s attributes:blackAttributes];
        }
        
        [attrstring appendAttributedString:str];//afford build gentle feed hand what book milk tragic over cushion nut

    }
    textField.attributedText=attrstring;
    
    
    UITextPosition *newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
    UITextRange *newSelectedRange = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
    [textField setSelectedTextRange:newSelectedRange];

    
    return NO;
    
}

-(void) crossCloseButtonPressed
{
    if([super shouldDismissIpadModalViewController]==NO)
        return;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        UIViewController *firstController=[self.navigationController.viewControllers firstObject];
        if([firstController isKindOfClass:[UITabBarController class]])
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
        
    }
    else
    {
        [super crossCloseButtonPressed];
    }
    
    
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.scrollViewBottomConstraint setConstant:keyboardHeight];
}


-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
 //   [self.view layoutIfNeeded];
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardHeight=frame.size.height;
    
    
    UIWindow *window=self.view.window;
    CGPoint point=[window convertPoint:CGPointMake(0, window.bounds.size.height-frame.size.height) toView:self.view];

    keyboardHeight=self.view.bounds.size.height-point.y;
    
    [self.scrollViewBottomConstraint setConstant:keyboardHeight];

    [UIView animateWithDuration:0.8 animations:^{
    [self.view layoutIfNeeded];
    }];

}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
//    [self.view layoutIfNeeded];
    keyboardHeight=0;
    [self.scrollViewBottomConstraint setConstant:keyboardHeight];

    [UIView animateWithDuration:0.8 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void) submitButtonPressed
{
    if([LWPrivateKeyManager shared].wifPrivateKeyLykke && ![LWPrivateKeyManager shared].privateKeyWords)
    {
        [self setLoading:YES];
        oldEncodedPrivateKey=[LWPrivateKeyManager shared].encryptedKeyLykke;
        LWWalletMigrationModel *model=[[LWWalletMigrationModel alloc] init];
        model.fromPrivateKey=[[LWPrivateKeyManager shared] wifPrivateKeyLykke];
        
        [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:self.wordsList];
        model.toPrivateKey=[[LWPrivateKeyManager shared] wifPrivateKeyLykke];
        model.toEncodedPrivateKey=[LWPrivateKeyManager shared].encryptedKeyLykke;
        model.toPubKey=[[LWPrivateKeyManager shared] publicKeyLykke];
        [[LWAuthManager instance] requestWalletMigration:model];
        return;
    }
    
//    
//    
//    BOOL flagHasKey=[LWPrivateKeyManager shared].privateKeyLykke;
//    BOOL result=YES;
//    if(!flagHasKey)
//        result=[[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:self.wordsList];
//    if(!result)
//    {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    
//    if(flagHasKey==NO)
//    {
//        [self setLoading:YES];
//        [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];
//    }
//    else
        [self saveBackupStateAndShowSuccess];

}

-(void) saveBackupStateAndShowSuccess
{
    [[LWAuthManager instance] requestSaveBackupState];
    
    [self showSuccess];
}

-(void) showSuccess
{
    LWBackupSuccessPresenter *presenter=[[LWBackupSuccessPresenter alloc] init];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        UINavigationController *parent=(UINavigationController *)[self.navigationController presentingViewController];
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [parent pushViewController:presenter animated:NO];
            
        }];
    }

}

-(void) authManagerDidSendClientKeys:(LWAuthManager *)manager
{
    [self setLoading:NO];
    [self saveBackupStateAndShowSuccess];
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    if(oldEncodedPrivateKey)
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:oldEncodedPrivateKey];
 
}

-(void) authManagerDidCompleteWalletMigration:(LWAuthManager *)manager
{
    [self setLoading:NO];
    [self showSuccess];
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"CONGRATULATIONS" message:@"Your wallets migration has been successfully completed. Now you can proceed with the backup of your private key." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//
//    [alert show];
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
