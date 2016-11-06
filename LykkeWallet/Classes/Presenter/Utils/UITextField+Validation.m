//
//  UITextField+Validation.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UITextField+Validation.h"
#import "LWMath.h"
#import <objc/runtime.h>

static void const *key;

@implementation UITextField (Validation)

- (int)accuracy {
    return [objc_getAssociatedObject(self, key) intValue];
}

- (void)setAccuracy:(int)accuracy {
    objc_setAssociatedObject(self, key, @(accuracy), OBJC_ASSOCIATION_RETAIN);
}

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
        NSArray *components=[candidate componentsSeparatedByString:decimalSymbol];
        if (components.count > 2 || (components.count==2 && self.accuracy==0)) {
            return NO;
        }
        if(components.count==2 && [components[1] length]>self.accuracy)  //Andrey
            return NO;
        
        NSString *validChars = [NSString stringWithFormat:@"0123456789%@%@", decimalSymbol, groupSymbol];
        if ([candidate stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:validChars]].length) {
            return NO;
        }
        return YES;
    }
    return NO;
}

-(void) setTextWithAccuracy:(NSString *)text
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSString *decimalSymbol = [formatter decimalSeparator];
   NSArray *components=[text componentsSeparatedByString:decimalSymbol];
    if (components.count<2 || [components[1] length]==0 || [components[1] length]<=self.accuracy) {
        
        self.text=text;
        
        return;
    }
    
   self.text=[NSString stringWithFormat:@"%@%@%@", components[0], decimalSymbol, [components[1] substringToIndex:self.accuracy]];
    
 

}

- (BOOL)isNumberValid {
    NSDecimalNumber *number = [LWMath numberWithString:self.text];
    BOOL const isValid = (number.doubleValue > 0.0);
    return isValid;
}

@end
