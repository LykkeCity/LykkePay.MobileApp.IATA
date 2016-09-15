//
//  LWEnterNewPasswordPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEnterNewPasswordPresenter.h"
#import "LWRestorePasswordHintPresenter.h"
#import "LWCommonButton.h"
#import "UIViewController+Navigation.h"
#import "LWRecoveryPasswordModel.h"

@interface LWEnterNewPasswordPresenter () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet LWCommonButton *proceedButton;
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;
@property (weak, nonatomic) IBOutlet UIImageView *icon1;
@property (weak, nonatomic) IBOutlet UIImageView *icon2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;


@end

@implementation LWEnterNewPasswordPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.password1.delegate=self;
    self.password2.delegate=self;
    self.proceedButton.enabled=NO;
    self.proceedButton.type=BUTTON_TYPE_COLORED;
    
    self.password1.placeholder=@"Enter a password";
    self.password2.placeholder=@"Enter again";
    
    [self.proceedButton addTarget:self action:@selector(proceedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void) proceedButtonPressed
{
    LWRestorePasswordHintPresenter *presenter=[[LWRestorePasswordHintPresenter alloc] init];
    self.recModel.password=self.password1.text;
    presenter.recModel=self.recModel;
    [self.navigationController pushViewController:presenter animated:YES];
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(_password1.text.length>=6)
    {
        _icon1.hidden=NO;
    }
    else
        _icon1.hidden=YES;
    
    if(_password1.text.length>=6 && [_password1.text isEqualToString:_password2.text])
    {
        _icon2.image=[UIImage imageNamed:@"IconValid"];
        self.icon2.hidden=NO;
        self.proceedButton.enabled=YES;
    }
    else
    {
        self.icon2.hidden=YES;
        self.proceedButton.enabled=NO;
        if(textField==_password2)
        {
            self.icon2.hidden=NO;
            self.icon2.image=[UIImage imageNamed:@"IconInvalid"];
        }
    }
    
    
    return NO;
}

-(void) observeKeyboardWillShowNotification:(NSNotification *)notification
{
    [self.view layoutIfNeeded];
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat height=frame.size.height;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        UIWindow *window=self.view.window;
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
