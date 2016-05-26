//
//  LWCashInOutHistoryItemType.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCashInOutHistoryItemType.h"
#import "LWTransactionCashInOutModel.h"


@implementation LWCashInOutHistoryItemType


+ (LWCashInOutHistoryItemType *)convertFromNetworkModel:(LWTransactionCashInOutModel *)model {
    LWCashInOutHistoryItemType *result = [LWCashInOutHistoryItemType new];
    result.dateTime    = model.dateTime;
    result.identity    = model.identity;
    result.amount      = model.amount;
    result.asset       = model.asset;
    result.iconId      = model.iconId;
    result.historyType = LWHistoryItemTypeCashInOut;
    
    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWCashInOutHistoryItemType* data = [super copyWithZone:zone];
    data.amount = [self.amount copy];
    data.asset = [self.iconId copy];
    return data;
}

@end
