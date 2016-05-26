//
//  LWPacketAssetPairs.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetPairs.h"
#import "LWAssetPairModel.h"

@implementation LWPacketAssetPairs


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"AssetPairs"]) {
        [list addObject:[[LWAssetPairModel alloc] initWithJSON:item]];
    }
    _assetPairs = list;
}

- (NSString *)urlRelative {
    return @"AssetPairs";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
