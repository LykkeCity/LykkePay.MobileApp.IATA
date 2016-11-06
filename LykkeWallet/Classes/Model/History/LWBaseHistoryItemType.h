//
//  LWBaseHistoryItemType.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LWHistoryItemType) {
    //LWHistoryItemTypeMarket,
    LWHistoryItemTypeTrade,
    LWHistoryItemTypeCashInOut,
    LWHistoryItemTypeTransfer
};


@interface LWBaseHistoryItemType : NSObject<NSCopying> {
    
}


#pragma mark - Properties

@property (assign, nonatomic) LWHistoryItemType  historyType;
@property (copy,   nonatomic) NSString          *identity;
@property (copy,   nonatomic) NSString          *asset;
@property (copy,   nonatomic) NSDate            *dateTime;

@end
