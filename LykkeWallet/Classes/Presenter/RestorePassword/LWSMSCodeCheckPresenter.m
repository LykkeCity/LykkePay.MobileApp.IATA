//
//  LWSMSCodeCheckPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSMSCodeCheckPresenter.h"
#import "LWNumbersKeyboardView.h"
#import "LWCommonButton.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"
#import "LWPrivateKeyManager.h"
#import "LWRecoveryPasswordModel.h"
#import "LWResultPresenter.h"
#import "LWPrivateKeyOwnershipMessage.h"
#import "UIView+Toast.h"
#import "LWSMSTimerView.h"
#import "LWRequestCallMessageView.h"


@interface LWSMSCodeCheckPresenter () <UITextFieldDelegate, LWNumbersKeyboardViewDelegate, UIGestureRecognizerDelegate, LWResultPresenterDelegate,LWSMSTimerViewDelegate>
{
    BOOL keyboardIsShowing;
    LWNumbersKeyboardView *keyboard;
    
    UIImageView *imageViewScreenshot;

}



@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet LWCommonButton *proceedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconValid;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet LWSMSTimerView *smsTimerView;


@end

@implementation LWSMSCodeCheckPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    keyboardIsShowing=NO;
    
    keyboard=[[LWNumbersKeyboardView alloc] init];
    keyboard.delegate=self;
    keyboard.textField=self.textField;
    keyboard.showSMSCodeCursor=YES;
    [self.view addSubview:keyboard];
    keyboard.cursor.hidden=YES;
    
    _smsTimerView.delegate=self;
    
    _textField.placeholder=@"Code";
    
    self.textField.delegate=self;
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideNumbersKeyboard)];
    gesture.delegate=self;
    [self.view addGestureRecognizer:gesture];
    
    self.proceedButton.type=BUTTON_TYPE_COLORED;
    self.proceedButton.enabled=NO;
    [self.proceedButton addTarget:self action:@selector(proceedPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.recModel.phoneNumber)
    {
        self.textLabel.text=[NSString stringWithFormat:@"Please enter the 4-digit code that we just sent to your phone %@", self.recModel.phoneNumber];
    }
    // Do any additional setup after loading the view from its nib.
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!keyboardIsShowing)
        [self showNumbersKeyboard];
    return NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
    self.navigationController.navigationBar.barTintColor = BAR_GRAY_COLOR;
    self.observeKeyboardEvents=YES;
    [_smsTimerView viewWillAppear];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor=[UIColor whiteColor];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"RESET PASSWORD";
    
    
//    if(!self.recModel.securityMessage2)
//    {

 //       [[LWAuthManager instance] requestRecoverySMSConfirmation:self.recModel];
    if([_smsTimerView isTimerRunnig]==NO)
    {
        [self resendSMS];
        [self setLoading:YES];

    }
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showNumbersKeyboard
{
    keyboard.frame=CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0.776*self.view.bounds.size.width);
    self.scrollViewBottomConstraint.constant=keyboard.bounds.size.height;

    [keyboard layoutSubviews];
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y-keyboard.bounds.size.height);
        [self.view layoutIfNeeded];
    }];
    keyboardIsShowing=YES;
    keyboard.cursor.hidden=NO;
}

-(void) proceedPressed
{
    [self setLoading:YES];
    self.recModel.smsCode=self.textField.text;
    [[LWAuthManager instance] requestChangePINAndPassword:self.recModel];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(keyboard.frame, location)) {
        return NO;
    }
    return YES;
}

-(void) numbersKeyboardChangedText:(LWNumbersKeyboardView *) keyboard
{
    self.iconValid.hidden=YES;
    if(self.textField.text.length==4)
    {
        self.proceedButton.enabled=YES;
        
    }
    else
        self.proceedButton.enabled=NO;
}

-(void) smsTimerViewPressedResend:(LWSMSTimerView *)view
{
    [self resendSMS];
}

-(void) smsTimerViewPressedRequestVoiceCall:(LWSMSTimerView *)view
{
    [self setLoading:YES];
    [[LWAuthManager instance] requestVoiceCall:nil email:self.recModel.email];
}

-(void) resendSMS
{
    [self setLoading:YES];
    [[LWAuthManager instance] requestPrivateKeyOwnershipMessage:self.recModel.email];

}

-(void) authManager:(LWAuthManager *) manager didGetPrivateKeyOwnershipMessage:(LWPrivateKeyOwnershipMessage *)packet
{
    
    self.recModel.securityMessage1=packet.ownershipMessage;
    self.recModel.signature1=[[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:self.recModel.securityMessage1];
    [[LWAuthManager instance] requestRecoverySMSConfirmation:self.recModel];
}


-(void) authManagerDidChangePINAndPassword:(LWAuthManager *)manager
{
    [self setLoading:NO];
    
    LWResultPresenter *presenter=[[LWResultPresenter alloc] init];
    presenter.delegate=self;
    presenter.buttonTitle=@"GO TO LOGIN";
    presenter.titleString=@"SUCCESSFULL!";
    presenter.textString=@"Great! Your password and the PIN changed. You can log in to the app.";
    presenter.image=[UIImage imageNamed:@"WithdrawSuccessFlag.png"];
    [self.navigationController presentViewController:presenter animated:YES completion:nil];
    
}

-(void) resultPresenterWillDismiss
{

    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    imageViewScreenshot=[[UIImageView alloc] initWithFrame:window.bounds];
    imageViewScreenshot.image=[self imageFromWindow];
    [window addSubview:imageViewScreenshot];
    
}

-(void) resultPresenterDismissed
{
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController popToRootViewControllerAnimated:NO];
    else
    {
        UINavigationController *parentNav=(UINavigationController *)self.navigationController.presentingViewController;
        
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [parentNav popToRootViewControllerAnimated:NO];
            
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageViewScreenshot removeFromSuperview];
    });
}


-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    if(reject[@"Code"] && [reject[@"Code"] intValue]==8)
    {
        self.iconValid.hidden=NO;
    }
    else
        [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
    
}

-(void) authManagerDidRequestVoiceCall:(LWAuthManager *)manager
{
    [self setLoading:NO];
    
    LWRequestCallMessageView *vvv=[[NSBundle mainBundle] loadNibNamed:@"LWRequestCallMessageView" owner:self options:nil][0];
    
    UIWindow *window=self.view.window;
    vvv.frame=window.bounds;
    [window addSubview:vvv];
    [vvv showWithCompletion:nil];

}


-(void) authManagerDidGetRecoverySMSConfirmation:(LWAuthManager *)manager
{
    [self setLoading:NO];
    if(self.recModel.signature2)
        [_smsTimerView startTimer];

    
    self.recModel.signature2=[[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:self.recModel.securityMessage2];
    [self.view makeToast:@"SMS sent"];
    self.textField.text=@"";
    self.iconValid.hidden=YES;
    
    if(self.recModel.phoneNumber)
    {
        self.textLabel.text=[NSString stringWithFormat:@"Please enter the 4-digit code that we just sent to your phone %@", self.recModel.phoneNumber];
    }
    

}




-(void) hideNumbersKeyboard
{
    self.scrollViewBottomConstraint.constant=0;
    
    [UIView animateWithDuration:0.3 animations:^{
        keyboard.center=CGPointMake(keyboard.center.x, keyboard.center.y+keyboard.bounds.size.height);
        [self.view layoutIfNeeded];
    }];
    keyboardIsShowing=NO;
    keyboard.cursor.hidden=YES;
}

-(void) numbersKeyboardViewPressedDone
{
    [self hideNumbersKeyboard];
}

- (UIImage *)imageFromWindow
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



@end
