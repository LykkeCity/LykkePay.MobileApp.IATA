//
//  LWKYCRestrictedPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCRestrictedPresenter.h"
#import "LWKeychainManager.h"
#import "UIViewController+Navigation.h"
#import "LWCommonButton.h"


@interface LWKYCRestrictedPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (weak, nonatomic) IBOutlet LWCommonButton *button;

@end


@implementation LWKYCRestrictedPresenter

-(void) viewDidLoad
{
    [super viewDidLoad];
    if([UIScreen mainScreen].bounds.size.width==320)
        _buttonWidthConstraint.constant=280;
    _button.type=BUTTON_TYPE_CLEAR;

}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self setBackButton];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(IBAction) buttonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
