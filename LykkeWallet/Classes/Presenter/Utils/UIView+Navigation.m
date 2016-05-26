//
//  UIView+Navigation.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UIView+Navigation.h"
#import "LWConstants.h"


@implementation UIView (Navigation)

- (void)setCancelButtonWithTitle:(NSString *)title navigation:(UINavigationItem *)navigation target:(id)target selector:(SEL)action {
    if (navigation) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:title
                                         style:UIBarButtonItemStylePlain
                                         target:target
                                         action:action];
        
        UIFont *font = [UIFont fontWithName:kModalNavBarFontName
                                       size:kModalNavBarFontSize];
        
        [cancelButton setTitleTextAttributes:@{NSFontAttributeName:font}
                                    forState:UIControlStateNormal];
        
        navigation.leftBarButtonItem = cancelButton;
    }
}

@end
