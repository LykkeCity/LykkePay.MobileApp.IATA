//
//  LWPacketGraphPeriodsGet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGraphPeriodsGet.h"
#import "LWGraphPeriodModel.h"
#import "LWCache.h"


@implementation LWPacketGraphPeriodsGet


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    // read assets
    NSMutableArray *periods = [NSMutableArray new];
    for (NSDictionary *item in result[@"AvailablePeriods"]) {
        [periods addObject:[[LWGraphPeriodModel alloc] initWithJSON:item]];
    }
    
    [LWCache instance].graphPeriods = [periods copy];
    _graphPeriods = periods;
}

- (NSString *)urlRelative {
    NSString *url = [NSString stringWithFormat:@"GraphPeriods"];
    return url;
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
