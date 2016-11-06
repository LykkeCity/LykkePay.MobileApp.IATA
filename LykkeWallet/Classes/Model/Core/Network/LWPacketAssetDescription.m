//
//  LWPacketAssetDescription.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAssetDescription.h"
#import "LWAssetDescriptionModel.h"


@implementation LWPacketAssetDescription


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _assetDescription = [[LWAssetDescriptionModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"AssetDescription/%@", self.identity];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
