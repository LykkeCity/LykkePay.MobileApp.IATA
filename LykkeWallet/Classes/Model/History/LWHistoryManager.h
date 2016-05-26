//
//  LWHistoryManager.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LWTransactionsModel;


@interface LWHistoryManager : NSObject {
    
}

+ (NSDictionary *)convertNetworkModel:(LWTransactionsModel *)model;
+ (NSArray *)sortKeys:(NSDictionary *)dictionary;

@end
