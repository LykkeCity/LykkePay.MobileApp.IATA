//
//  UIView+Navigation.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Navigation)

- (void)setCancelButtonWithTitle:(NSString *)title navigation:(UINavigationItem *)navigation target:(id)target selector:(SEL)action;

@end
