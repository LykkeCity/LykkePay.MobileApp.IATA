//
//  LWWithdrawCurrencyCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWithdrawCurrencyCell : UIView

-(id) initWithWidth:(CGFloat)width title:(NSString *) title placeholder:(NSString *) placeholder addBottomLine:(BOOL) flagLine;

-(NSString *) text;

@property id delegate;

@end


@protocol LWWithdrawCurrencyCellDelegate

-(void) withdrawCurrencyCell:(LWWithdrawCurrencyCell *) cell changedHeightFrom:(CGFloat) prevHeight to:(CGFloat) curHeight;

@end

