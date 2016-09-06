//
//  LWMyLykkeIPadNavigationController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeIPadNavigationController.h"
#import "LWMyLykkeCreditCardDepositPresenter.h"

@interface LWMyLykkeIPadNavigationController ()

@end

@implementation LWMyLykkeIPadNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backButton.hidden=YES;
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setTitle:(NSString *)title
{
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                @(1.5f), NSKernAttributeName,
                                nil];
    
    _titleLabel.attributedText=[[NSAttributedString alloc] initWithString:[title uppercaseString] attributes:attributes];
}

-(UIViewController *) popViewControllerAnimated:(BOOL)animated
{
    if(self.viewControllers.count==2)
        self.backButton.hidden=YES;
    UIViewController *v=[super popViewControllerAnimated:animated];
    
    return v;
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.backButton.hidden=NO;
    [super pushViewController:viewController animated:animated];
}

-(void) backButtonPressed
{
    if([self.viewControllers.lastObject isKindOfClass:[LWMyLykkeCreditCardDepositPresenter class]])
    {
        [(LWMyLykkeCreditCardDepositPresenter *)self.viewControllers.lastObject backButtonPressed];
    }
    else
        [self popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
