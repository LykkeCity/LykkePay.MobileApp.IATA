//
//  NSString+Date.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 11.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSString+Date.h"


@implementation NSString (Date)

- (NSDate *)toDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:self];
    return dateFromString;
}

@end
