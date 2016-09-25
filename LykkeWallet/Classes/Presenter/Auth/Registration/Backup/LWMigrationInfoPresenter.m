//
//  LWMigrationInfoPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMigrationInfoPresenter.h"
#import "LWCommonButton.h"
#import "LWGenerateKeyPresenter.h"
#import "LWBackupGetStartedPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"

@interface LWMigrationInfoPresenter () <LWGenerateKeyPresenterDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet LWCommonButton *skipButton;
@property (weak, nonatomic) IBOutlet LWCommonButton *confirmButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmButtonWidth;

@end

@implementation LWMigrationInfoPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _skipButton.type=BUTTON_TYPE_CLEAR;
    if([UIScreen mainScreen].bounds.size.width==320)
        _confirmButtonWidth.constant=280;
    
    [_confirmButton addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


-(void) confirmClicked
{
    LWGenerateKeyPresenter *presenter=[[LWGenerateKeyPresenter alloc] init];
    presenter.delegate=self;
    presenter.flagSkipIntro=YES;
    [self.navigationController pushViewController:presenter animated:YES];
    
}

-(IBAction)skipBackupPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) generateKeyPresenterFinished:(LWGenerateKeyPresenter *)pres
{
    NSMutableArray *arr=[self.navigationController.viewControllers mutableCopy];
    [arr removeLastObject];
    [arr removeLastObject];
    LWBackupGetStartedPresenter *presenter=[[LWBackupGetStartedPresenter alloc] init];
    
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        [arr addObject:presenter];
        [self.navigationController setViewControllers:arr animated:YES];
//        [self.navigationController pushViewController:presenter animated:YES];
    }
    
    else
    {
        UINavigationController *navController=self.navigationController;
        [self.navigationController setViewControllers:arr animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LWIPadModalNavigationControllerViewController *navigationController=[[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
            navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            navigationController.transitioningDelegate=navigationController;
            [navController presentViewController:navigationController animated:YES completion:nil];

        });

    }

}

-(NSString *) nibName
{
    return @"LWMigrationInfoPresenter";
}


@end
