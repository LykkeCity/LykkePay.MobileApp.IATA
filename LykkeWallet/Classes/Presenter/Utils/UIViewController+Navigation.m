//
//  UIViewController+Navigation.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UIViewController+Navigation.h"
#import "LWConstants.h"
#import "LWAuthManager.h"




@implementation UIViewController (Navigation)

- (void)setBackButton {
    if (self.navigationController && self.navigationItem) {
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone || ([self.navigationController.viewControllers indexOfObject:self]>0))
        {
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon"] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
            self.navigationItem.leftBarButtonItem = button;
        }
        else
        {
            [self setCancelButtonWithTitle:Localize(@"register.phone.cancel") target:self.navigationController selector:@selector(popViewControllerAnimated:)];
 
        }
    }
}

- (void)setCrossCloseButton {
    if (self.navigationController && self.navigationItem) {
             UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseCross"] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popToRootViewControllerAnimated:)];
            self.navigationItem.leftBarButtonItem = button;
    }
}



- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)action {
    if (self.navigationItem && self.navigationController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:title
                                         style:UIBarButtonItemStylePlain
                                         target:target
                                         action:action];
        
        UIFont *font = [UIFont fontWithName:kModalNavBarFontName
                                       size:kModalNavBarFontSize];
        
        [cancelButton setTitleTextAttributes:@{NSFontAttributeName:font}
                                    forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

@end
