//
//  LWCache.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"


@interface LWCache : NSObject {
    
}

SINGLETON_DECLARE


#pragma mark - Properties

@property (copy, nonatomic) NSNumber *refreshTimer;
@property (copy, nonatomic) NSString *baseAssetId;
@property (copy, nonatomic) NSString *baseAssetSymbol;
@property (copy, nonatomic) NSArray  *baseAssets; // Array of LWAssetModel items

@property (copy, nonatomic) NSArray *allAssets;

@property (copy, nonatomic) NSString *depositUrl;
@property (copy, nonatomic) NSString *multiSig;
@property (copy, nonatomic) NSString *coloredMultiSig;

@property (copy, nonatomic) NSString *refundAddress;

// Array of LWAssetsDictionaryItem items
@property (copy, nonatomic) NSArray  *assetsDict;
@property (assign, nonatomic) BOOL shouldSignOrder;
@property (assign, nonatomic) BOOL debugMode;

- (BOOL)isMultisigAvailable;

+(BOOL) shouldHideDepositForAssetId:(NSString *)assetID;
+(BOOL) shouldHideWithdrawForAssetId:(NSString *)assetID;

+(BOOL) isBaseAsset:(NSString *) assetId;

+(NSString *) currentAppVersion;

-(NSString *) currencySymbolForAssetId:(NSString *) assetId;

@end
