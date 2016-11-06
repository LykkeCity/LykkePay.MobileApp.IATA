//
//  LWPacketBuySellAsset.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBuySellAsset.h"
#import "LWAssetDealModel.h"


@implementation LWPacketBuySellAsset


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _deal = [[LWAssetDealModel alloc] initWithJSON:result[@"Order"]];
}

- (NSString *)urlRelative {
    return @"PurchaseAsset";
}

- (NSDictionary *)params {
    return @{@"BaseAsset" : self.baseAsset,
             @"AssetPair" : self.assetPair,
             @"Volume"    : self.volume,
             @"Rate"      : self.rate};
}

@end
