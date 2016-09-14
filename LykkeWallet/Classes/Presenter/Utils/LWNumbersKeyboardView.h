//
//  LWNumbersKeyboardView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWMathKeyboardCursorView.h"

@interface LWNumbersKeyboardView : UIView

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) LWMathKeyboardCursorView *cursor;

@property id delegate;

@property BOOL showDoneButton;
@property BOOL showDotButton;
@property BOOL showPredefinedSums;
@property BOOL showSeparators;

@property BOOL showSMSCodeCursor;

@property (strong, nonatomic) NSString *prefix;

@property int accuracy;


@end

@protocol LWNumbersKeyboardViewDelegate

-(void) numbersKeyboardViewPressedDone;
-(void) numbersKeyboardChangedText:(LWNumbersKeyboardView *) keyboard;
-(void) numbersKeyboardViewPressedDot;

@end
