//
//  LWBackupIntroPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupIntroPresenter.h"
#import "LWValidator.h"
#import "LWBackupGetStartedPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWAuthNavigationController.h"
#import "LWCommonButton.h"
#import "LWPrivateKeyManager.h"

@interface LWBackupIntroPresenter ()

@property (weak, nonatomic) IBOutlet UIButton *takeBackupButton;
@property (weak, nonatomic) IBOutlet LWCommonButton *skipBackupButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takeBackupWidthConstraint;

@end

@implementation LWBackupIntroPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _takeBackupButton.enabled=YES;
    _skipBackupButton.type=BUTTON_TYPE_CLEAR;
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _takeBackupWidthConstraint.constant=280;
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([LWPrivateKeyManager shared].privateKeyLykke==nil)
    {
        [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[LWPrivateKeyManager generateSeedWords]];
        [self setLoading:YES];
        [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.takeBackupButton.layer.cornerRadius=self.takeBackupButton.bounds.size.height/2;
}

-(IBAction)takeBackupButtonPressed:(UIButton *)takeBackupButton
{
    LWBackupGetStartedPresenter *presenter=[[LWBackupGetStartedPresenter alloc] init];
    
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];

    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }

}

-(IBAction)skipBackupPressed:(id)sender
{
    [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
    
}


-(void) authManagerDidSendClientKeys:(LWAuthManager *)manager
{
    [self setLoading:NO];

}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response];
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
