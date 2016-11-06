//
//  TKPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKPresenter.h"


@interface TKPresenter () {
    UITapGestureRecognizer *tapKeyboardClose;
}

#pragma mark - Private

- (void)closeKeyboard;

@end


@implementation TKPresenter


#pragma mark - Lifecycle

- (instancetype)init {
    return [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle mainBundle]];
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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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


- (void)setTitle:(NSString *)title {
    [super setTitle:[title uppercaseString]];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // ...
}

@end
