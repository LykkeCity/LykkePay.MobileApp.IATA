//
//  TKPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"
#import "LWConstants.h"
#import "LWWalletsNavigationController.h"


@interface TKPresenter () {
    UITapGestureRecognizer *tapKeyboardClose;
    
    UIView *modalTopBar;
}


#pragma mark - Private

- (void)closeKeyboard;

@end


@implementation TKPresenter


#pragma mark - Lifecycle

- (instancetype)init {
    
    NSString *classString=NSStringFromClass(self.class);
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
//    {
//        if([[NSBundle mainBundle] pathForResource:[classString stringByAppendingString:@"_iPad"] ofType:@"nib"])
//            classString=[classString stringByAppendingString:@"_iPad"];
//    }
    
    return [super initWithNibName:classString bundle:[NSBundle mainBundle]];
}

-(void) setTitle:(NSString *)title
{
    if(!title)
        return;
    UIFont *font = [UIFont fontWithName:kNavigationBarFontName size:kNavigationBarFontSize];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithHexString:kNavigationBarFontColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                @(1.5f), NSKernAttributeName,
                                nil];
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:[title uppercaseString] attributes:attributes];
    [titleLabel sizeToFit];
    
    if([self.navigationController isKindOfClass:[LWWalletsNavigationController class]])
    {
        self.navigationController.navigationController.navigationBar.topItem.titleView=titleLabel;
    }
    else
        self.navigationController.navigationBar.topItem.titleView=titleLabel;
    
}

- (void)dealloc {
    [self unsubscribeAll];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hideKeyboardOnTap = YES; // hide keyboard on tap by default
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.observeKeyboardEvents = NO; // no keyboard observing by default
    
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self localize];
    [self colorize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStylePlain
                                             target:self.navigationController
                                             action:@selector(popViewControllerAnimated:)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unsubscribeAll];
}



#pragma mark - Setup

- (void)localize {
    // override if necessary
}

- (void)colorize {
    // override if necessary
}


#pragma mark - Utils

- (void)animateConstraintChanges {
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    // ...
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    // ...
}


#pragma mark - Private

- (void)closeKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Properties

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}

- (void)setObserveKeyboardEvents:(BOOL)observeKeyboardEvents {
    if (self.observeKeyboardEvents == observeKeyboardEvents) {
        return;
    }
    _observeKeyboardEvents = observeKeyboardEvents;
    
    if (self.observeKeyboardEvents) {
        [self subscribe:UIKeyboardWillShowNotification selector:@selector(observeKeyboardWillShowNotification:)];
        [self subscribe:UIKeyboardWillHideNotification selector:@selector(observeKeyboardWillHideNotification:)];
    }
    else {
        [self unsubscribe:UIKeyboardWillShowNotification];
        [self unsubscribe:UIKeyboardWillHideNotification];
    }
}

- (void)setHideKeyboardOnTap:(BOOL)hideKeyboardOnTap {
    if (self.hideKeyboardOnTap == hideKeyboardOnTap) {
        return;
    }
    _hideKeyboardOnTap = hideKeyboardOnTap;
    
    if (self.hideKeyboardOnTap) {
        tapKeyboardClose = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(closeKeyboard)];
        [self.view addGestureRecognizer:tapKeyboardClose];
    }
    else {
        [self.view removeGestureRecognizer:tapKeyboardClose];
        // also remove reference
        tapKeyboardClose = nil;
    }
}




#pragma mark - Rotation

-(BOOL) shouldAutorotate
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        return YES;
    
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        return YES;

    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    // ...
//}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
//    LWIPadModalNavigationControllerViewController *parent=(LWIPadModalNavigationControllerViewController *)self.navigationController;
//    if([parent isKindOfClass:[LWIPadModalNavigationControllerViewController class]])
//    {
//        CGSize sss=parent.view.bounds.size;
//        
////        CGRect sss1=[(LWIPadModalNavigationControllerViewController *)parent view].frame;
////        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
////        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context){
////        
////            self.view.frame=CGRectMake((size.width-sss.width)/2, (size.height-sss.height)/2, sss.width, sss.height);
////        
////        } completion:^(id <UIViewControllerTransitionCoordinatorContext> context){}];
//        
//        parent.view.frame=CGRectMake((size.width-sss.width)/2, (size.height-sss.height)/2, sss.width, sss.height);
//
//    }
}









@end
