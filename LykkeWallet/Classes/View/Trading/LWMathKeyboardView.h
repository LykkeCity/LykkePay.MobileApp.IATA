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
- (void)mathKeyboardView:(LWMathKeyboardView *) view volumeStringChangedTo:(NSString *) string;
-(void) mathKeyboardDonePressed:(LWMathKeyboardView *) keyboardView;

@end


@interface LWMathKeyboardView : TKView {
    
}


-(void) setText:(NSString *) text;

@property BOOL isVisible;
@property (weak, nonatomic) UITextField *targetTextField;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSNumber *accuracy;


- (void)updateView;

@end
