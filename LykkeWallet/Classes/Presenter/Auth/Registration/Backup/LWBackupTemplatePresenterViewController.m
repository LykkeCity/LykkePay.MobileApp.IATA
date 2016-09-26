//
//  LWBackupTemplatePresenterViewController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupTemplatePresenterViewController.h"
#import "LWPrivateKeyManager.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Navigation.h"
#import "LWCache.h"

@interface LWBackupTemplatePresenterViewController () <UIAlertViewDelegate>

@end

@implementation LWBackupTemplatePresenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) shouldDismissIpadModalViewController
{
    if([LWPrivateKeyManager shared].privateKeyWords)
        return YES;
//    if([LWCache instance].userWatchedAllBackupWords==NO)
//    {
//        return YES;
//    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Cancel backup" message:@"12 words will be discarded and will not be valid any more.\nDo you want to cancel the wallet backup?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    return NO;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex!=alertView.cancelButtonIndex)
    {
//        [LWCache instance].userWatchedAllBackupWords=NO;
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        {
            UIViewController *firstController=[self.navigationController.viewControllers firstObject];
            if([firstController isKindOfClass:[UITabBarController class]])
                [self.navigationController popToRootViewControllerAnimated:YES];
            else
                [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
            
        }
        else
        {
            [super crossCloseButtonPressed];
        }

    }
}




@end
