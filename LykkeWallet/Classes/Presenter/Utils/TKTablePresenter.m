//
//  TKTablePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTablePresenter.h"


@interface TKTablePresenter () {
    
}

@end


@implementation TKTablePresenter

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:[title uppercaseString]];
}

@end
