//
//  UIViewController+Navigation.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (Navigation)

- (void)setBackButton;
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)action;

@end
