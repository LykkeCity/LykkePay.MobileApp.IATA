//
//  LWMyLykkeSuccessViewController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeSuccessViewController.h"
#import "AppDelegate.h"

@interface LWMyLykkeSuccessViewController ()
{
    UIViewController *previousRoot;
    UIWindow *myWindow;
}

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation LWMyLykkeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showInWindow:(UIWindow *) window
{
    previousRoot=window.rootViewController;
    self.view.frame=window.bounds;
    [window setRootViewController:self];
    myWindow=window;
    self.amountLabel.text=[NSString stringWithFormat:@"Your purchase of LKK %@ has been successfully committed. Your Lykke Wallet balance is now updated.", self.amount];
}

-(void) buttonPressed
{
    [myWindow setRootViewController:previousRoot];
}


@end
