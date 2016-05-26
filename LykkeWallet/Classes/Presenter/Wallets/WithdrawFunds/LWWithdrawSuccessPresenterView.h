//
//  LWWithdrawSuccessPresenterView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWithdrawSuccessPresenterView : UIView

@property id delegate;

@end


@protocol LWWithdrawSuccessPresenterViewDelegate


-(void) withdrawSuccessPresenterViewPressedReturn:(LWWithdrawSuccessPresenterView *) view;

@end