//
//  LWRegisterPhonePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterPhonePresenter.h"
#import "LWRegisterPhoneConfirmPresenter.h"
#import "LWCountrySelectorPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"
#import "LWPacketCountryCodes.h"


@interface LWRegisterPhonePresenter () <UITextFieldDelegate, LWCountrySelectorPresenterDelegate> {
    
    LWPacketCountryCodes *countries;
    
    CGRect originalSrollViewFrame;
    UIView *separator;
    
    UIButton *codeLabelButton;
}

@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) UILabel *codeLabel;
@property (strong, nonatomic) UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *phoneInputMask;

@end


@implementation LWRegisterPhonePresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    [self.nextButton setTitle:Localize(@"register.phone.send")
//                     forState:UIControlStateNormal];
    
    self.phoneInputMask.userInteractionEnabled=YES;
    self.phoneInputMask.backgroundColor=[UIColor colorWithRed:236.0/255 green:238.0/255 blue:239.0/255 alpha:1];
    self.phoneInputMask.layer.cornerRadius=3;
    
    self.codeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, self.phoneInputMask.bounds.size.height)];
    self.codeLabel.textColor=[UIColor blackColor];
    self.codeLabel.textAlignment=NSTextAlignmentRight;
    self.codeLabel.backgroundColor=nil;
    self.codeLabel.opaque=NO;
    [self.phoneInputMask addSubview:self.codeLabel];
    
    separator=[[UIView alloc] initWithFrame:CGRectMake(self.codeLabel.frame.origin.x+self.codeLabel.bounds.size.width+10, 10, 0.5, self.phoneInputMask.bounds.size.height-20)];
    separator.backgroundColor=[UIColor lightGrayColor];
    [self.phoneInputMask addSubview:separator];
    
    self.numberTextField=[[UITextField alloc] initWithFrame:CGRectMake(separator.frame.origin.x+10, 0, self.phoneInputMask.bounds.size.width-separator.frame.origin.x-20, self.phoneInputMask.bounds.size.height)];
    [self.phoneInputMask addSubview:self.numberTextField];
    
    self.numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.numberTextField.delegate = self;
    self.numberTextField.placeholder = Localize(@"register.phone.placeholder");
    
    
    [self.numberTextField addTarget:self
                             action:@selector(textFieldDidChangeValue:)
                   forControlEvents:UIControlEventEditingChanged];

    
    codeLabelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    codeLabelButton.frame=CGRectMake(0, 0, separator.frame.origin.x, self.phoneInputMask.bounds.size.height);
    [codeLabelButton addTarget:self action:@selector(countryClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.phoneInputMask addSubview:codeLabelButton];
    
    
    [[LWAuthManager instance] requestCountyCodes];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LWValidator setButton:self.nextButton enabled:[self canProceed]];
    
    self.observeKeyboardEvents = YES;

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    originalSrollViewFrame=self.scrollView.frame;
    [self.numberTextField becomeFirstResponder];
    self.title = Localize(@"title.register");

}

- (IBAction)nextClicked:(id)sender {
    if ([self canProceed]) {
        NSString *phone = [self phoneNumberWithoutPlus];
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationPhone:phone];
    }
}

- (IBAction)countryClicked:(id)sender {
    LWCountrySelectorPresenter *presenter = [LWCountrySelectorPresenter new];
    presenter.delegate = self;
    presenter.countries=countries.countries;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:presenter];

    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

-(void) updateTextFieldFrame
{
    [self.codeLabel sizeToFit];

    self.codeLabel.center=CGPointMake(self.codeLabel.bounds.size.width/2+10, self.phoneInputMask.bounds.size.height/2);
    separator.center=CGPointMake(self.codeLabel.frame.origin.x+self.codeLabel.bounds.size.width+10, self.codeLabel.center.y);
    self.numberTextField.frame=CGRectMake(separator.frame.origin.x+10, 0, self.phoneInputMask.bounds.size.width-separator.frame.origin.x-20, self.phoneInputMask.bounds.size.height);
    
    codeLabelButton.frame=CGRectMake(0, 0, separator.frame.origin.x, self.phoneInputMask.bounds.size.height);
}

#pragma mark - Keyboard


- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    if([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight)
    {
        self.scrollView.contentOffset=CGPointMake(0, 120);
        self.scrollView.scrollEnabled=NO;
    }
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled=YES;
}


//- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {      //Previously for iPhone only
//    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    
//    if(self.scrollView.frame.origin.y+self.scrollView.bounds.size.height>self.view.bounds.size.height-rect.size.height)
//        self.scrollView.frame=CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.bounds.size.width, self.view.bounds.size.height-rect.size.height-self.scrollView.frame.origin.y);
//    
//
//}
//
//- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
////    self.scrollView.contentInset = UIEdgeInsetsZero;
//    self.scrollView.frame=originalSrollViewFrame;
//}
//

#pragma mark - Properties

- (NSString *)fieldPlaceholder {
    return @"";
}

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterPhoneConfirm;
}

- (BOOL)canProceed {
    return (self.codeLabel.text.length > 0 &&
            self.numberTextField.text.length > 0);
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidChangeValue:(UITextField *)textFieldInput {
    // prevent from being processed if controller is not presented
    if (!self.isVisible) {
        return;
    }

    [LWValidator setButton:self.nextButton enabled:self.canProceed];
}


#pragma mark - LWCountrySelectorPresenterDelegate

- (void)countrySelected:(NSString *)name code:(NSString *)code prefix:(NSString *)prefix {
    self.codeLabel.text = prefix;
    [self updateTextFieldFrame];
    [self.countryButton setTitle:name forState:UIControlStateNormal];
    
    [LWValidator setButton:self.nextButton enabled:self.canProceed];
}


#pragma mark - LWAuthManagerDelegate

-(void) authManager:(LWAuthManager *)manager didGetCountryCodes:(LWPacketCountryCodes *)_countryCodes
{
    countries=_countryCodes;
    self.codeLabel.text=countries.ipLocatedCountry.prefix;
    [self.countryButton setTitle:countries.ipLocatedCountry.name forState:UIControlStateNormal];
    [self updateTextFieldFrame];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response];
}

- (void)authManagerDidSendValidationPhone:(LWAuthManager *)manager {
    // copy data to model
    [self setLoading:NO];
    LWAuthNavigationController *controller = (LWAuthNavigationController *)self.navigationController;
    [controller navigateToStep:[self nextStep]
              preparationBlock:^(LWAuthStepPresenter *presenter) {
                  LWRegisterPhoneConfirmPresenter *nextPresenter = (LWRegisterPhoneConfirmPresenter *)presenter;
                  nextPresenter.phone = [self phoneNumberWithPlus];
              }];
}

- (NSString *)phoneNumberWithoutPlus {
    NSString *phone = [NSString stringWithFormat:@"%@%@", self.codeLabel.text, self.numberTextField.text];
    phone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return phone;
}

- (NSString *)phoneNumberWithPlus {
    NSString *phone = [NSString stringWithFormat:@"%@%@", self.codeLabel.text, self.numberTextField.text];
    return phone;
}


@end
