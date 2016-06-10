//
//  LWCashInOutHistoryItemType.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryItemType.h"


@class LWTransactionCashInOutModel;


@interface LWCashInOutHistoryItemType : LWBaseHistoryItemType {
    
}

@property (copy, nonatomic) NSNumber *amount;
@property (copy, nonatomic) NSString *iconId;
@property (copy, nonatomic) NSString *blockchainHash;
@property BOOL isRefund;

+ (LWCashInOutHistoryItemType *)convertFromNetworkModel:(LWTransactionCashInOutModel *)model;

@end
