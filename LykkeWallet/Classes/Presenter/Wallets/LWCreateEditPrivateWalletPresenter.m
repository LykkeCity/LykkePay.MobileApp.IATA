//
//  LWCreateEditPrivateWalletPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCreateEditPrivateWalletPresenter.h"
#import "LWValidator.h"
#import "LWWalletsTypeButton.h"

#define TextColor [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]

@interface LWCreateEditPrivateWalletPresenter ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *walletNewButton;
@property (weak, nonatomic) IBOutlet UIButton *walletExistingButton;
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *createUpdateButton;
@property (weak, nonatomic) IBOutlet UIView *scanQRView;
@property (weak, nonatomic) IBOutlet UIButton *padlockButton;
@property (weak, nonatomic) IBOutlet UIView *modeButtonsContainer;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *padlockWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyCopyWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanQRHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *walletNameTopConstraint;


@end

@implementation LWCreateEditPrivateWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *createButtonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};

    NSDictionary *buttonDisabledAttributes = @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:TextColor};

    NSString *createUpdateButtonTitle;
    
    if(self.editMode)
    {
        self.scanQRView.hidden=YES;
        self.scanQRHeightConstraint.constant=25;
        self.modeButtonsContainer.hidden=YES;
        self.walletNameTopConstraint.constant=20;
        createUpdateButtonTitle=@"UPDATE WALLET";
        [LWValidator setButton:self.createUpdateButton enabled:YES];
    }
    else
    {
        createUpdateButtonTitle=@"CREATE WALLET";
        [LWValidator setButton:self.createUpdateButton enabled:NO];
    }
    
    
    
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:createButtonEnabledAttributes] forState:UIControlStateNormal];
    [self.createUpdateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:createUpdateButtonTitle attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.createUpdateButton.layer.cornerRadius=self.createUpdateButton.bounds.size.height/2;
    self.walletNewButton.layer.cornerRadius=self.walletNewButton.bounds.size.height/2;
    self.walletExistingButton.layer.cornerRadius=self.walletExistingButton.bounds.size.height/2;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
