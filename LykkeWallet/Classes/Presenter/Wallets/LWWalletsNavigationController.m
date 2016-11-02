//
//  LWWalletsNavigationController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletsNavigationController.h"
#import "LWWalletsPresenter.h"
#import "LWWalletsNavigationBar.h"
#import "LWPrivateWalletsPresenter.h"
#import "LWPrivateWalletAddView.h"
#import "LWAddPrivateWalletPresenter.h"
#import "LWCreatePrivateWalletPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWBackupNotificationView.h"
#import "LWPrivateKeyManager.h"

@interface LWWalletsNavigationController () <LWWalletsNavigationBarDelegate>
{
    NSArray *viewControllers;
    LWPrivateWalletAddView *plusView;
    UIBarButtonItem *itemPlus;
    LWPrivateWalletsPresenter *privateWalletsPresenter;
}

@end

@implementation LWWalletsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LWWalletsPresenter *exchangeWallets=[LWWalletsPresenter new];
    [super pushViewController:exchangeWallets animated:NO];
    
    plusView=[[LWPrivateWalletAddView alloc] init];
    itemPlus=[[UIBarButtonItem alloc] initWithCustomView:plusView];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewWalletPressed)];
    [plusView addGestureRecognizer:gesture];

//    [self setTitle:@"WALLETS"];
    // Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem=nil;

    return;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [self.navigationController setNavigationBarHidden:NO animated:NO];


    if([[self.viewControllers lastObject] isKindOfClass:[LWPrivateWalletsPresenter class]])
    {
        self.navigationController.visibleViewController.navigationItem.rightBarButtonItem=itemPlus;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"WALLET";
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self.navigationController.viewControllers containsObject:viewController])
        return [self.navigationController popToViewController:viewController animated:animated];
    return nil;
}

-(UIViewController *) popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) walletsNavigationBarPressedPrivateWallets
{
    if(!privateWalletsPresenter)
        privateWalletsPresenter=[[LWPrivateWalletsPresenter alloc] init];
    self.view.userInteractionEnabled=NO;
    [super pushViewController:privateWalletsPresenter animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled=YES;
    });
    
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem=itemPlus;
}

-(void) walletsNavigationBarPressedTradingWallets
{
    self.view.userInteractionEnabled=NO;

    [super popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled=YES;
    });

    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem=nil;

}

-(void) addNewWalletPressed
{
    if([[LWPrivateKeyManager shared] privateKeyWords]==nil)
    {
        LWBackupNotificationView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWBackupNotificationView" owner:self options:nil] objectAtIndex:0];
        view.type=BackupRequestTypeRequired;
        view.text=@"Please make a backup of your private key to be able to create a new private wallet.";
        [view show];
        return;
    }
    
    
    LWCreatePrivateWalletPresenter *presenter=[[LWCreatePrivateWalletPresenter alloc] init];
    [self.navigationController pushViewController:presenter animated:YES];
}

-(void) logout
{
    [(LWAuthNavigationController *)self.navigationController logout];
}




@end
