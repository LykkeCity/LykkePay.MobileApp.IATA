//
//  LWValidator.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 10.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWValidator.h"
#import <UIKit/UIImage.h>


@interface LWValidator () {
    
}


#pragma mark - Utils
+ (void)updateButton:(UIButton *)button activeImage:(NSString *)activeImage inactiveImage:(NSString *)inactiveImage enabled:(BOOL)enabled;

@end


@implementation LWValidator

static int const MinTextLength = 1;
static int const PasswordLength = 6;

#pragma mark - Texts

+ (BOOL)validateEmail:(NSString *)input {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:input];
}

+ (BOOL)validateFullName:(NSString *)input {
    return (input && input.length >= MinTextLength);
}

+ (BOOL)validatePhone:(NSString *)input {
    return (input && input.length >= MinTextLength);
}

+ (BOOL)validatePassword:(NSString *)input {
    return (input && input.length >= PasswordLength);
}

+ (BOOL)validateConfirmPassword:(NSString *)input {
    return (input && input.length >= PasswordLength);
}

+ (BOOL)validateCardNumber:(NSString *)input {
    NSString *cardNumberRegex = @"^(\\d{4}(?: )){3}\\d{4}$";
    NSPredicate *cardNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", cardNumberRegex];
    
    return [cardNumberTest evaluateWithObject:input];
}

+ (BOOL)validateCardExpiration:(NSString *)input {
    NSString *cardExpirationRegex = @"^(1[0-2]|(?:0)[1-9])(?:/)\\d{2}$";
    NSPredicate *cardExpirationTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", cardExpirationRegex];
    
    return [cardExpirationTest evaluateWithObject:input];
}

+ (BOOL)validateCardOwner:(NSString *)input {
    return input.length > 0;
}

+ (BOOL)validateCardCode:(NSString *)input {
    NSString *cardCodeRegex = @"^\\d{3}$";
    NSPredicate *cardCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", cardCodeRegex];
    
    return [cardCodeTest evaluateWithObject:input];
}

+ (BOOL)validateQrCode:(NSString *)input {
    return input.length > 0;
}

+ (void)setButton:(UIButton *)button enabled:(BOOL)enabled {
    [LWValidator updateButton:button
                  activeImage:@"ButtonOK"
                inactiveImage:@"ButtonOKInactive"
                      enabled:enabled];
}

+ (void)setPriceButton:(UIButton *)button enabled:(BOOL)enabled {
    [LWValidator updateButton:button
                  activeImage:@"ButtonOKGreen"
                inactiveImage:@"ButtonOKInactive"
                      enabled:enabled];
}

+ (void)setSellButton:(UIButton *)button enabled:(BOOL)enabled {
    [LWValidator updateButton:button
                  activeImage:@"ButtonOKRed"
                inactiveImage:@"ButtonOKInactive"
                      enabled:enabled];
}

+ (void)setBuyButton:(UIButton *)button enabled:(BOOL)enabled {
    [LWValidator updateButton:button
                  activeImage:@"ButtonOKGreen"
                inactiveImage:@"ButtonOKInactive"
                      enabled:enabled];
}


#pragma mark - Utils

+ (void)updateButton:(UIButton *)button activeImage:(NSString *)activeImage inactiveImage:(NSString *)inactiveImage enabled:(BOOL)enabled {
    NSString *proceedImage = (enabled) ? activeImage : inactiveImage;
    UIColor *proceedColor = (enabled) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    
    [button setBackgroundImage:[UIImage imageNamed:proceedImage] forState:UIControlStateNormal];
    [button setTitleColor:proceedColor forState:UIControlStateNormal];
    button.enabled = enabled;
}

@end
