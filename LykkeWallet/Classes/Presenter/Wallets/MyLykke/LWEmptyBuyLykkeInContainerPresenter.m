//
//  LWEmptyBuyLykkeInContainerPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEmptyBuyLykkeInContainerPresenter.h"
#import "LWTabController.h"

@interface LWEmptyBuyLykkeInContainerPresenter ()

@end

@implementation LWEmptyBuyLykkeInContainerPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) depositButtonPressed:(id)sender
{
    
    NSArray *arr=self.navigationController.viewControllers;
    if([[arr firstObject] isKindOfClass:[LWTabController class]])
    {
        UITabBarController *tabBar=[arr firstObject];
        tabBar.selectedIndex=0;
        [self.navigationController setViewControllers:@[tabBar]];
    }
//    id sss=self.tabBarController;
//    
//    
//    if([self.delegate respondsToSelector:@selector(emptyPresenterPressedDeposit)])
//        [self.delegate emptyPresenterPressedDeposit];
}

-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
        return @"LWEmptyBuyLykkeInContainerPresenter_iphone5";
    else if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        return @"LWEmptyBuyLykkeInContainerPresenter";
 
    }
    else
        return @"LWEmptyBuyLykkeInContainerPresenter";

}
@end
