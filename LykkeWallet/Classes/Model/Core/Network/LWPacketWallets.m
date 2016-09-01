//
//  LWPacketWallets.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketWallets.h"
#import "LWCache.h"


@implementation LWPacketWallets


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _data = [[LWLykkeWalletsData alloc] initWithJSON:result];
    [LWCache instance].walletsData=_data.lykkeData;
}

- (NSString *)urlRelative {
    return @"Wallets";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
