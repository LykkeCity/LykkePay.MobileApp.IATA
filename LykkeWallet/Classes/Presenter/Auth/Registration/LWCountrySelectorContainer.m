//
//  LWCountrySelectorContainer.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCountrySelectorContainer.h"
#import "LWCountrySelectorPresenter.h"
#import "UIViewController+Loading.h"
#import "UIViewController+Navigation.h"

@interface LWCountrySelectorContainer () <LWCountrySelectorPresenterDelegate>

@end

@implementation LWCountrySelectorContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LWCountrySelectorPresenter *presenter = [LWCountrySelectorPresenter new];

    presenter.delegate = self;
    presenter.countries=self.countries;
    
    presenter.view.frame=self.view.bounds;
    presenter.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:presenter.view];
    [self addChildViewController:presenter];
    [presenter didMoveToParentViewController:self];

    
    // Do any additional setup after loading the view.
}

-(void) countrySelected:(NSString *)name code:(NSString *)code prefix:(NSString *)prefix
{
    [self.delegate countrySelected:name code:code prefix:prefix];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCrossCloseButtonOnlyOne];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1]];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title=@"COUNTRY";
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) nibName
{
    return nil;
}
@end
