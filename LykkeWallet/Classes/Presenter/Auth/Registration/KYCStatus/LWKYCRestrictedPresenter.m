//
//  LWKYCRestrictedPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCRestrictedPresenter.h"
#import "LWKeychainManager.h"


@interface LWKYCRestrictedPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;

@end


@implementation LWKYCRestrictedPresenter


#pragma mark - LWAuthStepPresenter

- (void)localize {
    self.headerLabel.text = Localize(@"register.kyc.restricted.header");
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.restricted"),
                           [LWKeychainManager instance].fullName];
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterKYCRestricted;
}

@end
