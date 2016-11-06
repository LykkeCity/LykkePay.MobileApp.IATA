//
//  TKNavigationPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKNavigationPresenter.h"
#import "UIColor+Generic.h"
#import "LWConstants.h"

@interface TKNavigationPresenter () {
    
}

@end


@implementation TKNavigationPresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#endif

- (void)setTitle:(NSString *)title {
    [super setTitle:[title uppercaseString]];
}

@end
