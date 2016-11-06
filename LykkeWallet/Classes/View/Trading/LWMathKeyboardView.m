//
//  LWMathKeyboardView.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 14.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMathKeyboardView.h"
#import "LWMath.h"
#import "GCMathParser.h"

typedef NS_ENUM(NSInteger, LWMathKeyboardViewNumpad) {
    LWMathKeyboardViewNumpad1 = 1,
    LWMathKeyboardViewNumpad2,
    LWMathKeyboardViewNumpad3,
    LWMathKeyboardViewNumpad4,
    LWMathKeyboardViewNumpad5,
    LWMathKeyboardViewNumpad6,
    LWMathKeyboardViewNumpad7,
    LWMathKeyboardViewNumpad8,
    LWMathKeyboardViewNumpad9,
    LWMathKeyboardViewNumpad0,
    LWMathKeyboardViewNumpadDot,
    LWMathKeyboardViewNumpadBackspace
};

typedef NS_ENUM(NSInteger, LWMathKeyboardViewSign) {
    LWMathKeyboardViewSignDivide,
    LWMathKeyboardViewSignMultiply,
    LWMathKeyboardViewSignSubtract,
    LWMathKeyboardViewSignAdd,
    LWMathKeyboardViewSignEquals
};


@interface LWMathKeyboardView () {
    
}

@property (weak, nonatomic) IBOutlet UIButton *delimiterButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *snippetButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numpadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *signButtons;


#pragma mark - Actions

- (IBAction)snippetButtonClick:(UIButton *)sender;
- (IBAction)numpadButtonClick:(UIButton *)sender;
- (IBAction)signButtonClick:(UIButton *)sender;


#pragma mark - Utils

- (NSString *)decimalSeparator;
- (NSString *)groupSeparator;
- (void)calculate:(BOOL)shouldRaiseException shouldValidate:(BOOL)shouldValidate;
- (BOOL)isSymbolsExists:(NSString *)symbols forString:(NSString *)string;

@end


@implementation LWMathKeyboardView


#pragma mark - Root

- (void)updateView {
    NSInteger const SnippedValues[] = { 100, 1000, 10000 };
    
    int item = 0;
    for (UIButton *button in self.snippetButtons) {
        NSString *value = [LWMath stringWithInteger:SnippedValues[item]];
        [button setTitle:value forState:UIControlStateNormal];
        ++item;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat whLine = 1; // 1px between elements
    
    CGFloat wTotal = self.frame.size.width;
    CGFloat wSign = [self.signButtons.firstObject frame].size.width;
    CGFloat wNumpadArea = wTotal - wSign - whLine;
    CGFloat wNumpad = (wNumpadArea - whLine * 2) / 3;
    CGFloat wSnippet = (wTotal - whLine * 2) / 3;
    
    CGFloat hTotal = self.frame.size.height;
    CGFloat hSnippet = [self.snippetButtons.firstObject frame].size.height;
    CGFloat hNumpadArea = hTotal - hSnippet - whLine;
    CGFloat hNumpad = (hNumpadArea - whLine * 3) / 4;
    CGFloat hSign = hNumpadArea / 5;
    
    for (NSInteger i = 0; i < self.snippetButtons.count; i++) {
        UIButton *button = self.snippetButtons[i];
        button.frame = CGRectMake(i * (wSnippet + whLine), 0, wSnippet, hSnippet);
    }
    for (NSInteger i = 0; i < self.signButtons.count; i++) {
        UIButton *button = self.signButtons[i];
        button.frame = CGRectMake(wNumpadArea + whLine, hSnippet + whLine + i * hSign, wSign, hSign);
    }
    NSInteger col = 0;
    NSInteger row = -1;
    for (NSInteger i = 0; i < self.numpadButtons.count; i++, col++) {
        if (i % 3 == 0) {
            col = 0;
            ++row;
        }
        UIButton *button = self.numpadButtons[i];
        button.frame = CGRectMake(col * (wNumpad + whLine),
                                  (hSnippet + whLine) + row * (hNumpad + whLine),
                                  wNumpad,
                                  hNumpad);
    }
    
    [self.delimiterButton setTitle:[self decimalSeparator]
                          forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)snippetButtonClick:(UIButton *)sender {
    NSString *str = sender.titleLabel.text;
    self.targetTextField.text = str;
    [self calculate:NO shouldValidate:YES];
}

- (IBAction)numpadButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case LWMathKeyboardViewNumpadBackspace: {
            if (self.targetTextField.text.length > 0) {
                NSRange range = NSMakeRange(self.targetTextField.text.length - 1, 1);
                self.targetTextField.text = [self.targetTextField.text
                                             stringByReplacingCharactersInRange:range
                                             withString:@""];
                [self calculate:NO shouldValidate:YES];
            }
            break;
        }
        case LWMathKeyboardViewNumpadDot: {
            NSString *separator = [self decimalSeparator];
            self.targetTextField.text = [self.targetTextField.text
                                         stringByAppendingString:separator];
            [self calculate:NO shouldValidate:YES];
            break;
        }
        default: {
            self.targetTextField.text = [self.targetTextField.text
                                         stringByAppendingString:sender.titleLabel.text];
            [self calculate:NO shouldValidate:YES];
        }
    }
}

