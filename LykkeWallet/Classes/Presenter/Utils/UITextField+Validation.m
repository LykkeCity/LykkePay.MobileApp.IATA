//
//  UITextField+Validation.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UITextField+Validation.h"
#import "LWMath.h"


@implementation UITextField (Validation)

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forMaxLength:(NSInteger)maxLength {
    
    NSUInteger oldLength = [self.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
        
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    NSUInteger maxLengthResult = (maxLength > 0) ? maxLength : INT_MAX;
        
    BOOL isReturnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
    return (newLength <= maxLengthResult) || isReturnKey;
}

- (BOOL)isNumberValidForRange:(NSRange)range replacementString:(NSString *)string {

    NSInteger const maxLength = 12;
    BOOL result = [self shouldChangeCharactersInRange:range replacementString:string forMaxLength:maxLength];
    
    if (result) {
        NSString *candidate = [self.text stringByReplacingCharactersInRange:range withString:string];
        
        // Ensure that the local decimal seperator is used max 1 time
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSString *decimalSymbol = [formatter decimalSeparator];
        NSString *groupSymbol = [formatter groupingSeparator];
        if ([candidate componentsSeparatedByString:decimalSymbol].count > 2) {
            return NO;
        }
        
        NSString *validChars = [NSString stringWithFormat:@"0123456789%@%@", decimalSymbol, groupSymbol];
        if ([candidate stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:validChars]].length) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)isNumberValid {
    NSDecimalNumber *number = [LWMath numberWithString:self.text];
    BOOL const isValid = (number.doubleValue > 0.0);
    return isValid;
}

@end
