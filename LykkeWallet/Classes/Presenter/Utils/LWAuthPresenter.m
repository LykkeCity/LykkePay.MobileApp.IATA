//
//  LWAuthPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Loading.h"


@interface LWAuthPresenter () {
    
}

@end


@implementation LWAuthPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // management
    [LWAuthManager instance].delegate = self;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidNotAuthorized:(LWAuthManager *)manager {
    [self setLoading:NO];
    [((LWAuthNavigationController *)self.navigationController) logout];
}

@end
