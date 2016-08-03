//
//  LWIPadModalNavigationControllerViewController.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWIPadModalNavigationControllerViewController : UINavigationController <UIViewControllerTransitioningDelegate>

-(void) dismissAnimated:(BOOL) animated;

@end
