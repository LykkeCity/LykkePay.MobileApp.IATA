//
//  LWKYCSuccessPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCSuccessPresenter.h"
#import "LWRegistrationData.h"
#import "LWKeychainManager.h"


@interface LWKYCSuccessPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender;

@end


@implementation LWKYCSuccessPresenter


#pragma mark - LWAuthStepPresenter

- (void)localize {
    self.headerLabel.text = Localize(@"register.kyc.success.header");
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.success"),
                           [LWKeychainManager instance].fullName];
    [self.okButton setTitle:[Localize(@"register.kyc.success.okButton") uppercaseString]
                   forState:UIControlStateNormal];
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterKYCSuccess;
}


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender {
    [((LWAuthNavigationController *)self.navigationController)
     navigateToStep:LWAuthStepRegisterPINSetup
     preparationBlock:nil];
}

@end
