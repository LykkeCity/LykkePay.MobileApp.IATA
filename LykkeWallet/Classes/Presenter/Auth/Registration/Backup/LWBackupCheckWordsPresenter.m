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

@interface LWBackupCheckWordsPresenter () <UITextFieldDelegate>
{
    CGFloat keyboardHeight;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@end

@implementation LWBackupCheckWordsPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate=self;
    self.textField.placeholder=@"Words";
    
    NSDictionary *attributesDisabled=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:15], NSKernAttributeName:@(1), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};
    
    NSDictionary *attributesEnabled=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:15], NSKernAttributeName:@(1), NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.submitButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"SUBMIT" attributes:attributesDisabled] forState:UIControlStateDisabled];
    [self.submitButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"SUBMIT" attributes:attributesEnabled] forState:UIControlStateNormal];
    
    self.submitButton.clipsToBounds=YES;
    [LWValidator setButton:self.submitButton enabled:NO];
    
    [self.submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.observeKeyboardEvents=YES;
    self.title=@"BACKUP";
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextPosition *beginning = textField.beginningOfDocument;
    UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textField positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];
    
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
                [LWValidator setButton:self.submitButton enabled:YES];

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

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.submitButton.layer.cornerRadius=self.submitButton.bounds.size.height/2;
    [self.scrollViewTopConstraint setConstant:(self.view.bounds.size.height-keyboardHeight-self.scrollView.bounds.size.height)/2];
}


-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
 //   [self.view layoutIfNeeded];
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight=frame.size.height;
    
    [self.scrollViewTopConstraint setConstant:(self.view.bounds.size.height-keyboardHeight-self.scrollView.bounds.size.height)/2];

    [UIView animateWithDuration:0.8 animations:^{
    [self.view layoutIfNeeded];
    }];

}

-(void) observeKeyboardWillHideNotification:(NSNotification *)notification
{
//    [self.view layoutIfNeeded];
    keyboardHeight=0;
    [self.scrollViewTopConstraint setConstant:(self.view.bounds.size.height-keyboardHeight-self.scrollView.bounds.size.height)/2];

    [UIView animateWithDuration:0.8 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void) submitButtonPressed
{
    BOOL result=[[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:self.wordsList];
    if(!result)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self setLoading:YES];
    [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];


}

-(void) authManagerDidSendClientKeys:(LWAuthManager *)manager
{
    [self setLoading:NO];
    LWBackupSuccessPresenter *presenter=[[LWBackupSuccessPresenter alloc] init];
    
    [self.navigationController pushViewController:presenter animated:YES];

}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
 
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
