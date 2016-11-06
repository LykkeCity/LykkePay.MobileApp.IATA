//
//  LWPacketGraphRates.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGraphRates.h"
#import "LWGraphPeriodRatesModel.h"


@implementation LWPacketGraphRates


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _data = [[LWGraphPeriodRatesModel alloc] initWithJSON:result];
}

- (NSString *)urlRelative {
    NSString *url = [NSString stringWithFormat:@"AssetPairDetailedRates?period=%@&assetId=%@&points=%@", self.period, self.assetId, self.points];
    return url;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
