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

@interface LWBackupIntroPresenter ()

@property (weak, nonatomic) IBOutlet UIButton *takeBackupButton;

@end

@implementation LWBackupIntroPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.takeBackupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BACK UP NOW" attributes:dict] forState:UIControlStateNormal];
    
    [LWValidator setButton:self.takeBackupButton enabled:YES];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
