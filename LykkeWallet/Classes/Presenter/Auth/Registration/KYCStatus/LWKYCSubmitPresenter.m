//
//  LWKYCSubmitPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCSubmitPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWKeychainManager.h"
#import "UIViewController+Loading.h"


@interface LWKYCSubmitPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


#pragma mark - Actions

- (IBAction)submitButtonClick:(id)sender;

@end


@implementation LWKYCSubmitPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"register.kyc.submit.title");
}

#pragma mark - LWAuthStepPresenter

- (void)localize {
    self.headerLabel.text = Localize(@"register.kyc.submit.header");
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.submit"), [LWKeychainManager instance].fullName];
    [self.submitButton setTitle:[Localize(@"register.kyc.submit.submitButton") uppercaseString] forState:UIControlStateNormal];
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterKYCSubmit;
}


#pragma mark - Actions

- (IBAction)submitButtonClick:(id)sender {
    [[LWAuthManager instance] requestKYCStatusSet];
    [self setLoading:YES];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    if (reject) {
        [self showReject:reject response:context.task.response];
    } else {
        [self setLoading:NO];
    }
}

- (void)authManagerDidSetKYCStatus:(LWAuthManager *)manager {
    [self setLoading:NO];
    
    [((LWAuthNavigationController *)self.navigationController) navigateToStep:LWAuthStepRegisterKYCPending
                                                             preparationBlock:nil];
}

@end
