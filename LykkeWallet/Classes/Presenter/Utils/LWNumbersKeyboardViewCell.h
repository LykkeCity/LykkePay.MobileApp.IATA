//
//  LWNumbersKeyboardViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWNumbersKeyboardViewCell : UIView

@property id delegate;

@end

@protocol LWNumbersKeyboardViewCellDelegate

-(void) numberCellPressedSymbol:(NSString *) symbol;
-(void) numberCellPressedBackspace;

@end