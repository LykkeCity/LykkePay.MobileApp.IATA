//
//  UITextField+Validation.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Validation)

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string forMaxLength:(NSInteger)maxLength;

- (BOOL)isNumberValidForRange:(NSRange)range replacementString:(NSString *)string;

- (BOOL)isNumberValid;

@end
