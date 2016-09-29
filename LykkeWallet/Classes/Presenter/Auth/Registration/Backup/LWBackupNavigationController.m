//
//  LWBackupNavigationController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupNavigationController.h"

@interface LWBackupNavigationController ()

@property (strong, nonatomic) UIWindow *window;

@end

@implementation LWBackupNavigationController

-(id) init
{
    self=[super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

-(void) setRootMainTabScreen
{
    [_window setRootViewController:nil];
    _window=nil;
}

-(void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    _window=nil;
    [super dismissViewControllerAnimated:flag completion:completion];
}

-(UIViewController *) popViewControllerAnimated:(BOOL)animated
{
    if(self.viewControllers.count>1)
        return [super popViewControllerAnimated:animated];
    else
        [self setRootMainTabScreen];
    return nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _window=[UIApplication sharedApplication].keyWindow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) orientationChanged
{
    self.view.window.frame=[UIScreen mainScreen].bounds;
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
