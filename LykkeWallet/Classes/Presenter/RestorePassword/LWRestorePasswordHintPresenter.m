//
//  LWRestorePasswordHintPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRestorePasswordHintPresenter.h"
#import "LWCommonButton.h"
#import "UIViewController+Navigation.h"
#import "LWPINPresenter.h"
#import "LWRecoveryPasswordModel.h"
#import "LWSMSCodeCheckPresenter.h"
#import "UIViewController+Loading.h"
#import "LWPrivateKeyManager.h"

@interface LWRestorePasswordHintPresenter () <UITextFieldDelegate>
{
    __weak LWPINPresenter *pinBlock;
}

@property (weak, nonatomic) IBOutlet LWCommonButton *proceedButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconValid;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@end

@implementation LWRestorePasswordHintPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proceedButton.type=BUTTON_TYPE_COLORED;
    self.textField.delegate=self;
    self.textField.placeholder=@"Enter a hint";
    self.proceedButton.enabled=NO;
    [self.proceedButton addTarget:self action:@selector(proceedPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.observeKeyboardEvents=YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"RESET PASSWORD";
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
    if(textField.text.length)
    {
        self.proceedButton.enabled=YES;
        self.iconValid.hidden=NO;
    }
    else
    {
        self.proceedButton.enabled=NO;
        self.iconValid.hidden=YES;
    }
    
    return NO;
}

-(void) proceedPressed
{
    self.recModel.hint=self.textField.text;
    LWPINPresenter *pin=[[LWPINPresenter alloc] init];
    pin.pinType=PIN_TYPE_ENTER;
    pinBlock=pin;
    pin.finishBlock=^(BOOL flag, NSString *selectedPin){
        self.recModel.pin=selectedPin;
        LWSMSCodeCheckPresenter *presenter=[[LWSMSCodeCheckPresenter alloc] init];
        presenter.recModel=self.recModel;
        
        [self.navigationController pushViewController:presenter animated:YES];
        
    };
    [self.navigationController pushViewController:pin animated:YES];
    
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
