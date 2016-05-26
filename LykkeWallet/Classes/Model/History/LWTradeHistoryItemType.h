//
//  LWTradeHistoryItemType.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryItemType.h"


@class LWTransactionTradeModel;


@interface LWTradeHistoryItemType : LWBaseHistoryItemType {
    
}

@property (copy, nonatomic) NSNumber *volume;
@property (copy, nonatomic) NSString *iconId;

+ (LWTradeHistoryItemType *)convertFromNetworkModel:(LWTransactionTradeModel *)model;

@end
