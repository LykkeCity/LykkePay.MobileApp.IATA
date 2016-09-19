//
//  LWSettingsConfirmationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSettingsConfirmationPresenter.h"

#import "UIViewController+Loading.h"

#import "LWPINPresenter.h"

#import "LWKeychainManager.h"



@interface LWSettingsConfirmationPresenter ()  {
    
}
@end


@implementation LWSettingsConfirmationPresenter



#pragma mark - LWAuthStepPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LWPINPresenter *pin=[LWPINPresenter new];
    pin.successBlock=^{
        [self.delegate operationConfirmed:self];
        [self.navigationController popViewControllerAnimated:YES];
    };
    pin.pinType=PIN_TYPE_CHECK;
    pin.checkBlock = ^BOOL(NSString *pin_) {
        
        return [pin_ isEqualToString:[[LWKeychainManager instance] pin]];
        
      };
    
    pin.view.frame=self.view.bounds;
    pin.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:pin.view];
    [self addChildViewController:pin];
}


@end
