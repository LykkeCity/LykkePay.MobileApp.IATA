//
//  LWCache.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCache.h"
#import "LWAssetModel.h"


@implementation LWCache


#pragma mark - Root

SINGLETON_INIT {
    self = [super init];
    if (self) {
        // initial values
        _refreshTimer = [NSNumber numberWithInteger:15];
        _debugMode    = NO;
    }
    return self;
}

- (BOOL)isMultisigAvailable {
    return (self.multiSig != nil
            && ![self.multiSig isKindOfClass:[NSNull class]]
            && ![self.multiSig isEqualToString:@""]);
}

+(BOOL) shouldHideDepositForAssetId:(NSString *)assetID
{
    BOOL shouldHide=NO;
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            shouldHide=asset.hideDeposit;
            break;
        }
    }
    
    return shouldHide;

}


+(BOOL) shouldHideWithdrawForAssetId:(NSString *)assetID
{
    BOOL shouldHide=NO;
    for(LWAssetModel *asset in [LWCache instance].allAssets)
    {
        if([asset.identity isEqualToString:assetID])
        {
            shouldHide=asset.hideWithdraw;
            break;
        }
    }
    
    return shouldHide;

//    NSArray *arr=@[@"USD",@"EUR", @"CHF", @"GBP", @"BTC", @"LKK"];
//    return [arr containsObject:assetID];
}

+(NSString *) currentAppVersion
{
    
    NSString *version= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *buildNum=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if(version && buildNum)
    {
        return [NSString stringWithFormat:@"Version %@ (%@)", buildNum, version];
    }
    return nil;
}

-(NSString *) currencySymbolForAssetId:(NSString *)assetId
{
//    NSDictionary *currencySymbols=@{@"USD":@"$",
//                                    @"EUR":@"€",
//                                    @"CHF":@"₣",
//                                    @"GBP":@"£",
//                                    @"JPY":@"¥",
//                                    @"BTC":@"BTC"};
    
    NSString *symbol;
    
    for(LWAssetModel *asset in self.allAssets)
    {
        if([asset.identity isEqualToString:assetId])
        {
            symbol=asset.symbol;
            break;
        }
    }

    if(!symbol)
        symbol=@"";
    return symbol;
}

+(BOOL) isBaseAsset:(NSString *) assetId
{
    BOOL flag=NO;
    for(LWAssetModel *asset in [LWCache instance].baseAssets)
    {
        if([asset.identity isEqualToString:assetId])
        {
            flag=YES;
            break;
        }
    }
    return flag;
}

@end
