//
//  LWWalletsNavigationController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletsNavigationController.h"
#import "LWWalletsPresenter.h"

@interface LWWalletsNavigationController ()
{
    NSArray *viewControllers;
}

@end

@implementation LWWalletsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LWWalletsPresenter *exchangeWallets=[LWWalletsPresenter new];
    [super pushViewController:exchangeWallets animated:NO];
    
    
//    [self setTitle:@"WALLETS"];
    // Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    return;
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
