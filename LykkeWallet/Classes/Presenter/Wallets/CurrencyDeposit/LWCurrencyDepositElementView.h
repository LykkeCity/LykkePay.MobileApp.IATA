//
//  LWCurrencyDepositElementView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWCurrencyDepositElementView : UIView

-(id) initWithTitle:(NSString *) title text:(NSString *) text;
-(void) setWidth:(CGFloat) width;

@property id delegate;

@end


@protocol LWCurrencyDepositElementViewDelegate

-(void) elementViewCopyPressed:(LWCurrencyDepositElementView *) view;

@end