- (IBAction)signButtonClick:(UIButton *)sender {
    BOOL equals = NO;
    NSString *str = nil;
    switch (sender.tag) {
        case LWMathKeyboardViewSignDivide: {
            str = @"/";
            break;
        }
        case LWMathKeyboardViewSignMultiply: {
            str = @"*";
            break;
        }
        case LWMathKeyboardViewSignSubtract: {
            str = @"-";
            break;
        }
        case LWMathKeyboardViewSignAdd: {
            str = @"+";
            break;
        }
        case LWMathKeyboardViewSignEquals: {
            equals = YES;
            break;
        }
        case LWMathKeyboardViewNumpadDot: {
            str = [self decimalSeparator];
            break;
        }
    }
    if (!equals) {
        self.targetTextField.text = [self.targetTextField.text stringByAppendingString:str];
        [self calculate:NO shouldValidate:YES];
    }
    else {
        [self calculate:YES shouldValidate:NO];
    }
}


#pragma mark - Utils

- (NSString *)decimalSeparator {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *decimalSymbol = [formatter decimalSeparator];
    return decimalSymbol;
}

- (NSString *)groupSeparator {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSymbol = [formatter groupingSeparator];
    return groupingSymbol;
}

- (void)calculate:(BOOL)shouldRaiseException shouldValidate:(BOOL)shouldValidate {
    // calculate
    @try {
        NSString *separator = [self decimalSeparator];
        NSString *groupSeparator = [self groupSeparator];
        NSString *text = self.targetTextField.text;
        
        // remove group separator
        text = [text stringByReplacingOccurrencesOfString:groupSeparator withString:@""];

        // will not calculate if have extra symbols
        if ([self isSymbolsExists:@"+-/*" forString:text] && shouldValidate) {
            [self.delegate volumeChanged:@"" withValidState:NO];
            return;
        }
        
        NSString *result = [text copy];

        // set '.' as decimal separator for evaluation
        text = [text stringByReplacingOccurrencesOfString:separator withString:@"."];
        double evaluation = [text evaluateMath];
        NSNumber *number = [NSNumber numberWithDouble:evaluation];
        if (number.doubleValue <= 0.0) {
            [self.delegate volumeChanged:text withValidState:NO];
            return;
        }
        
        NSDecimalNumber *resultChecker = [LWMath numberWithString:text];
        if (resultChecker.doubleValue != evaluation) {
            result = [LWMath makeEditStringByNumber:number];
        }

        self.targetTextField.text = result;
        [self.delegate volumeChanged:result withValidState:evaluation > 0.0];
    }
    @catch (NSException *exception) {
        if (shouldRaiseException) {
            [self.delegate mathKeyboardViewDidRaiseMathException:self];
        }
        [self.delegate volumeChanged:@"" withValidState:NO];
    }
}

- (BOOL)isSymbolsExists:(NSString *)symbols forString:(NSString *)string {
    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:symbols];
    NSRange range = [string rangeOfCharacterFromSet:cset];
    if (range.location == NSNotFound) {
        return NO;
    }
    return YES;
}

@end
