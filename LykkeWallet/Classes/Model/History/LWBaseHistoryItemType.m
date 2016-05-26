//
//  LWBaseHistoryItemType.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryItemType.h"


@implementation LWBaseHistoryItemType

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWBaseHistoryItemType* data = [[[self class] allocWithZone:zone] init];
    data.historyType = self.historyType;
    data.identity    = [self.identity copy];
    data.dateTime    = [self.dateTime copy];
    data.asset       = [self.asset copy];
    return data;
}

@end
