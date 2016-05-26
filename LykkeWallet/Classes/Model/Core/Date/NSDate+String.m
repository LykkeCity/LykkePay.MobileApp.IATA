//
//  NSDate+String.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSDate+String.h"


@implementation NSDate (String)

- (NSString *)toShortFormat {
    NSString *dateString = [NSDateFormatter
                            localizedStringFromDate:self
                            dateStyle:NSDateFormatterShortStyle
                            timeStyle:NSDateFormatterShortStyle];
    return dateString;
}

@end
