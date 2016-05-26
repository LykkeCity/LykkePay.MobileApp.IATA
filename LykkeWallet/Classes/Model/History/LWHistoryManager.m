//
//  LWHistoryManager.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWHistoryManager.h"
#import "LWTransactionsModel.h"
#import "LWTransactionCashInOutModel.h"
#import "LWTransactionTransferModel.h"
#import "LWTransactionTradeModel.h"
#import "LWTradeHistoryItemType.h"
#import "LWCashInOutHistoryItemType.h"
#import "LWTransferHistoryItemType.h"


@implementation LWHistoryManager

// nsdictionary:
// key - date time of operation(s)
// value - set of operations for the selected date time
+ (NSDictionary *)convertNetworkModel:(LWTransactionsModel *)model {
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    // mapping trades
    if (model && model.trades) {
        for (LWTransactionTradeModel *tradeOperation in model.trades) {
            if (![result objectForKey:tradeOperation.dateTime]) {
                result[tradeOperation.dateTime] = [NSMutableArray new];
            }
            LWTradeHistoryItemType *item = [LWTradeHistoryItemType convertFromNetworkModel:tradeOperation];
            [result[tradeOperation.dateTime] addObject:item];
        }
    }
    
    // mapping cash in/out operations
    if (model && model.cashInOut) {
        for (LWTransactionCashInOutModel *cashInOutOperations in model.cashInOut) {
            if (![result objectForKey:cashInOutOperations.dateTime]) {
                result[cashInOutOperations.dateTime] = [NSMutableArray new];
            }
            LWCashInOutHistoryItemType *item = [LWCashInOutHistoryItemType convertFromNetworkModel:cashInOutOperations];
            [result[cashInOutOperations.dateTime] addObject:item];
        }
    }
    
#ifdef PROJECT_IATA
    // mapping transfer operations
    if (model && model.transfers) {
        for (LWTransactionTransferModel *transferOperations in model.transfers) {
            if (![result objectForKey:transferOperations.dateTime]) {
                result[transferOperations.dateTime] = [NSMutableArray new];
            }
            LWTransferHistoryItemType *item = [LWTransferHistoryItemType convertFromNetworkModel:transferOperations];
            [result[transferOperations.dateTime] addObject:item];
        }
    }
#endif
    
    return result;
}

+ (NSArray *)sortKeys:(NSDictionary *)dictionary {
    // sorting
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayUsingComparator:
                           ^(NSDate *d1, NSDate *d2) {
                               return [d2 compare:d1];
                           }];
    return sortedKeys;
}

@end
