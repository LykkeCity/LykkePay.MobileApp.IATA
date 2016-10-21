//
//  LWMainTabPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMainTabPresenter.h"

@interface LWMainTabPresenter ()

@end

@implementation LWMainTabPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(void) setTitle:(NSString *)title
{
    
}

@end
