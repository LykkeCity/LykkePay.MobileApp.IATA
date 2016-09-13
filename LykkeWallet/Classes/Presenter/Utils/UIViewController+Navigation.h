//
//  UIViewController+Navigation.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BAR_GRAY_COLOR [UIColor colorWithRed:245.0/255 green:246.0/255 blue:248.0/255 alpha:1]



@interface UIViewController (Navigation)

- (void)setBackButton;
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)action;
- (void)setCrossCloseButton;
-(void) setCrossCloseButtonOnlyOne;

@end
