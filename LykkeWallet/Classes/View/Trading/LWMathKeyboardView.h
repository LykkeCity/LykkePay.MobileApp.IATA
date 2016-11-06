//
//  LWMathKeyboardView.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 14.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKView.h"

@class LWMathKeyboardView;

@protocol LWMathKeyboardViewDelegate
@required
- (void)volumeChanged:(NSString *)volume withValidState:(BOOL)isValid;
- (void)mathKeyboardViewDidRaiseMathException:(LWMathKeyboardView *)view;

@end


@interface LWMathKeyboardView : TKView {
    
}

@property (weak, nonatomic) UITextField *targetTextField;
@property (weak, nonatomic) id<LWMathKeyboardViewDelegate> delegate;

- (void)updateView;

@end
