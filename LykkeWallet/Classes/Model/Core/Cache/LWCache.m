//
//  LWCache.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCache.h"


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

+(BOOL) isAssetDepositAvailableForAssetID:(NSString *)assetID
{
    NSArray *arr=@[@"USD",@"EUR", @"CHF", @"GBP", @"BTC", @"LKK"];
    return [arr containsObject:assetID];
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

@end
