//
//  LWRegisterBasePresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthStepPresenter.h"

@class LWTextField;


@interface LWRegisterBasePresenter : LWAuthStepPresenter {
    
}

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (copy, nonatomic) LWRegistrationData *registrationInfo;

@property (readonly, nonatomic) NSString   *fieldPlaceholder;
@property (readonly, nonatomic) LWAuthStep nextStep;
@property (readonly, nonatomic) BOOL       canProceed;


#pragma mark - Navigation

- (void)proceedToNextStep;
- (void)prepareNextStepData:(NSString *)input;


#pragma mark - Utils

- (BOOL)validateInput:(NSString *)input;
- (void)configureTextField:(LWTextField *)textField;
- (NSString *)textFieldString;

@end
