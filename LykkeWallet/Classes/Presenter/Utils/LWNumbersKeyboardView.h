//
//  LWNumbersKeyboardView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWNumbersKeyboardView : UIView

@property (strong, nonatomic) UITextField *textField;
@property id delegate;

@end

@protocol LWNumbersKeyboardViewDelegate

-(void) numbersKeyboardViewPressedDone;
-(void) numbersKeyboardChangedText;

@end
