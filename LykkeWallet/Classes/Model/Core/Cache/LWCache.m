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

-(int) accuracyForAssetId:(NSString *) assetId
{
    for(LWAssetModel *asset in self.baseAssets)
    {
        if([asset.identity isEqualToString:assetId])
            return asset.accuracy;
    }
    return 0;
}

@end
