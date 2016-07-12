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
#import "LWConstants.h"


@interface LWAuthPresenter () {
    
}

@end


@implementation LWAuthPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeGesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipedBack)];
    swipeGesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // management
    [LWAuthManager instance].delegate = self;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setLoading:NO];
}

-(void) userSwipedBack
{
    UIBarButtonItem *item=self.navigationItem.leftBarButtonItem;
    
    if(item)
        [self.navigationController popViewControllerAnimated:YES];
}





#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidNotAuthorized:(LWAuthManager *)manager {
    [self setLoading:NO];
    [((LWAuthNavigationController *)self.navigationController) logout];
}

@end
