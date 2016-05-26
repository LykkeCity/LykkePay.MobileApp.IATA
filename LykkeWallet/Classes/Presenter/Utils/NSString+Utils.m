//
//  NSString+Utils.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "NSString+Utils.h"


@implementation NSString (Utils)

- (BOOL)isEmpty {
    return (self == nil || [self isEqualToString:@""] || [self isKindOfClass:[NSNull class]]);
}

@end
