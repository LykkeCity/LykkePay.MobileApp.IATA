//
//  LWWalletConfirmPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletConfirmPresenter.h"


@interface LWWalletConfirmPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end


@implementation LWWalletConfirmPresenter


#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)localize {
    self.titleLabel.text = Localize(@"wallets.confirm.title");
    self.descriptionLabel.text = Localize(@"wallets.confirm.description");
    self.continueButton.titleLabel.text = Localize(@"wallets.confirm.continue");
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif

- (IBAction)continueClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
