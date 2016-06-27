//
//  LWPacketGetRefundAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetRefundAddress.h"

@implementation LWPacketGetRefundAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.refundAddress=response[@"Result"][@"Address"];
    self.validDays=[response[@"Result"][@"ValidDays"] intValue];
    self.sendAutomatically=[response[@"Result"][@"SendAutomatically"] boolValue];
    
}

- (NSString *)urlRelative {
    return @"RefundSettings";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
