//
//  LWTextField.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKView.h"


@class LWTextField;
@class TKContainer;

@protocol LWTextFieldDelegate <NSObject>

@required
- (void)textFieldDidChangeValue:(LWTextField *)textField;

@optional
- (BOOL)textField:(LWTextField *)textField shouldChangeCharsInRange:(NSRange)range replacementString:(NSString *)string;
- (void)textFieldDidBeginEditing:(LWTextField *)textField;
- (void)textFieldDidEndEditing:(LWTextField *)textField;

@end

@interface LWTextField : TKView {
    
}

@property (weak, nonatomic) id<LWTextFieldDelegate> delegate;

@property (assign, nonatomic) NSString   *text;
@property (assign, nonatomic) NSString   *rawText;
@property (assign, nonatomic) NSString   *placeholder;
@property (assign, nonatomic) NSUInteger maxLength;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UITextFieldViewMode viewMode;
@property (assign, nonatomic) NSInteger leftOffset;
@property (assign, nonatomic) NSInteger rightOffset;

@property (assign, nonatomic, getter=isSecure)  BOOL secure;
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic, getter=isValid)   BOOL valid;

@property (assign, nonatomic) BOOL willRemoveText;

+ (LWTextField *)createTextFieldForContainer:(TKContainer *)container withPlaceholder:(NSString *)placeholder;

- (void)addSelector:(SEL)selector targer:(id)target;
- (void)setupAccessoryView:(UIView *)accessoryView;
- (void)showKeyboard;

@end
