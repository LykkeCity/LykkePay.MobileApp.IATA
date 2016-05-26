//
//  LWPacketBaseAssets.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketBaseAssets.h"
#import "LWAssetModel.h"
#import "LWCache.h"


@implementation LWPacketBaseAssets


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *item in result[@"Assets"]) {
        [list addObject:[[LWAssetModel alloc] initWithJSON:item]];
    }
    _assets = list;

    [LWCache instance].baseAssets = _assets;
}

- (NSString *)urlRelative {
    return @"BaseAssets";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
