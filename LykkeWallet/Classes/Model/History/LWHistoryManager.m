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
#import "LWExchangeInfoModel.h"


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

    
    return result;
}

+(NSArray *) convertHistoryToArrayOfArrays:(NSArray *) history
{
    NSMutableArray *result=[[NSMutableArray alloc] init];
    
    NSMutableArray *similar=[[NSMutableArray alloc] init];
    
    for(NSDictionary *d in history)
    {
        id item;
        if(d[@"Trade"])
        {
            LWTransactionTradeModel *m=[[LWTransactionTradeModel alloc] initWithJSON:d[@"Trade"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWTradeHistoryItemType convertFromNetworkModel:m];
            [(LWTradeHistoryItemType *)item setMarketOrder:[[LWExchangeInfoModel alloc] initWithJSON:d[@"Trade"][@"MarketOrder"]]];
//            [result[m.dateTime] addObject:item];
        }
        else if(d[@"CashInOut"])
        {
            LWTransactionCashInOutModel *m=[[LWTransactionCashInOutModel alloc] initWithJSON:d[@"CashInOut"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWCashInOutHistoryItemType convertFromNetworkModel:m];
//            [result[m.dateTime] addObject:item];
        }
        else if(d[@"Transfer"])
        {
            LWTransactionTransferModel *m=[[LWTransactionTransferModel alloc] initWithJSON:d[@"Transfer"]];
//            if(!result[m.dateTime])
//                result[m.dateTime]=[[NSMutableArray alloc] init];
            item = [LWTransferHistoryItemType convertFromNetworkModel:m];
//            [result[m.dateTime] addObject:item];
        }
        
        if(!item)
            continue;
        
        if(similar.count==0 || [similar.lastObject isKindOfClass:[item class]])
        {
            [similar addObject:item];
        }
        else
        {
            [result addObject:similar];
            similar=[[NSMutableArray alloc] init];
            [similar addObject:item];
        }
        

    }
    if(similar.count)
        [result addObject:similar];
    
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
