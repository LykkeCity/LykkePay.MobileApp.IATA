//
//  LWPrivateWalletTransferInputPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletTransferInputPresenter.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWPrivateWalletsManager.h"
#import "LWPWTransferInputView.h"
#import "LWMathKeyboardView.h"
#import "LWValidator.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletModel.h"
#import "LWCache.h"
#import "LWPKTransferModel.h"
#import "LWTransactionManager.h"
#import "LWPKTransferConfirmationView.h"
#import "LWSettingsConfirmationPresenter.h"
#import "LWResultPresenter.h"
#import "LWPrivateWalletHistoryPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"


@interface LWPrivateWalletTransferInputPresenter () <LWMathKeyboardViewDelegate, UITextFieldDelegate, LWSettingsConfirmationPresenter, LWResultPresenterDelegate>
{
    UILabel *balanceLabel;
    NSNumber *balance;
    LWPWTransferInputView *inputView;
    UIButton *checkoutButton;
    
}

@end

@implementation LWPrivateWalletTransferInputPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    inputView=[[LWPWTransferInputView alloc] init];
    [self.view addSubview:inputView];
    inputView.textField.delegate=self;
    checkoutButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [checkoutButton addTarget:self action:@selector(checkoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [checkoutButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CHECKOUT" attributes:@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
    [checkoutButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CHECKOUT" attributes:@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]}] forState:UIControlStateDisabled];
    
    [LWValidator setButton:checkoutButton enabled:NO];
    [self.view addSubview:checkoutButton];
    
    balanceLabel=[[UILabel alloc] init];
    balanceLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    balanceLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    balanceLabel.textAlignment=NSTextAlignmentCenter;
    
    LWPrivateWalletAssetModel *asset=self.transfer.asset;
    balanceLabel.text=[NSString stringWithFormat:@"%@ %f available", asset.assetId, asset.amount.floatValue];
    [self.view addSubview:balanceLabel];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    inputView.frame=CGRectMake(0, 44, self.view.bounds.size.width, 47);
    if(self.keyboardView.isVisible==NO)
        checkoutButton.frame=CGRectMake(30, self.view.bounds.size.height-30-45, self.view.bounds.size.width-60, 45);
    [LWValidator setButton:checkoutButton enabled:checkoutButton.enabled];

    balanceLabel.frame=CGRectMake(0, 0, self.view.bounds.size.width, 20);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"TRANSFER";
//    [self setLoading:YES];
}


-(void) mathKeyboardDonePressed:(LWMathKeyboardView *)keyboardView
{
    [self hideCustomKeyboard];
}



-(void) showCustomKeyboard
{
    [super showCustomKeyboard];
    
    CGRect rrr=checkoutButton.frame;
    CGRect eee=self.keyboardView.frame;
    CGFloat keybHeight=self.keyboardView.bounds.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        
//    checkoutButton.center=CGPointMake(self.view.bounds.size.width/2, 150);
    
        checkoutButton.center=CGPointMake(self.view.bounds.size.width/2, checkoutButton.center.y-self.keyboardView.bounds.size.height);
    }];
}


-(void) hideCustomKeyboard
{
    [super hideCustomKeyboard];
    
    [UIView animateWithDuration:0.5 animations:^{
        checkoutButton.center=CGPointMake(checkoutButton.center.x, checkoutButton.center.y+self.keyboardView.bounds.size.height);
        
    } completion:^(BOOL finished){
        
    }];
    
}

- (void)mathKeyboardView:(LWMathKeyboardView *) view volumeStringChangedTo:(NSString *) string
{
    inputView.textField.text=string;
    [LWValidator setButton:checkoutButton enabled:string.floatValue>0];

}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!self.keyboardView || (self.keyboardView && self.keyboardView.isVisible==NO))
        [self showCustomKeyboard];
    
    self.keyboardView.targetTextField=textField;
    
    self.keyboardView.accuracy=@(2);
    [self.keyboardView setText:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    
    return NO;
}

-(void) checkoutButtonPressed
{
//    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;
//    if (shouldSignOrder) {
//        [self validateUser];
//    }
//    else {
//        [self showConfirmationView];
//    }
    self.transfer.amount=@(inputView.textField.text.floatValue);
    
    [LWPKTransferConfirmationView showTransfer:self.transfer withCompletion:^(BOOL result){
        if(result)
            [self signPressed];
    }];
    
    
    
}

#pragma mark - LWRadioTableViewCellDelegate

- (void) signPressed {
    LWSettingsConfirmationPresenter *validator = [LWSettingsConfirmationPresenter new];
    validator.delegate = self;
    
    [self.navigationController pushViewController:validator animated:YES];
}


#pragma mark - LWSettingsConfirmationPresenter

- (void)operationConfirmed:(LWSettingsConfirmationPresenter *)presenter {
    
    
    [[LWPrivateWalletsManager shared] requestTransferTransaction:self.transfer withCompletion:^(NSDictionary *dict) {
        if([dict isKindOfClass:[NSDictionary class]] && dict[@"Hex"])
        {
            NSString *signedTransaction=[LWTransactionManager signTransactionRaw:dict[@"Hex"] forModel:self.transfer];
            if(signedTransaction)
            {
                [[LWPrivateWalletsManager shared] broadcastTransaction:signedTransaction identity:dict[@"Id"] withCompletion:^(BOOL success){
                    [self setLoading:NO];
                    if(success)
                    {
                        LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
                        presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
                        presenter.titleString=@"SUCCESSFUL!";
                        presenter.textString=@"Your transfer transaction has been successfuly broadcasted to Blockchain. We will notify you when it will be confirmed.";
                        
                        presenter.delegate=self;
                        [self.navigationController presentViewController:presenter animated:YES completion:nil];

                    }
                    else
                        [self showFailed];
                }];
                return;
            }
            else
                [self showFailed];
        }
        else
        {
            [self showFailed];
        }
        
        [self setLoading:NO];
        
    }];
}

-(void) showFailed
{
    LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
    presenter.titleString=@"Sorry!";
    presenter.textString=@"Something went wrong.\nYour transfer transaction was unsuccessfull";
    presenter.image=[UIImage imageNamed:@"RegisterFailed"];
    
    presenter.delegate=self;
    [self.navigationController presentViewController:presenter animated:YES completion:nil];

}

-(void) resultPresenterWillDismiss
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        NSArray *array=self.navigationController.viewControllers;
        for(UIViewController *v in array)
        {
            if([v isKindOfClass:[LWPrivateWalletHistoryPresenter class]])
            {
                [self.navigationController popToViewController:v animated:NO];
                break;
            }
        }
    }
    else
    {
        self.navigationController.view.hidden=YES;
        //        [self.navigationController setViewControllers:@[]];
        [(LWIPadModalNavigationControllerViewController *)self.navigationController dismissAnimated:NO];
    }

    
}

- (void)operationRejected {
    
}



-(NSString *) nibName
{
    return nil;
}


@end
