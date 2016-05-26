//
//  LWTextField.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWTextField.h"
#import "LWConstants.h"
#import "TKContainer.h"
#import "LWStringUtils.h"
#import "NSObject+GDXObserver.h"
#import "UITextField+Validation.h"


@interface LWTextField ()<UITextFieldDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *validImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;


#pragma mark - Observing

- (void)observeTextFieldDidChangeNotification:(NSNotification *)notification;

@end


@implementation LWTextField


#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.validImageView.hidden = YES;
    // observe text changes
    [self subscribe:UITextFieldTextDidChangeNotification
           selector:@selector(observeTextFieldDidChangeNotification:)];
    
    UIImage *background = [[UIImage imageNamed:@"TextField"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    self.backgroundImageView.image = background;
    [self setLeftOffset:kDefaultLeftTextFieldOffset];
    [self setRightOffset:kDefaultRigthTextFieldOffset];
}

- (void)dealloc {
    [self unsubscribeAll];
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

+ (LWTextField *)createTextFieldForContainer:(TKContainer *)container withPlaceholder:(NSString *)placeholder {
    LWTextField *(^createField)(TKContainer *, NSString *) = ^LWTextField *(TKContainer *container, NSString *placeholder) {
        
        LWTextField *f = [LWTextField new];
        f.keyboardType = UIKeyboardTypeASCIICapable;
        f.placeholder = placeholder;
        [container attach:f];
        
        return f;
    };
    
    LWTextField *result = createField(container, placeholder);
    return result;
}

- (void)addSelector:(SEL)selector targer:(id)target {
    [self.textField addTarget:target
                       action:selector
             forControlEvents:UIControlEventEditingChanged];
}

- (void)setupAccessoryView:(UIView *)accessoryView {
    [self.textField setInputAccessoryView:accessoryView];
}

- (void)showKeyboard {
    [self.textField becomeFirstResponder];
}


#pragma mark - Observing

- (void)observeTextFieldDidChangeNotification:(NSNotification *)notification {
    [self.delegate textFieldDidChangeValue:self];
}


#pragma mark - Properties

- (NSString *)text {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setText:(NSString *)text {
    self.textField.text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)rawText {
    return self.textField.text;
}

- (void)setRawText:(NSString *)rawText {
    self.textField.text = rawText;
}

- (NSString *)placeholder {
    return self.textField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.textField.placeholder = placeholder;
}

- (void)setSecure:(BOOL)secure {
    _secure = secure;
    
    self.textField.secureTextEntry = self.secure;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    self.textField.enabled = self.isEnabled;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    
    self.textField.keyboardType = self.keyboardType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType {
    _autocapitalizationType = autocapitalizationType;
    
    self.textField.autocapitalizationType = self.autocapitalizationType;
}

- (void)setViewMode:(UITextFieldViewMode)viewMode {
    _viewMode = viewMode;
    
    [self.textField setClearButtonMode:self.viewMode];
}

- (void)setLeftOffset:(NSInteger)leftOffset {
    _leftOffset = leftOffset;
    self.leftConstraint.constant = leftOffset;
}

- (void)setRightOffset:(NSInteger)rightOffset {
    _rightOffset = rightOffset;
    self.rightConstraint.constant = rightOffset;
}

- (void)setValid:(BOOL)valid {
    _valid = valid;
    
    self.validImageView.hidden = !self.isValid;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharsInRange:replacementString:)]) {
        return [self.delegate textField:self shouldChangeCharsInRange:range replacementString:string];
    }
    else {
        return [textField shouldChangeCharactersInRange:range replacementString:string forMaxLength:self.maxLength];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:self];
    }
}

@end
