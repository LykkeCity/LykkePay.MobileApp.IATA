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
    result.volume      = model.amount;
    result.asset       = model.asset;
    
    result.historyType = LWHistoryItemTypeCashInOut;
    
    result.isRefund=model.isRefund;
    result.addressFrom=model.addressFrom;
    result.addressTo=model.addressTo;

    result.iconId=model.iconId;
    result.blockchainHash=model.blockchainHash;
    result.isSettled=model.isSettled;
    
    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWCashInOutHistoryItemType* data = [super copyWithZone:zone];
    data.volume = [self.volume copy];
    data.asset = [self.iconId copy];
    data.blockchainHash=[self.blockchainHash copy];
    data.isRefund=self.isRefund;
    return data;
}

@end
