//
//  LWPacketCashOut.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCashOut.h"


@implementation LWPacketCashOut


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
}

- (NSString *)urlRelative {
    return @"CashOut";
}

- (NSDictionary *)params {
    return @{@"MultiSig" : self.multiSig,
             @"Amount"   : self.amount,
             @"AssetId"  : self.assetId
             };
}

@end
