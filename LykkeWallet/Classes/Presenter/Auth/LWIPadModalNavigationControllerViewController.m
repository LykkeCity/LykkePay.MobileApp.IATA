//
//  LWIPadModalNavigationControllerViewController.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWIPadModalNavigationControllerViewController.h"

@interface LWIPadModalNavigationControllerViewController  ()
{
    UIView *shadow;
}

@property BOOL presenting;

@end

@implementation LWIPadModalNavigationControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.presenting=NO;
    self.view.translatesAutoresizingMaskIntoConstraints=YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) shadowPressed
{
    [self dismiss];
}

#pragma mark - TransitioningForIpad

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext     {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if(self.presenting==NO)
    {
        toViewController.view.clipsToBounds=YES;
        
        toViewController.view.alpha=0;
        shadow=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        shadow.backgroundColor=[UIColor colorWithRed:53.0/255 green:76.0/255 blue:97.0/255 alpha:0.5];
        shadow.alpha=0;
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowPressed)];
        [shadow addGestureRecognizer:gesture];
        
        toViewController.view.frame=CGRectMake(0, 0, 475, 650);
        toViewController.view.center=CGPointMake(fromViewController.view.bounds.size.width/2, fromViewController.view.bounds.size.height*1.5);
//        toViewController.view.center=CGPointMake(fromViewController.view.bounds.size.width/2, fromViewController.view.bounds.size.height/2);
        
        [transitionContext.containerView addSubview:shadow];
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            toViewController.view.center=CGPointMake(fromViewController.view.bounds.size.width/2, fromViewController.view.bounds.size.height*0.5);

            toViewController.view.alpha=1;
            shadow.alpha=1;
        }completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else
    {
        
        [UIView animateWithDuration:0.5 animations:^{
            fromViewController.view.center=CGPointMake(toViewController.view.bounds.size.width/2, toViewController.view.bounds.size.height*1.5);

//            fromViewController.view.alpha=0;
            
            shadow.alpha=0;
        }completion:^(BOOL finished) {
            [shadow removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];

    }
    
    self.presenting=!self.presenting;
    

}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    
    UIViewController *result = [super popViewControllerAnimated:animated];
    if(!result)
    {
        [self dismiss];
    }
    return result;
}

-(void) dismiss
{
    UINavigationController *parent=(UINavigationController *)self.presentingViewController;
    [parent dismissViewControllerAnimated:YES completion:^{
        
        UITabBarController *vvv=(UITabBarController *)parent.visibleViewController;
        
        if([vvv isKindOfClass:[UITabBarController class]])
        {
            [vvv.selectedViewController viewWillAppear:YES];
            [vvv.selectedViewController viewDidAppear:YES];
        }
        else
        {
            [vvv viewWillAppear:YES];
            [vvv viewDidAppear:YES];
        }
        
    }];

}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}


-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
    
    CGSize mySize=self.view.frame.size;
    
            [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context){
    
                
                self.view.frame=CGRectMake(0, 0, mySize.width, mySize.height);
                self.view.center=CGPointMake(size.width/2, size.height/2);
    
            } completion:^(id <UIViewControllerTransitionCoordinatorContext> context){
            
            
            }];

}


@end
